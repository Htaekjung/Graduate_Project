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

// Double Buffers for pipelining
reg [7:0]   tile_buffer_A [0:(TILE_WIDTH*TILE_WIDTH)-1];
reg [7:0]   tile_buffer_B [0:(TILE_WIDTH*TILE_WIDTH)-1];

// A single counter for driving both pipeline stages
reg [8:0]   pixel_count; // Counts from 0-255 and wraps around

// Buffer management
reg         write_to_A; // 1: Stage 1 writes to Buffer A, Stage 2 reads from B
                        // 0: Stage 1 writes to Buffer B, Stage 2 reads from A

// --- Stage 1: Summation Pipeline Registers --- //
reg [15:0]  s1_pixel_sum;

// --- Stage 2: SAD Calculation Pipeline Registers --- //
reg [15:0]  s2_pixel_sum_reg;
reg [7:0]   s2_tile_average;
reg [15:0]  s2_sad_accumulator;

// Wires for Stage 2 SAD calculation
wire [7:0]  s2_pixel_from_buffer;
wire [8:0]  s2_diff;
wire [7:0]  s2_abs_diff;

// Stage 2 reads from the buffer that Stage 1 is NOT writing to
assign s2_pixel_from_buffer = write_to_A ? tile_buffer_B[pixel_count] : tile_buffer_A[pixel_count];
assign s2_diff              = s2_pixel_from_buffer - s2_tile_average;
assign s2_abs_diff          = (s2_diff[8] == 1'b1) ? -s2_diff : s2_diff; // Absolute value

//--- Pipelined Logic ---//
always @(posedge iClk) begin
    if (!iRst) begin
        // Reset all registers
        pixel_count        <= 0;
        write_to_A         <= 1'b1;
        s1_pixel_sum       <= 0;
        s2_pixel_sum_reg   <= 0;
        s2_tile_average    <= 0;
        s2_sad_accumulator <= 0;
        oRouteToCnn        <= 1'b0;
        oDecisionValid     <= 1'b0;
    end else begin
        // Default output
        oDecisionValid <= 1'b0;

        if (iValid) begin
            // ========================================================== //
            // == STAGE 1: Sum incoming pixels and write to active buffer == //
            // ========================================================== //
            if (write_to_A) begin
                tile_buffer_A[pixel_count] <= iData;
            end else begin
                tile_buffer_B[pixel_count] <= iData;
            end
            s1_pixel_sum <= s1_pixel_sum + iData;


            // ============================================================ //
            // == STAGE 2: Read from inactive buffer and calculate SAD == //
            // ============================================================ //
            s2_sad_accumulator <= s2_sad_accumulator + s2_abs_diff;


            // ============================================================ //
            // ==           Control Logic & Pipeline Management          == //
            // ============================================================ //
            if (pixel_count == (TILE_WIDTH * TILE_WIDTH - 1)) begin
                // A full tile has been processed in both stages
                
                // 1. Final decision for the tile that just finished Stage 2
                if (s2_sad_accumulator > ROUTING_THRESHOLD_SAD) begin
                    oRouteToCnn <= 1'b1;
                end else begin
                    oRouteToCnn <= 1'b0;
                end
                oDecisionValid <= 1'b1;

                // 2. Pass Stage 1 result to Stage 2 for the NEXT tile
                s2_pixel_sum_reg <= s1_pixel_sum;
                s2_tile_average  <= s1_pixel_sum >> 8; // Avg for the tile that just finished Stage 1

                // 3. Reset accumulators for the NEXT tile
                s1_pixel_sum       <= 0;
                s2_sad_accumulator <= 0;
                
                // 4. Swap buffers for the NEXT tile
                write_to_A <= !write_to_A;
                
                // 5. Reset the shared counter
                pixel_count <= 0;
            end else begin
                // Continue processing the current tile
                pixel_count <= pixel_count + 1;
            end
        end
    end
end

endmodule