`timescale 1ns / 1ps

module Top_module (
    input  wire        iClk,
    input  wire        iRst,
    input  wire [7:0]  iData,
    output wire [7:0]  oData
);
    // =========================================================
    // BRAM Interface → WorkloadAllocator 연결 신호
    // =========================================================
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
    wire       oRouteToCnn;     // 라우팅 결과 신호
    wire       oDecisionValid;  // 라우팅 결과 유효 신호
    reg        r_Valid;         // WorkloadAllocator 입력 유효 신호
    wire [7:0] oSNN_Result, oCNN_Result;
    wire oSNN_Valid, oCNN_Valid;

	// uart #(.DBIT(8),.SB_TICK(16),.DVSR(100),.DVSR_WIDTH(7),.FIFO_W(5)) m3 //Baud rate of 100_000(115_200 produce errors). Computation: DVSR=clk_freq/(16*BaudRate)
	// (
	// 	.clk(clk_sdram),
	// 	.rst_n(rst_n),
	// 	.rd_uart(),
	// 	.wr_uart(),
	// 	.wr_data(),
	// 	.rx(rx),
	// 	.tx(),
	// 	.rd_data(dout),
	// 	.rx_done(rx_done),
	// 	.tx_full()
    // );



    // =========================================================
    // BRAM Interface 인스턴스
    // =========================================================
    Bram_interface_Tiling #(
        .RAM_WIDTH(8),
        .RAM_DEPTH(307200),
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
        .INIT_FILE(""),   // 초기화 파일이 있다면 여기에 입력
        .IMG_WIDTH(640),
        .IMG_HEIGHT(480),
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
    // WorkloadAllocator
    // =========================================================
    WorkloadAllocator_SAD #(
        .TILE_WIDTH(16),
        .ROUTING_THRESHOLD_SAD(4000)
    ) workload_allocator_sad (
        .iClk(iClk),
        .iRst(iRst),
        .iData(wData_T2WF),
        .iValid(r_Valid),
        .oRouteToCnn(oRouteToCnn),
        .oDecisionValid(oDecisionValid)
    );
    // Core_Valid 신호를 제어하기 위한 레지스터 및 와이어
    wire Core_Valid;
    // 1. oDecisionValid 신호를 2 클럭 지연시켜 시작 트리거를 생성합니다.
    reg oDecisionValid_d1;
    reg oDecisionValid_d2;
    reg done_2_d1;
    reg done_2_d2;
    reg done_2_d3;
    always @(posedge iClk) begin
        if (!iRst) begin
            oDecisionValid_d1 <= 1'b0;
            oDecisionValid_d2 <= 1'b0;
        end else begin
            // 매 클럭마다 신호를 한 칸씩 옆으로 전달합니다.
            oDecisionValid_d1 <= oDecisionValid;
            oDecisionValid_d2 <= oDecisionValid_d1;
        end
    end
    assign Core_Valid = oDecisionValid_d2;
    // 최종 Core_Valid 신호는 정확히 2 클럭 지연된 oDecisionValid 값입니다.
    // oDecisionValid가 1클럭 펄스이므로, Core_Valid도 1클럭 펄스가 됩니다.

    reg wSNN_Valid;

    always @(posedge iClk) begin
        if (!iRst) begin
            done_2_d1 <= 1'b0;
            done_2_d2 <= 1'b0;
            done_2_d3 <= 1'b0;

        end else begin
            // 매 클럭마다 신호를 한 칸씩 옆으로 전달합니다.
            done_2_d1 <= done_2;
            done_2_d2 <= done_2_d1;
            done_2_d3 <= done_2_d2;
        end
    end



    always @(posedge iClk) begin
        if (!iRst) begin
            wSNN_Valid <= 0;
        end else if (done_2_d3) begin
            wSNN_Valid <= !oRouteToCnn;
        end
    end

    reg oRouteToCNN_d1;
    reg oRouteToCNN_d2;
    always @(posedge iClk) begin
        if (!iRst) begin
            oRouteToCNN_d1 <= 1'b0;
            oRouteToCNN_d2 <= 1'b0;
        end else begin
            // 매 클럭마다 신호를 한 칸씩 옆으로 전달합니다.
            oRouteToCNN_d1 <= oRouteToCnn;
            oRouteToCNN_d2 <= oRouteToCNN_d1;
        end
    end

    // =========================================================
    // SNN Core
    // =========================================================
    SNN_Core #(
        .IMAGE_WIDTH(16)
    ) u_SNN_Core (
        .iClk      (iClk),
        .iRst      (iRst),
        .iStart    (Core_Valid),//1클럭
        .iData     (data_out),
        .iValid    (wSNN_Valid),//256클럭
        .oResult   (oSNN_Result),
        .oValid    (oSNN_Valid)
    );

    //=========================================================
    // CNN Core
    //=========================================================
    CNN_Core #(
        .IMAGE_WIDTH(16)
    ) u_CNN_Core (
        .iClk      (iClk),
        .iRst      (iRst),
        .iStart    (Core_Valid),
        .iData     (data_out),
        .iValid    (oRouteToCNN_d2),//256클럭
        .oResult   (oCNN_Result),
        .oValid    (oCNN_Valid)
    );


    // =========================================================
    // 최종 출력
    // =========================================================
    assign oData = (oCNN_Valid) ? oCNN_Result : oSNN_Result;
    
endmodule
