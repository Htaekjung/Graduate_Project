// module CNN_Core #(
//     parameter IMAGE_WIDTH = 256
// ) (
//     // System Signals
//     input  wire                 iClk,
//     input  wire                 iRst,

//     // Control Signals
//     input  wire                 iStart,

//     // Input Pixel Stream
//     input  wire [7:0]           iData,
//     input  wire                 iValid,

//     // Output Result
//     output wire [7:0]           oResult,
//     output reg                  oValid
// );
//     //--- Parameters and Localparams ---//
//     localparam IMAGE_WIDTH_LOG2 = $clog2(IMAGE_WIDTH);
//     // ⭐ 중요: Pre-pipeline(3) + Sqrt IP Latency(12) + Post-pipeline(1)
//     // IP 설정 창에서 확인한 Latency 값으로 수정해야 합니다. (여기서는 12로 가정)
//     localparam PRE_PIPE_STAGES = 3;
//     localparam IP_LATENCY      = 29;
//     localparam POST_PIPE_STAGES= 1;
//     localparam TOTAL_LATENCY   = PRE_PIPE_STAGES + IP_LATENCY + POST_PIPE_STAGES; // 총 16

//     //--- Internal Registers and Wires ---//
//     reg [7:0] line_buffer1 [0:IMAGE_WIDTH-1];
//     reg [7:0] line_buffer2 [0:IMAGE_WIDTH-1];
//     reg [IMAGE_WIDTH_LOG2-1:0] wr_ptr;
//     reg [IMAGE_WIDTH_LOG2-1:0] row_cnt;
//     reg [7:0] window [0:2][0:2];
//     integer i;
    
//     reg process_active;
//     wire valid_in = iValid && process_active;
    
//     // --- 계산 파이프라인 레지스터 ---
//     reg  signed [13:0] Gx_d1, Gy_d1;
//     reg  signed [27:0] Gx_sq_d2, Gy_sq_d2;
//     reg  signed [28:0] sum_sq_d3;
//     reg  [TOTAL_LATENCY-1:0] valid_shifter; // 전체 지연 시간에 맞춘 시프트 레지스터
    
//     // --- IP 연결을 위한 Wires ---
//     wire ip_in_valid;
//     wire [31:0] ip_in_data; // IP 데이터 폭에 맞게 수정 필요
//     wire ip_out_valid;
//     wire [31:0] ip_out_data;  // IP 데이터 폭에 맞게 수정 필요
//     reg  [15:0] magnitude;    // 최종 결과 저장 레지스터

//     //--- Line Buffer and Window Logic ---//
//     always @(posedge iClk) begin
//         if (!iRst) begin
//             wr_ptr <= 0;
//             row_cnt <= 0;
//             process_active <= 1'b0;
//             // 시뮬레이션 명확성을 위한 초기화
//             for (i = 0; i < IMAGE_WIDTH; i = i + 1) begin
//                 line_buffer1[i] <= 0;
//                 line_buffer2[i] <= 0;
//             end
//             for (i = 0; i < 3; i = i + 1) begin
//                 window[i][0] <= 0;
//                 window[i][1] <= 0;
//                 window[i][2] <= 0;
//             end
//         end else begin
//             if (iStart) begin
//                 process_active <= 1'b1;
//             end
            
//             if (valid_in) begin
//                 line_buffer1[wr_ptr] <= line_buffer2[wr_ptr];
//                 line_buffer2[wr_ptr] <= iData;

//                 for (i = 0; i < 3; i = i + 1) begin
//                     window[i][2] <= window[i][1];
//                     window[i][1] <= window[i][0];
//                 end
                
//                 window[0][0] <= line_buffer1[wr_ptr];
//                 window[1][0] <= line_buffer2[wr_ptr];
//                 window[2][0] <= iData;

//                 if (wr_ptr == IMAGE_WIDTH - 1) begin
//                     wr_ptr <= 0;
//                     row_cnt <= row_cnt + 1;
//                 end else begin
//                     wr_ptr <= wr_ptr + 1;
//                 end
//             end
//         end
//     end

//     //--- Scharr Calculation (DSP-based) ---//
//     wire signed [13:0] Gx_calc, Gy_calc;
//     assign Gx_calc = ((window[0][2] * 3) + (window[1][2] * 10) + (window[2][2] * 3)) -
//                      ((window[0][0] * 3) + (window[1][0] * 10) + (window[2][0] * 3));
//     assign Gy_calc = ((window[0][0] * 3) + (window[0][1] * 10) + (window[0][2] * 3)) -
//                      ((window[2][0] * 3) + (window[2][1] * 10) + (window[2][2] * 3));

//     //--- Magnitude Calculation Pipeline (IP 사용) ---//
//     always @(posedge iClk) begin
//         if (!iRst) begin
//             Gx_d1 <= 0; Gy_d1 <= 0;
//             Gx_sq_d2 <= 0; Gy_sq_d2 <= 0;
//             sum_sq_d3 <= 0;
//         end else if (valid_in) begin
//             // Stage 1: Gx, Gy 레지스터링
//             Gx_d1 <= Gx_calc;
//             Gy_d1 <= Gy_calc;
            
//             // Stage 2: 제곱
//             Gx_sq_d2 <= Gx_d1 * Gx_d1;
//             Gy_sq_d2 <= Gy_d1 * Gy_d1;
             
//             // Stage 3: 합산
//             sum_sq_d3 <= Gx_sq_d2 + Gy_sq_d2;
//         end
//     end
    
//     // IP의 입력 신호 준비
//     assign ip_in_valid = valid_shifter[PRE_PIPE_STAGES-1]; // 3클럭 지연된 valid 신호
//     assign ip_in_data  = {3'b0, sum_sq_d3}; // 32비트로 폭 확장

//     // ⭐--- Floating-Point Operator (sqrt) IP 인스턴스화 ---⭐
//     // IP 생성 시 인스턴스 이름과 포트 폭은 달라질 수 있습니다.
//     floating_point_0 u_sqrt_ip (
//       .aclk(iClk),
//       .aresetn(~iRst), // Active-low 리셋으로 변경
      
//       // Input Channel
//       .s_axis_a_tvalid(ip_in_valid),
//       .s_axis_a_tdata(ip_in_data),
//       .s_axis_a_tready(), // Backpressure 사용 안 하므로 open
      
//       // Output Channel
//       .m_axis_result_tvalid(ip_out_valid),
//       .m_axis_result_tdata(ip_out_data),
//       .m_axis_result_tready(1'b1) // 항상 받을 준비 완료
//     );

//     // IP 출력 결과 레지스터링 (Post-pipeline stage)
//     always @(posedge iClk) begin
//         if (ip_out_valid) begin
//             magnitude <= ip_out_data[15:0]; // 필요한 비트만 사용
//         end
//     end

//     //--- Output Logic ---//
//     assign oResult = (magnitude > 255) ? 8'hFF : magnitude[7:0];

//     // oValid 생성
//     always @(posedge iClk) begin
//         if (!iRst) begin
//             valid_shifter <= 0;
//             oValid        <= 1'b0;
//         end else begin
//             valid_shifter <= {valid_shifter[TOTAL_LATENCY-2:0], valid_in};
//             oValid        <= valid_shifter[TOTAL_LATENCY-1];
//         end
//     end
// endmodule


module CNN_Core #(
    parameter IMAGE_WIDTH = 16
) (
    // System Signals
    input  wire                    iClk,
    input  wire                    iRst,

    // Control Signals
    input  wire                    iStart, // 연산 시작을 알리는 신호 (Enable)

    // Input Pixel Stream
    input  wire [7:0]              iData,
    input  wire                    iValid, // iData가 유효함을 알리는 신호

    // Output Result
    output wire [7:0]              oResult, // 엣지 검출 결과 (Magnitude)
    output reg                    oValid   // oResult가 유효함을 알리는 신호
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

    //--- Scharr Calculation (DSP-based) ---//
    assign Gx = ((window[0][2] * 3) + (window[1][2] * 10) + (window[2][2] * 3)) -
                ((window[0][0] * 3) + (window[1][0] * 10) + (window[2][0] * 3));
    assign Gy = ((window[0][0] * 3) + (window[0][1] * 10) + (window[0][2] * 3)) -
                ((window[2][0] * 3) + (window[2][1] * 10) + (window[2][2] * 3));

    //--- Magnitude Calculation ---//
    assign abs_Gx = (Gx[13]) ? -Gx : Gx;
    assign abs_Gy = (Gy[13]) ? -Gy : Gy;
    assign magnitude = abs_Gx + abs_Gy;

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
    assign oResult = (is_border) ? 8'd0 :
                     (magnitude > 255) ? 8'hFF : magnitude[7:0];
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