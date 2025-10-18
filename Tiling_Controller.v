module Tiling_Controller #(
    parameter IMAGE_WIDTH = 640,
    parameter IMAGE_HEIGHT = 480,
    parameter TILE_SIZE = 16
)(
    input iClk,
    input iRst,
    input iStart, // 타일링 시작 신호
    input [7:0] i_bram_data,
    // BRAM 인터페이스 포트
    output reg [18:0] o_bram_addr,
    // 출력 타일 데이터 포트
    output reg [7:0] o_tile_data,
    output reg o_tile_data_valid
);

    // --- FSM States ---
    localparam S_IDLE = 2'b00;
    localparam S_READ_TILE = 2'b01;
    localparam S_NEXT_TILE = 2'b10;
    localparam S_DONE = 2'b11;

    reg [1:0] state, next_state;

    // --- 4개의 중첩 카운터 ---
    reg [5:0] tile_x_counter; // 0-39
    reg [4:0] tile_y_counter; // 0-29
    reg [3:0] pixel_x_counter; // 0-15
    reg [3:0] pixel_y_counter; // 0-15

    // 현재 픽셀의 전체 이미지 기준 좌표
    wire [9:0] global_x = (tile_x_counter * TILE_SIZE) + pixel_x_counter;
    wire [8:0] global_y = (tile_y_counter * TILE_SIZE) + pixel_y_counter;

    // --- FSM ---
    always @(posedge iClk or negedge iRst) begin
        if (!iRst) state <= S_IDLE;
        else       state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case(state)
            S_IDLE: if (iStart) next_state = S_READ_TILE;
            S_READ_TILE:
                // 타일 하나(256픽셀)를 모두 읽으면 다음 타일 준비 상태로
                if (pixel_x_counter == TILE_SIZE-1 && pixel_y_counter == TILE_SIZE-1)
                    next_state = S_NEXT_TILE;
            S_NEXT_TILE:
                // 모든 타일을 다 읽었으면 DONE, 아니면 다시 READ
                if (tile_x_counter == (IMAGE_WIDTH/TILE_SIZE)-1 && tile_y_counter == (IMAGE_HEIGHT/TILE_SIZE)-1)
                    next_state = S_DONE;
                else
                    next_state = S_READ_TILE;
            S_DONE: next_state = S_IDLE;
        endcase
    end
    
    // --- 카운터 및 데이터패스 로직 ---
    always @(posedge iClk or negedge iRst) begin
        if(!iRst) begin
            tile_x_counter <= 0;
            tile_y_counter <= 0;
            pixel_x_counter <= 0;
            pixel_y_counter <= 0;
            o_bram_addr <= 0;
            o_tile_data <= 0;
            o_tile_data_valid <= 0;
        end else begin
            // BRAM 읽기 지연시간(1클럭)을 고려하여
            // 주소 계산은 현재, 데이터 출력은 다음 사이클에 유효
            o_tile_data <= i_bram_data; 
            o_tile_data_valid <= (state == S_READ_TILE);

            case(state)
                S_IDLE: begin
                    tile_x_counter <= 0;
                    tile_y_counter <= 0;
                end
                
                S_READ_TILE: begin
                    // BRAM 주소 계산 및 출력
                    o_bram_addr <= (global_y * IMAGE_WIDTH) + global_x;
                    
                    // 픽셀 카운터 증가 (x부터, y 순서로)
                    if (pixel_x_counter == TILE_SIZE - 1) begin
                        pixel_x_counter <= 0;
                        pixel_y_counter <= pixel_y_counter + 1;
                    end else begin
                        pixel_x_counter <= pixel_x_counter + 1;
                    end
                end

                S_NEXT_TILE: begin
                    // 픽셀 카운터 리셋
                    pixel_x_counter <= 0;
                    pixel_y_counter <= 0;
                    
                    // 타일 카운터 증가 (x부터, y 순서로)
                    if (tile_x_counter == (IMAGE_WIDTH / TILE_SIZE) - 1) begin
                        tile_x_counter <= 0;
                        tile_y_counter <= tile_y_counter + 1;
                    end else begin
                        tile_x_counter <= tile_x_counter + 1;
                    end
                end
            endcase
        end
    end
endmodule
