`timescale 1ns / 1ps

module Top_module (
    input  wire        iClk,
    input  wire        iRst,
    input  wire [7:0]  iData,
    output wire [7:0]  oData
);
    // BRAM Interface → WorkloadAllocator 연결 신호
    wire [7:0] wData;           // BRAM output data
    wire       done_sig;        // BRAM operation done signal
    reg [1:0] counter;

    // WorkloadAllocator 내부 제어 신호
    wire       oRouteToCnn;     // Routing decision
    wire       oDecisionValid;  // Routing valid pulse
    wire       wValid;
    Bram_interface #(
        .RAM_WIDTH(8),
        //.RAM_DEPTH(10240),
        .RAM_DEPTH(512),
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
        .INIT_FILE(""),   // 초기화 파일이 있다면 여기에 입력
        .IMG_WIDTH(32),
        .IMG_HEIGHT(16),
        .TILE_WIDTH(16),
        .TILE_HEIGHT(16)
    ) bram (
        .iClk(iClk),
        .iRst(iRst),
        .iData(iData),
        .enb(wValid),
        .oDone_sig(done_sig),  // output from BRAM module
        .oData(wData)         // BRAM read data
    );
    always @(posedge iClk) begin
        if(!iRst) begin
            counter <= 0;
        end else if (wValid) begin
            counter <= counter +1;
        end
    end

    reg r_Valid;
    always @(posedge iClk) begin
        if(!iRst) begin
            r_Valid <= 0;
        end else if (counter == 2'b11)begin
            r_Valid <= 1;
        end
    end

    WorkloadAllocator_SAD #(
        .TILE_WIDTH(16),
        .ROUTING_THRESHOLD_SAD(6000)
    ) workload_allocator_sad (
        .iClk(iClk),
        .iRst(iRst),
        .iData(wData),
        .iValid(r_Valid),           // valid input to allocator
        .oRouteToCnn(oRouteToCnn),
        .oDecisionValid(oDecisionValid)
    );

    // 예시로, 최종 출력 데이터를 BRAM의 출력으로 전달
    assign oData = wData;

endmodule