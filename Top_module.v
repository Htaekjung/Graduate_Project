`timescale 1ns / 1ps

module Top_module (
    input  wire        iClk,
    input  wire        iRst,
    input  wire [7:0]  iData,
    output wire [7:0]  oData,
    output oRouteToCnn,
    output oDecisionValid
);
    // =========================================================
    // BRAM Interface → WorkloadAllocator 연결 신호
    // =========================================================
    wire [7:0] wData_B2WF;      // BRAM output data (Bram_interface_Tiling → WorkloadAllocator)
    wire [7:0] wData_T2WF;      // Bram_interface_Tiling → 첫 번째 FIFO 입력
    wire [7:0] wData_T2T;       // 첫 번째 FIFO → 두 번째 FIFO 데이터
    wire [7:0] data_out;        // 두 번째 FIFO → 최종 출력

    wire       done_sig;        // BRAM 동작 완료 신호
    wire       done_1;          // 첫 번째 FIFO 완료 신호
    wire       done_2;          // 두 번째 FIFO 완료 신호
    wire       wValid;          // BRAM read enable (valid)
    reg  [1:0] counter;         // 간단한 카운터

    // =========================================================
    // WorkloadAllocator 내부 제어 신호
    // =========================================================
    //wire       oRouteToCnn;     // 라우팅 결과 신호
    //wire       oDecisionValid;  // 라우팅 결과 유효 신호
    reg        r_Valid;         // WorkloadAllocator 입력 유효 신호
    wire done_3;
    wire [7:0] wData_T2T2;
    // =========================================================
    // BRAM Interface 인스턴스
    // =========================================================
    Bram_interface_Tiling #(
        .RAM_WIDTH(8),
        .RAM_DEPTH(512),
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
        .INIT_FILE(""),   // 초기화 파일이 있다면 여기에 입력
        .IMG_WIDTH(32),
        .IMG_HEIGHT(16),
        .TILE_WIDTH(16),
        .TILE_HEIGHT(16)
    ) bram (
        .iClk      (iClk),
        .iRst      (iRst),
        .iData     (iData),
        .enb       (wValid),
        .oDone_sig (done_sig),
        .oData     (wData_T2WF)
    );

    // =========================================================
    // Valid 생성 로직
    // =========================================================
    always @(posedge iClk) begin
        if (!iRst) begin
            counter <= 0;
        end else if (wValid) begin
            counter <= counter + 1;
        end
    end

    always @(posedge iClk) begin
        if (!iRst) begin
            r_Valid <= 0;
        end else if (counter == 2'b11) begin
            r_Valid <= 1;
        end
    end

    // =========================================================
    // FIFO 체인 1단계
    // =========================================================
    Bram_interface_FIFO #(
        .RAM_WIDTH(8),
        .RAM_DEPTH(512)
    ) u_bram_fifo_1 (
        .iClk    (iClk),
        .iRst    (iRst),
        .iStart  (done_sig),
        .iData   (wData_T2WF),
        .oDone   (done_1),
        .oData   (wData_T2T)
    );

    // =========================================================
    // FIFO 체인 2단계
    // =========================================================
    Bram_interface_FIFO #(
        .RAM_WIDTH(8),
        .RAM_DEPTH(512)
    ) u_bram_fifo_2 (
        .iClk    (iClk),
        .iRst    (iRst),
        .iStart  (done_1),
        .iData   (wData_T2T),
        .oDone   (done_2),
        .oData   (data_out)
    );
    // =========================================================
    // WorkloadAllocator 인스턴스
    // =========================================================
    WorkloadAllocator_SAD #(
        .TILE_WIDTH(16),
        .ROUTING_THRESHOLD_SAD(3000)
    ) workload_allocator_sad (
        .iClk(iClk),
        .iRst(iRst),
        .iData(wData_T2WF),
        .iValid(r_Valid),
        .oRouteToCnn(oRouteToCnn),
        .oDecisionValid(oDecisionValid)
    );

<<<<<<< HEAD









    // 예시로, 최종 출력 데이터를 BRAM의 출력으로 전달
    assign oData = wData;

endmodule
=======
    // =========================================================
    // 최종 출력
    // =========================================================
    assign oData = data_out;   // 마지막 FIFO 출력 연결
    
endmodule
>>>>>>> e0bdfa77416f92641869c108d4b68cd1cee9e697
