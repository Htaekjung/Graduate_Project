`timescale 1ns / 1ps

module fifo #(
    // --- Parameters --- //
    // 이 값을 수정하여 FIFO의 데이터 너비와 깊이를 쉽게 변경할 수 있습니다.
    parameter DATA_WIDTH = 8,   // 데이터의 비트 수 (픽셀 데이터이므로 8)
    parameter DEPTH      = 256  // 저장할 데이터의 개수
) (
    // --- System Signals --- //
    input  wire                  clk,
    input  wire                  rst,

    // --- Write Port --- //
    input  wire                  wr_en,      // 쓰기 활성화 신호
    input  wire [DATA_WIDTH-1:0] wr_data,    // 쓸 데이터

    // --- Read Port --- //
    input  wire                  rd_en,      // 읽기 활성화 신호
    output reg  [DATA_WIDTH-1:0] rd_data,    // 읽은 데이터

    // --- Status Signals --- //
    output wire                  full,       // FIFO가 꽉 찼는지 여부
    output wire                  empty       // FIFO가 비어있는지 여부
);

    // 포인터의 비트 수를 깊이에 맞게 자동 계산
    localparam PTR_WIDTH = $clog2(DEPTH);

    // --- Internal Registers & Wires --- //
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];   // 데이터를 저장할 메모리 배열
    reg [PTR_WIDTH-1:0]  wr_ptr;            // 쓰기 위치를 가리키는 포인터
    reg [PTR_WIDTH-1:0]  rd_ptr;            // 읽기 위치를 가리키는 포인터
    reg [PTR_WIDTH:0]    count;             // FIFO에 저장된 데이터 개수를 세는 카운터

    // --- Status Logic --- //
    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    // --- Main Logic --- //
    always @(posedge clk) begin
        if (!rst) begin
            // 리셋: 모든 포인터, 카운터, 출력 데이터 초기화
            wr_ptr  <= 0;
            rd_ptr  <= 0;
            count   <= 0;
            rd_data <= 0;
        end else begin
            // --- Write Operation --- //
            // 쓰기 신호가 있고, FIFO가 꽉 차지 않았을 때
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr      <= wr_ptr + 1; // 다음 위치로 쓰기 포인터 이동
            end

            // --- Read Operation --- //
            // 읽기 신호가 있고, FIFO가 비어있지 않을 때
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr];
                rd_ptr  <= rd_ptr + 1; // 다음 위치로 읽기 포인터 이동
            end
        end
    end

    // --- Counter Logic --- //
    // 카운터는 읽기/쓰기 동작과 독립적으로 계산되어야 정확합니다.
    always @(posedge clk) begin
        if (!rst) begin
            count <= 0;
        end else begin
            // case문을 사용하여 4가지 상황을 명확하게 처리
            case ({wr_en && !full, rd_en && !empty})
                2'b00: count <= count;           // No operation
                2'b01: count <= count - 1;       // Read only
                2'b10: count <= count + 1;       // Write only
                2'b11: count <= count;           // Read and Write simultaneously
            endcase
        end
    end

endmodule