
module Bram_interface#(
    parameter RAM_WIDTH = 8,                       
    parameter RAM_DEPTH = 10240,                     
    parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", 
    parameter INIT_FILE = "",
    parameter IMG_WIDTH   = 640, // 전체 이미지의 가로 크기
    parameter IMG_HEIGHT  = 480,
    parameter TILE_WIDTH  = 16,  // 타일의 가로 크기
    parameter TILE_HEIGHT = 16  // 타일의 세로 크기                       
) (
    input iClk,
    input iRst,
    input [7:0] iData,
    output done_sig,
    output [7:0] oData
);
localparam NUM_TILES_X = IMG_WIDTH / TILE_WIDTH;   // 40 (가로 타일 개수)
localparam NUM_TILES_Y = IMG_HEIGHT / TILE_HEIGHT; // 30 (세로 타일 개수)


    // 타일 내에서의 위치를 추적하기 위한 카운터 레지스터
    // --- 레지스터 정의 ---
    // 타일 내부 픽셀 위치 카운터 (0~15)
    reg [3:0] tile_row_cnt;
    reg [3:0] tile_col_cnt;

    // 현재 읽고 있는 타일의 위치 카운터 (⭐새로 추가됨)
    reg [5:0] tile_x_cnt; // 가로 타일 위치 (0 ~ 39)
    reg [4:0] tile_y_cnt; // 세로 타일 위치 (0 ~ 29)
    reg [18:0] addra;
    reg [18:0] addrb;
    wire [RAM_WIDTH-1:0] dina;
    wire rsta, rstb;
    wire clka, clkb;
    reg ena, enb;
    reg regceb;
    wire [7:0] doutb;

    assign clkb = iClk;
    assign clka = iClk;
    assign rsta = iRst;
    assign rstb = iRst;
    assign dina = iData;

    localparam IDLE  = 3'b000; // 초기 대기 상태
    localparam WRITE = 3'b001; // Port A로 데이터를 쓰는 상태
    localparam DELAY = 3'b010;
    localparam READ  = 3'b011; // Port B로 데이터를 읽는 상태
    localparam DONE  = 3'b100; // 모든 작업이 끝난 상태

    reg [2:0] state, next_state;
    reg delay_done;

    always @(posedge iClk or negedge iRst) begin
        if (!iRst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    always @(*) begin
        case (state) 
            IDLE:  next_state = WRITE;
            WRITE: 
                next_state = (addra == RAM_DEPTH-1) ? DELAY : WRITE;
            DELAY :
                next_state = (delay_done == 1'b1) ? READ : DELAY;
            READ: 
                next_state = (addrb == RAM_DEPTH+1) ? DONE : READ;
            DONE: 
                next_state = DONE;
            default: 
                next_state = IDLE;
        endcase
    end
    always @(posedge iClk) begin
        if (!iRst) begin
            regceb = 1'b0;
            enb = 1'b0;
        end else if (next_state == DELAY && state == DELAY) begin
            regceb = 1'b1;
            enb = 1'b1;
        end
    end

always @(posedge iClk) begin
    if (!iRst) begin
        // 리셋: 모든 주소와 카운터 초기화
        addra <= 0;
        addrb <= 0;
        ena   <= 1'b1;
        tile_row_cnt <= 0;
        tile_col_cnt <= 0;
        tile_x_cnt   <= 0;
        tile_y_cnt   <= 0;
    end else if (state == WRITE) begin
        // 쓰기 상태 로직 (기존과 동일)
        ena   <= 1'b1;
        addra <= addra + 1;
    end else if (state == DELAY) begin
        // DELAY: READ 시작 전 모든 카운터 초기화 (⭐타일 카운터 초기화 추가)
        ena <= 1'b0;
        tile_row_cnt <= 0;
        tile_col_cnt <= 0;
        tile_x_cnt   <= 0;
        tile_y_cnt   <= 0;
    end else if (state == READ) begin
        // --- 여기가 수정된 핵심 로직입니다 ---

        // 1. 주소 계산: 4개의 카운터를 모두 사용하여 현재 읽어야 할 픽셀의 절대 주소 계산
        addrb <= ((tile_y_cnt * TILE_HEIGHT) + tile_row_cnt) * IMG_WIDTH + 
                 ((tile_x_cnt * TILE_WIDTH) + tile_col_cnt);

        // 2. 계층적 카운터 업데이트
        // 가장 안쪽 카운터(tile_col_cnt)부터 1씩 증가시키고,
        // 최대값에 도달하면 상위 카운터를 증가시키는 방식
        if (tile_col_cnt == TILE_WIDTH - 1) begin
            tile_col_cnt <= 0; // 열 카운터 리셋
            if (tile_row_cnt == TILE_HEIGHT - 1) begin
                tile_row_cnt <= 0; // 행 카운터 리셋 (타일 하나 완료)
                
                // 다음 타일로 이동
                if (tile_x_cnt == NUM_TILES_X - 1) begin
                    tile_x_cnt <= 0; // 가로 타일 카운터 리셋
                    if (tile_y_cnt == NUM_TILES_Y - 1) begin
                        tile_y_cnt <= 0; // 모든 타일 완료 -> 다음 동작을 위해 리셋
                    end else begin
                        tile_y_cnt <= tile_y_cnt + 1; // 다음 타일 줄로 이동
                    end
                end else begin
                    tile_x_cnt <= tile_x_cnt + 1; // 다음 가로 타일로 이동
                end
            end else begin
                tile_row_cnt <= tile_row_cnt + 1; // 타일 내 다음 행으로 이동
            end
        end else begin
            tile_col_cnt <= tile_col_cnt + 1; // 타일 내 다음 열로 이동
        end
    end else if (state == DONE) begin
        // DONE 상태 로직 (필요시 구현)
    end else begin
        // 기타 상태
    end
end

    Bram #(
    .RAM_WIDTH(RAM_WIDTH),
    .RAM_DEPTH(RAM_DEPTH),
    .RAM_PERFORMANCE(RAM_PERFORMANCE),
    .INIT_FILE(INIT_FILE)
    ) DUT (
    .addra(addra),
    .addrb(addrb),
    .dina(dina),
    .dinb(),
    .clka(clka),
    .clkb(clkb),
    .wea(1'b1),
    .web(1'b0),
    .ena(ena),
    .enb(enb),
    .rsta(rsta),
    .rstb(rstb),
    .regcea(1'b0),
    .regceb(regceb),
    .douta(),
    .doutb(doutb)
    );

    always @(posedge iClk) begin
        if(!iRst) begin
            delay_done = 1'b0;
        end else if(state == DELAY) begin
            delay_done = delay_done + 1;
        
        end
    end

    assign oData = doutb;
    assign done_sig = (1 < addrb && addrb < RAM_DEPTH+2 ) ? 1'b1 : 1'b0;
endmodule
