`timescale 1ns / 1ps

module WorkloadAllocator (
    // System Signals
    input  wire         iClk,
    input  wire         iRst,

    // Input Pixel Stream
    input  wire [7:0]   iPixelData, // 8-bit grayscale pixel
    input  wire         iPixelValid, // Input pixel is valid

    // Output Decision
    output reg          oRouteToCnn, // 1: Route to CNN, 0: Route to SNN
    output reg          oDecisionValid // Routing decision is valid for one cycle
);

//--- Parameters ---//
parameter TILE_WIDTH        = 16;
parameter IMG_WIDTH         = 640; // Needed for line buffer size
parameter EDGE_THRESHOLD    = 50;  // Gradient magnitude threshold to be an "edge"
parameter ROUTING_THRESHOLD = 64;  // If edge_count > 64, it's a complex tile (25% density)

//--- Registers & Wires ---//
// Line Buffers to create a 3x3 window
reg  [7:0] line_buffer1 [0:IMG_WIDTH-1];
reg  [7:0] line_buffer2 [0:IMG_WIDTH-1];

// 3x3 Pixel Window Registers
reg  [7:0] p_win [0:2][0:2];

// Counters
reg  [8:0] pixel_count;      // Counts pixels within a tile (0-255)
reg  [8:0] edge_pixel_count; // Counts edge pixels within a tile

// Sobel Operator intermediate values
wire [9:0] grad_x;
wire [9:0] grad_y;
wire [9:0] grad_mag;

//--- Logic ---//

// 1. Line Buffer and 3x3 Window Generation
// This block creates a sliding 3x3 window from the input pixel stream
always @(posedge iClk) begin
    if (iRst) begin
        // Reset logic if needed
    end else if (iPixelValid) begin
        // Shift values through the 3x3 window registers
        // Row 0 (from line_buffer2)
        p_win[0][0] <= p_win[0][1];
        p_win[0][1] <= p_win[0][2];
        p_win[0][2] <= line_buffer2[pixel_count % IMG_WIDTH];

        // Row 1 (from line_buffer1)
        p_win[1][0] <= p_win[1][1];
        p_win[1][1] <= p_win[1][2];
        p_win[1][2] <= line_buffer1[pixel_count % IMG_WIDTH];

        // Row 2 (from input stream)
        p_win[2][0] <= p_win[2][1];
        p_win[2][1] <= p_win[2][2];
        p_win[2][2] <= iPixelData;

        // Update line buffers
        line_buffer2[pixel_count % IMG_WIDTH] <= line_buffer1[pixel_count % IMG_WIDTH];
        line_buffer1[pixel_count % IMG_WIDTH] <= iPixelData;
    end
end

// 2. Sobel Operator (Hardware-Friendly)
// Calculates Gx, Gy, and approximates magnitude as |Gx| + |Gy|
assign grad_x = (p_win[0][2] - p_win[0][0]) + ((p_win[1][2] - p_win[1][0]) << 1) + (p_win[2][2] - p_win[2][0]);
assign grad_y = (p_win[2][0] - p_win[0][0]) + ((p_win[2][1] - p_win[0][1]) << 1) + (p_win[2][2] - p_win[0][2]);

// Using conditional operator for absolute value
assign grad_mag = (grad_x > 0 ? grad_x : -grad_x) + (grad_y > 0 ? grad_y : -grad_y);


// 3. Counter and Decision Logic
always @(posedge iClk) begin
    if (iRst) begin
        pixel_count      <= 0;
        edge_pixel_count <= 0;
        oRouteToCnn      <= 1'b0;
        oDecisionValid   <= 1'b0;
    end else begin
        // Default: decision is not valid
        oDecisionValid <= 1'b0;

        if (iPixelValid) begin
            // ---- Tile Processing ---- //
            if (pixel_count == (TILE_WIDTH * TILE_WIDTH - 1)) begin
                // This is the LAST pixel of the current tile
                // Final decision for the completed tile
                if (edge_pixel_count > ROUTING_THRESHOLD) begin
                    oRouteToCnn <= 1'b1; // Complex tile -> route to CNN
                end else begin
                    oRouteToCnn <= 1'b0; // Simple tile -> route to SNN
                end
                
                oDecisionValid <= 1'b1; // The decision is valid for this one clock cycle
                
                // Reset counters for the next tile
                pixel_count      <= 0;
                edge_pixel_count <= 0;

            end else begin
                // This is an ONGOING pixel in the current tile
                // Increment pixel counter
                pixel_count <= pixel_count + 1;
                
                // Accumulate edge pixel count
                if (grad_mag > EDGE_THRESHOLD) begin
                    edge_pixel_count <= edge_pixel_count + 1;
                end
            end
        end
    end
end

endmodule