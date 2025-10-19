`timescale 1ns / 1ps

module tb_Topmodule;

    localparam RAM_DEPTH = 512;
    // localparam RAM_DEPTH = 307200; // 최종 검증 시에만 사용하세요.

    localparam RAM_WIDTH = 8;
    localparam CLK_PERIOD = 10;

    // --- DUT Inputs ---
    reg iClk;
    reg iRst;
    reg [RAM_WIDTH-1:0] iData;

    // --- DUT Outputs ---
    wire [RAM_WIDTH-1:0] oData;
    
    // --- Testbench Internal Signals ---
    // [수정 1] image.txt 파일 내용을 저장할 메모리 선언
    reg [RAM_WIDTH-1:0] image_data_from_file [0:RAM_DEPTH-1];
    integer i; // 루프 카운터
    integer error_count = 0;

    // --- DUT Instantiation ---
    Top_module 
    DUT (
        .iClk(iClk),
        .iRst(iRst),
        .iData(iData),
        .oData(oData)
    );
    
    // --- Clock Generation ---
    always #((CLK_PERIOD)/2) iClk = ~iClk;
    
    // --- Main Test Sequence ---
    initial begin
        // 1. Initialize signals
        $display("INFO: Starting Simulation with RAM_DEPTH = %0d", RAM_DEPTH);
        iClk = 0;
        iRst = 0; // Active-Low 리셋 활성화
        iData = 0;

        // [수정 2] 시뮬레이션 시작 시 image.txt 파일을 메모리로 로드
        $readmemh("image1.txt", image_data_from_file);
        $display("INFO: image.txt loaded into testbench memory.");
        
        // 2. Reset sequence
        #95;
        iRst = 1; // 리셋 해제
        $display("INFO: Reset released. DUT should start writing data.");
        
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin
            @(posedge iClk);
            iData <= image_data_from_file[i];
        end
        
        @(posedge iClk);
        iData <= 0; // 데이터 공급 완료 후 입력 0으로 유지
        $display("INFO: Finished providing all %0d bytes of image data.", RAM_DEPTH);

        // DUT가 WRITE 상태를 완료할 때까지 대기합니다.
        //repeat (RAM_DEPTH) @(posedge iClk);

        $display("INFO: DUT should now be reading data back.");
        
        // [수정 4] 자동 검증 로직
        // BRAM의 읽기 지연시간(2 사이클)만큼 기다린 후, 첫 데이터가 oData에 나타납니다.
        repeat (2) @(posedge iClk);

        repeat (2000) @(posedge iClk);
        $display("INFO: Simulation Finished.");
        $stop;
    end

endmodule

