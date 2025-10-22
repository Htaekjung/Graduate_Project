module SNN_Core #(
    parameter IMAGE_WIDTH = 16 // ⭐ 수정: 타일 크기에 맞게 16으로 변경
) (
    // System Signals
    input  wire                 iClk,
    input  wire                 iRst,

    // Control Signals
    input  wire                 iStart,

    // Input Pixel Stream
    input  wire [7:0]           iData,
    input  wire                 iValid,

    // Output Result
    output wire [7:0]           oResult,
    output reg                 oValid
);

    //--- Parameters and Localparams ---//
    localparam IMAGE_WIDTH_LOG2 = $clog2(IMAGE_WIDTH);

    //--- Internal Registers and Wires ---//
    reg [7:0] line_buffer1 [0:IMAGE_WIDTH-1];
    reg [7:0] line_buffer2 [0:IMAGE_WIDTH-1];
    reg [16:0] valid_shifter;

    // ⭐ 수정: 열(x)과 행(y) 카운터
    reg [IMAGE_WIDTH_LOG2-1:0] wr_ptr;      // 열(Column) 카운터
    reg [IMAGE_WIDTH_LOG2-1:0] row_cnt;     // 행(Row) 카운터

    reg process_active;
    wire       valid_in = iValid && process_active;
    reg [7:0] window [0:2][0:2];
    
    // ⭐ 추가: 위치 정보 파이프라이닝을 위한 레지스터
    reg [IMAGE_WIDTH_LOG2-1:0] col_d1, col_d2, col_d3;
    reg [IMAGE_WIDTH_LOG2-1:0] row_d1, row_d2, row_d3;
    reg valid_d1, valid_d2, valid_d3;

    wire signed [13:0] Gx, Gy;
    wire [14:0] abs_Gx, abs_Gy;
    wire [14:0] magnitude;
    
    // ⭐ 추가: 최종 출력 시점의 가장자리 여부 판별 와이어
    wire is_border;

    //--- Line Buffer and Window Logic ---//
    integer i;
    always @(posedge iClk) begin
        if (!iRst) begin
            wr_ptr <= 0;
            row_cnt <= 0;
            process_active <= 1'b0;
        end else begin
            if (iStart) begin
                process_active <= 1'b1;
            end

            if (iValid && process_active) begin
                line_buffer1[wr_ptr] <= line_buffer2[wr_ptr];
                line_buffer2[wr_ptr] <= iData;

                // ⭐ 수정: 패딩 로직 제거, 단순 시프트로 3x3 윈도우 구성
                // Col 2 -> Col 1 -> Col 0 (새로운 데이터) 순으로 시프트
                for (i = 0; i < 3; i = i + 1) begin
                    window[i][2] <= window[i][1];
                    window[i][1] <= window[i][0];
                end
                
                // Col 0 (가장 오른쪽)에 새로운 픽셀 열 채우기
                window[0][0] <= line_buffer1[wr_ptr]; // 2줄 위
                window[1][0] <= line_buffer2[wr_ptr]; // 1줄 위
                window[2][0] <= iData;                // 현재 픽셀

                // --- 카운터 업데이트 ---
                if (wr_ptr == IMAGE_WIDTH - 1) begin
                    wr_ptr <= 0;
                    row_cnt <= row_cnt + 1; // 한 줄이 끝나면 행 카운터 증가
                end else begin
                    wr_ptr <= wr_ptr + 1;
                end
            end
        end
    end

    //--- Scharr Calculation (Shift-Add based) ---//
    // (이 부분은 수정 없음)
    wire signed [13:0] gx_pos, gx_neg, gy_pos, gy_neg;

    assign gx_pos = ((window[0][0] << 1) + window[0][0]) + ((window[1][0] << 3) + (window[1][0] << 1)) + ((window[2][0] << 1) + window[2][0]);
    assign gx_neg = ((window[0][2] << 1) + window[0][2]) + ((window[1][2] << 3) + (window[1][2] << 1)) + ((window[2][2] << 1) + window[2][2]);
    assign Gx = - gx_pos + gx_neg;

    assign gy_pos = ((window[0][2] << 1) + window[0][2]) + ((window[0][1] << 3) + (window[0][1] << 1)) + ((window[0][0] << 1) + window[0][0]);
    assign gy_neg = ((window[2][2] << 1) + window[2][2]) + ((window[2][1] << 3) + (window[2][1] << 1)) + ((window[2][0] << 1) + window[2][0]);
    assign Gy = - gy_pos + gy_neg;

    //--- Magnitude Calculation ---//
    // (이 부분은 수정 없음)
    assign abs_Gx = (Gx[13]) ? -Gx : Gx;
    assign abs_Gy = (Gy[13]) ? -Gy : Gy;
    assign magnitude = abs_Gx + abs_Gy;

    // ⭐ 추가: 가장자리 픽셀 판별 로직
    // 파이프라인 최종 단의 위치 정보로 가장자리인지 확인
    assign is_border = (row_d2 == 1) || (row_d2 == 0) || 
                       (row_d2 == 2 && col_d2 == 0) || (row_d2 == 2 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 3 && col_d2 == 0) || (row_d2 == 3 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 4 && col_d2 == 0) || (row_d2 == 4 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 5 && col_d2 == 0) || (row_d2 == 5 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 6 && col_d2 == 0) || (row_d2 == 6 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 7 && col_d2 == 0) || (row_d2 == 7 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 8 && col_d2 == 0) || (row_d2 == 8 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 9 && col_d2 == 0) || (row_d2 == 9 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 10 && col_d2 == 0) || (row_d2 == 10 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 11 && col_d2 == 0) || (row_d2 == 11 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 12 && col_d2 == 0) || (row_d2 == 12 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 13 && col_d2 == 0) || (row_d2 == 13 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 14 && col_d2 == 0) || (row_d2 == 14 && col_d2 == IMAGE_WIDTH - 1) ||
                       (row_d2 == 15 && col_d2 == 0) || (row_d2 == 15 && col_d2 == IMAGE_WIDTH - 1);

    //--- Output Logic ---//
    // ⭐ 수정: is_border 신호에 따라 출력을 0 또는 연산 결과로 결정
    assign oResult = (is_border) ? 8'd0 :
                     (magnitude > 255) ? 8'hFF : magnitude[7:0];

    // ⭐ 수정: oValid 생성 및 위치 정보 파이프라이닝
    always @(posedge iClk) begin
        if (!iRst) begin
            valid_d1 <= 1'b0;
            valid_d2 <= 1'b0;
            valid_d3 <= 1'b0;
            // 파이프라인 레지스터 초기화
            col_d1 <= 0; col_d2 <= 0; col_d3 <= 0;
            row_d1 <= 0; row_d2 <= 0; row_d3 <= 0;
        end else begin
            // 1단 파이프라인
            valid_d1 <= iValid && process_active;
            col_d1   <= wr_ptr;
            row_d1   <= row_cnt;
            
            // 2단 파이프라인
            valid_d2 <= valid_d1;
            col_d2   <= col_d1;
            row_d2   <= row_d1;

            // 3단 파이프라인
            valid_d3 <= valid_d2;
            col_d3   <= col_d2;
            row_d3   <= row_d2;
        end
    end
    

    always @(posedge iClk) begin
        if (!iRst) begin
            valid_shifter <= 17'b0;
            oValid        <= 1'b0;
        end else begin
            valid_shifter <= {valid_shifter[15:0], valid_in};
            oValid <= valid_shifter[16];
        end
    end


endmodule