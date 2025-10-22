`timescale 1ns / 1ps

module tb_Top_module;

    localparam CLK_PERIOD = 20;  // 50MHz
    localparam DVSR = 326;       // Baud rate divisor
    localparam DBIT = 8;
    localparam IMAGE_SIZE = 256; // 307200 → 100개로 변경

    reg iClk;
    reg iRst;
    reg rd_uart;
    reg rx;
    wire [7:0] oData;

    // DUT 인스턴스
    Top_module DUT (
        .iClk(iClk),
        .iRst(iRst),
        .rd_uart(rd_uart),
        .rx(rx),
        .oData(oData)
    );

    // --- Clock generation ---
    initial begin
        iClk = 0;
        forever #(CLK_PERIOD/2) iClk = ~iClk;
    end

    integer i;
    reg [DBIT-1:0] data_to_send;

    // --- Main Test Sequence ---
    initial begin
        $display("TB: ========================================================");
        $display("TB:           UART RX Testbench (Send 1~100 HEX)           ");
        $display("TB: ========================================================");

        // 초기화
        iRst = 1'b0;
        rx = 1'b1;
        rd_uart = 1'b0;
        #100;
        iRst = 1'b1;
        $display("TB: [%0t ns] Reset complete", $time);

        // 잠시 대기
        #(50000);

        $display("TB: [%0t ns] Starting RX test (%d bytes)...", $time, IMAGE_SIZE);

        // 1~100 전송
        for (i = 1; i <= IMAGE_SIZE; i = i + 1) begin
            data_to_send = i[DBIT-1:0]; // i 값을 8비트로 변환
            $display("TB: [%0t ns] Sending byte %0d (data: 0x%02h)", $time, i, data_to_send);
            uart_send_byte(data_to_send);
        end

        $display("TB: [%0t ns] All bytes sent.", $time);
        #10_000_000;
        $display("TB: [%0t ns] Final oData = 0x%h", $time, oData);
        $finish;
    end

    // --- UART Byte 송신 Task ---
    task uart_send_byte;
        input [DBIT-1:0] data;
        integer j;
        localparam integer BIT_TIME_NS = 16 * DVSR * (CLK_PERIOD/2) * 2; // 1 bit duration
        begin
            // Start bit
            rx <= 1'b0;
            #(BIT_TIME_NS);

            // 데이터 비트 (LSB부터)
            for (j = 0; j < DBIT; j = j + 1) begin
                rx <= data[j];
                #(BIT_TIME_NS);
            end

            // Stop bit
            rx <= 1'b1;
            #(BIT_TIME_NS);
        end
    endtask

endmodule




// `timescale 1ns / 1ps

// module tb_Topmodule;

//     localparam RAM_DEPTH = 307200;
//     // localparam RAM_DEPTH = 307200; // 최종 검증 시에만 사용하세요.

//     localparam RAM_WIDTH = 8;
//     localparam CLK_PERIOD = 10;
    
//     // ⭐ 수정: 파이프라인 지연 시간 파라미터 추가
//     // 이 값은 Top_module의 전체 지연 시간보다 길게 설정해야 합니다.
//     // 예: Bram_Tiling Latency + 2*FIFO Latency + Sobel Core Latency
//     localparam PIPELINE_LATENCY = 537; 

//     // --- DUT Inputs ---
//     reg iClk;
//     reg iRst;
//     reg [RAM_WIDTH-1:0] iData;

//     // --- DUT Outputs ---
//     wire [RAM_WIDTH-1:0] oData;
    
//     // --- Testbench Internal Signals ---
//     reg [RAM_WIDTH-1:0] image_data_from_file [0:RAM_DEPTH-1];
//     integer i; // 루프 카운터
    
//     // ⭐ 수정: 파일 핸들러 및 에러 카운터 선언
//     integer result_file;
//     integer error_count = 0;

//     // --- DUT Instantiation ---
//     Top_module 
//     DUT (
//         .iClk(iClk),
//         .iRst(iRst),
//         .iData(iData),
//         .oData(oData)
//     );
    
//     // --- Clock Generation ---
//     always #((CLK_PERIOD)/2) iClk = ~iClk;
    
//     // --- Main Test Sequence ---
//     initial begin
//         // 1. Initialize signals
//         $display("INFO: Starting Simulation with RAM_DEPTH = %0d", RAM_DEPTH);
//         iClk = 0;
//         iRst = 0; // Active-Low 리셋 활성화
//         iData = 0;

//         // 2. Load image data and open result file
//         $readmemh("trump_original.txt", image_data_from_file);
//         $display("INFO: image.txt loaded into testbench memory.");
        
//         // ⭐ 수정: 결과 저장을 위한 txt 파일 열기
//         result_file = $fopen("result.txt", "w");
//         if (result_file == 0) begin
//             $display("ERROR: Could not open result.txt for writing.");
//             $stop;
//         end
        
//         // 3. Reset sequence
//         #95;
//         iRst = 1; // 리셋 해제
//         $display("INFO: Reset released. DUT should start processing.");
        
//         // 4. Provide input data from memory
//         for (i = 0; i < RAM_DEPTH; i = i + 1) begin
//             @(posedge iClk);
//             iData <= image_data_from_file[i];
//         end
        
//         @(posedge iClk);
//         iData <= 0; // 데이터 공급 완료 후 입력 0으로 유지
//         $display("INFO: Finished providing all %0d bytes of image data.", RAM_DEPTH);

//         // 5. Wait for the pipeline to fill
//         $display("INFO: Waiting for %0d cycles for pipeline latency...", PIPELINE_LATENCY);
//          repeat (PIPELINE_LATENCY) @(posedge iClk);

//         // 6. ⭐ 수정: Capture output data and write to file
//         $display("INFO: Capturing %0d bytes of output data to result.txt...", RAM_DEPTH);
//         for (i = 0; i < RAM_DEPTH; i = i + 1) begin
//             @(posedge iClk);
//             $fdisplayh(result_file, oData);
//         end
        
//         // 7. Clean up and finish
//         $fclose(result_file); // 파일 닫기
//         $display("INFO: Simulation Finished. Results are in result.txt");
//         $stop;
//     end

// endmodule
