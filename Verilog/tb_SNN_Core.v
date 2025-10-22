`timescale 1ns / 1ps

module tb_SNN_Core;

    //=============== 파라미터 및 상수 ===============//
    localparam IMAGE_WIDTH = 16;
    localparam CLK_PERIOD  = 10; // 클럭 주기 (10ns -> 100MHz)
    localparam PIXEL_COUNT = IMAGE_WIDTH * IMAGE_WIDTH;

    //=============== 테스트벤치 신호 선언 ===============//
    // DUT 입력 (reg 타입)
    reg                             iClk;
    reg                             iRst;
    reg                             iStart;
    reg [7:0]                       iData;
    reg                             iValid;

    // DUT 출력 (wire 타입)
    wire [7:0]                      oResult;
    wire                            oValid;

    //=============== 내부 신호 및 변수 ===============//
    integer                         out_file;
    integer                         pixel_idx;
    reg [7:0]                       input_memory [0:PIXEL_COUNT-1];

    //=============== DUT (SNN_Core) 인스턴스화 ===============//
    SNN_Core #(
        .IMAGE_WIDTH(IMAGE_WIDTH)
    ) u_SNN_Core (
        .iClk(iClk),
        .iRst(iRst),
        .iStart(iStart),
        .iData(iData),
        .iValid(iValid),
        .oResult(oResult),
        .oValid(oValid)
    );

    //=============== 1. 클럭 생성 ===============//
    // CLK_PERIOD 주기를 갖는 클럭을 항상 생성
    always #((CLK_PERIOD)/2) iClk = ~iClk;

    //=============== 2. 메인 테스트 시퀀스 ===============//
    initial begin
        // --- 2.1. 초기화 ---
        iClk   = 0;
        iRst   = 1'b1; // 리셋 활성화
        iStart = 1'b0;
        iData  = 8'd0;
        iValid = 1'b0;
        
        $display("INFO: 시뮬레이션을 시작합니다.");

        // --- 2.2. 입력 데이터 파일 로드 ---
        // $readmemh: 16진수 텍스트 파일을 메모리(레지스터 배열)로 로드
        $readmemh("tile_0000.txt", input_memory);
        $display("INFO: 'input_tile_16x16.txt' 파일 로드 완료.");

        //--- 2.3. 출력 파일 열기 ---
        out_file = $fopen("output_results.txt", "w");
        if (out_file == 0) begin
            $display("ERROR: 출력 파일 'output_results.txt'를 열 수 없습니다.");
            $finish;
        end

        // --- 2.4. 리셋 해제 ---
        #10;
        iRst = 1'b0;
        repeat (2) @(posedge iClk); // 2 클럭 동안 리셋 유지
        iRst = 1'b1;
        @(posedge iClk);
        
        // --- 2.5. 연산 시작 신호 ---
        iStart = 1'b1;
        @(posedge iClk);
        iStart = 1'b0; // 1 클럭 동안만 펄스 형태로 인가

        $display("INFO: 데이터 스트리밍을 시작합니다...");

        // --- 2.6. 16x16 (256개) 픽셀 데이터 스트리밍 ---
        for (pixel_idx = 0; pixel_idx < PIXEL_COUNT; pixel_idx = pixel_idx + 1) begin
            @(posedge iClk);
            iValid = 1'b1;
            iData  = input_memory[pixel_idx];
        end

        // --- 2.7. 입력 종료 ---
        @(posedge iClk);
        iValid = 1'b0;
        iData  = 8'd0;
        
        // --- 2.8. 파이프라인 Flush 대기 및 시뮬레이션 종료 ---
        // 파이프라인 딜레이 + 여유 시간만큼 대기
        repeat (IMAGE_WIDTH + 10) @(posedge iClk);

        $display("INFO: 시뮬레이션 완료. 결과는 'output_results.txt' 파일에 저장되었습니다.");
        $fclose(out_file); // 파일 닫기
        $stop;           // 시뮬레이션 종료
    end

    //=============== 3. 출력 모니터링 ===============//
    // 매 클럭 oValid 신호를 확인하여 유효한 결과값을 파일에 저장
    always @(posedge iClk) begin
        if (iRst && oValid) begin
            // $fwrite: 포맷에 맞춰 파일에 텍스트 쓰기
            $fwrite(out_file, "%h\n", oResult);
            // $display: 시뮬레이터 콘솔에 메시지 출력
            // $time: 현재 시뮬레이션 시간
            $display("TIME=%0t | Valid Output Detected: %h (Decimal: %d)", $time, oResult, oResult);
        end
    end

endmodule