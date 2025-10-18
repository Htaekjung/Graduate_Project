`timescale 1ns / 1ps

module WorkloadAllocator_SAD #(
    //--- Parameters ---//
    parameter TILE_WIDTH            = 16,
    parameter ROUTING_THRESHOLD_SAD = 10000 // SAD 값이 이보다 크면 복잡한 타일로 간주
) (
    // System Signals
    input  wire         iClk,
    input  wire         iRst,

    // Input Pixel Stream (Tiled)
    input  wire [7:0]   iData,
    input  wire         iValid,

    // Output Decision
    output reg          oRouteToCnn,
    output reg          oDecisionValid
);

//--- FSM State Definition ---//
localparam STATE_IDLE       = 2'b00;
localparam STATE_SUM        = 2'b01; // 1단계: 합 계산 및 버퍼링
localparam STATE_CALC_SAD   = 2'b10; // 2단계: SAD 계산
localparam STATE_DECIDE     = 2'b11; // 최종 결정

//--- Registers & Wires ---//
reg [1:0]   state;

// Internal buffer to store one tile
reg [7:0]   tile_buffer [0:(TILE_WIDTH*TILE_WIDTH)-1];

// Counters and Accumulators
reg [8:0]   pixel_count;       // Counts from 0-255 for both stages
reg [15:0]  pixel_sum;         // Accumulates sum of pixels (max 255*256=65280)
reg [15:0]  sad_accumulator;   // Accumulates SAD value (max 255*256=65280)

reg [7:0]   tile_average;      // Stores the calculated average of the tile

wire [7:0]  pixel_from_buffer;
wire [8:0]  diff;
wire [7:0]  abs_diff;

assign pixel_from_buffer = tile_buffer[pixel_count];
assign diff = pixel_from_buffer - tile_average;
assign abs_diff = (diff[8] == 1'b1) ? -diff : diff; // Check sign bit for absolute value

always @(posedge iClk) begin
    if (!iRst) begin
        // Reset all registers
        state           <= STATE_IDLE;
        pixel_count     <= 0;
        pixel_sum       <= 0;
        sad_accumulator <= 0;
        tile_average    <= 0;
        oRouteToCnn     <= 1'b0;
        oDecisionValid  <= 1'b0;
    end else begin
        // Default outputs
        oDecisionValid <= 1'b0;

        case (state)
            STATE_IDLE: begin
                if (iValid) begin
                    // New tile starts, begin Stage 1
                    state           <= STATE_SUM;
                    pixel_count     <= 1; // Start counting from 1 for the first pixel
                    pixel_sum       <= iData;
                    tile_buffer[0]  <= iData;
                end
            end

            STATE_SUM: begin // Stage 1: Buffering and Summing
                if (pixel_count == (TILE_WIDTH * TILE_WIDTH - 1)) begin
                    // Last pixel of the tile received
                    state           <= STATE_CALC_SAD;
                    pixel_sum       <= pixel_sum + iData;
                    tile_buffer[pixel_count] <= iData;
                    tile_average    <= (pixel_sum + iData) >> 8; // Calculate average (divide by 256)
                    pixel_count     <= 0; // Reset for Stage 2
                    sad_accumulator <= 0; // Reset for Stage 2
                end else begin
                    // Continue summing and buffering
                    pixel_count     <= pixel_count + 1;
                    pixel_sum       <= pixel_sum + iData;
                    tile_buffer[pixel_count] <= iData;
                end
            end

            STATE_CALC_SAD: begin // Stage 2: Calculating SAD
                sad_accumulator <= sad_accumulator + abs_diff;

                if (pixel_count == (TILE_WIDTH * TILE_WIDTH - 1)) begin
                    // Finished calculating SAD for all pixels
                    state <= STATE_DECIDE;
                end else begin
                    pixel_count <= pixel_count + 1;
                end
            end

            STATE_DECIDE: begin // Make the final decision
                if (sad_accumulator > ROUTING_THRESHOLD_SAD) begin
                    oRouteToCnn <= 1'b1; // Complex tile -> route to CNN
                end else begin
                    oRouteToCnn <= 1'b0; // Simple tile -> route to SNN
                end
                
                oDecisionValid <= 1'b1; // Decision is valid for one cycle
                state          <= STATE_IDLE; // Go back to IDLE to wait for the next tile
            end
        endcase
    end
end

endmodule