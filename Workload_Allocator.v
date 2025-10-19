`timescale 1ns / 1ps

module WorkloadAllocator_SAD #(
    //--- Parameters ---//
    parameter TILE_WIDTH            = 16,
    parameter ROUTING_THRESHOLD_SAD = 10000
) (
    // System Signals
    input  wire         iClk,
    input  wire         iRst,

    // Input Pixel Stream (Continuous Tiled)
    input  wire [7:0]   iData,
    input  wire         iValid,

    // Output Decision
    output reg          oRouteToCnn,
    output reg          oDecisionValid
);

//--- Registers & Wires ---//
reg [7:0]   tile_buffer_A [0:(TILE_WIDTH*TILE_WIDTH)-1];
reg [7:0]   tile_buffer_B [0:(TILE_WIDTH*TILE_WIDTH)-1];
reg [8:0]   pixel_count;
reg         write_to_A;

reg [15:0]  s1_pixel_sum;
reg [7:0]   s2_tile_average;
reg [15:0]  s2_sad_accumulator;

wire [7:0]  s2_pixel_from_buffer;
wire [8:0]  s2_diff;
wire [7:0]  s2_abs_diff;
wire        tile_is_done = (iValid && (pixel_count == (TILE_WIDTH * TILE_WIDTH - 1)));

assign s2_pixel_from_buffer = write_to_A ? tile_buffer_B[pixel_count] : tile_buffer_A[pixel_count];
assign s2_diff              = s2_pixel_from_buffer - s2_tile_average;
assign s2_abs_diff          = (s2_diff[8] == 1'b1) ? -s2_diff : s2_diff;
//--- Pipelined Logic ---//
always @(posedge iClk) begin
    if (!iRst) begin
        pixel_count        <= 0;
        write_to_A         <= 1'b1;
        s1_pixel_sum       <= 0;
        s2_tile_average    <= 0;
        s2_sad_accumulator <= 0;
        oRouteToCnn        <= 1'b0;
        oDecisionValid     <= 1'b0;
    end else begin
        oDecisionValid <= 1'b0;

        if (iValid) begin
            // ========================================================== //
            // == STAGE 1: Sum & Write to Buffer                     == //
            // ========================================================== //
            if (write_to_A) begin
                tile_buffer_A[pixel_count] <= iData;
            end else begin
                tile_buffer_B[pixel_count] <= iData;
            end
            
            // ⭐ 핵심 수정: 타일이 끝나면 0으로 초기화, 아니면 계속 더함
            if (tile_is_done) begin
                s1_pixel_sum <= 0; // 다음 타일을 위해 완벽하게 초기화
            end else begin
                s1_pixel_sum <= s1_pixel_sum + iData;
            end

            // ============================================================ //
            // == STAGE 2: Read & Calculate SAD                      == //
            // ============================================================ //
            // 타일이 끝나면 다음 SAD 계산을 위해 0으로 초기화, 아니면 계속 더함
            if (tile_is_done) begin
                s2_sad_accumulator <= 0;
            end else begin
                s2_sad_accumulator <= s2_sad_accumulator + s2_abs_diff;
            end

            // ============================================================ //
            // ==           Control Logic & Pipeline Management        == //
            // ============================================================ //
            if (tile_is_done) begin
                // 1. 최종 결정 (방금 2단계가 끝난 타일에 대한 결과)
                // s2_sad_accumulator의 최종 값은 현재 값 + 마지막 abs_diff 값임
                if ((s2_sad_accumulator + s2_abs_diff) > ROUTING_THRESHOLD_SAD) begin
                    oRouteToCnn <= 1'b1;
                end else begin
                    oRouteToCnn <= 1'b0;
                end
                oDecisionValid <= 1'b1;

                // 2. 1단계의 "최종 합계"를 정확히 계산하여 2단계로 전달
                // 현재 s1_pixel_sum은 마지막 픽셀을 더하기 전의 값임
                s2_tile_average <= (s1_pixel_sum + iData) >> 8;
                
                // 3. 버퍼 스왑
                write_to_A <= !write_to_A;
            end
            
            // 카운터 업데이트
            if (tile_is_done) begin
                pixel_count <= 0;
            end else begin
                pixel_count <= pixel_count + 1;
            end
        end
    end
end

endmodule