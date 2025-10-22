`timescale 1ns / 1ps

module tb_uart_10bytes;

    // DUT Parameters
    localparam DBIT       = 8;
    localparam DVSR       = 326; // Corresponds to ~9600 baud with 50MHz clk
    localparam FIFO_W     = 2;
    localparam CLK_PERIOD = 20; // 50MHz clock

    // Testbench signals
    reg                 clk;
    reg                 rst_n;
    reg                 rd_uart;
    reg                 rx;

    wire [DBIT-1:0]     rd_data;
    wire                rx_done;

    // --- Test Data and Counters ---
    reg [DBIT-1:0]      test_data [0:9];
    integer             rx_count = 0;
    integer             error_count = 0;

    // Instantiate the Unit Under Test (DUT)
    uart #(
        .DBIT(DBIT),
        .DVSR(DVSR),
        .FIFO_W(FIFO_W)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .rd_uart(rd_uart),
        .rx(rx),
        .rd_data(rd_data),
        .rx_done(rx_done)
    );

    // 1. Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 2. Test Data Initialization
    initial begin
        test_data[0] = 8'hAA;
        test_data[1] = 8'h55;
        test_data[2] = 8'h01;
        test_data[3] = 8'hF0;
        test_data[4] = 8'h0F;
        test_data[5] = 8'hDE;
        test_data[6] = 8'hAD;
        test_data[7] = 8'hBE;
        test_data[8] = 8'hEF;
        test_data[9] = 8'hC0;
    end
        integer i;
    // 3. Test Sequence
    initial begin

        $display("TB: Simulation Started.");
        
        // Reset sequence
        rst_n   = 1;
        rx      = 1; // UART idle is high
        rd_uart = 0;
        #100;
        rst_n   = 0;
        #100;
        rst_n   = 1;
        $display("TB: Reset complete.");

        #50000; // Wait a bit after reset

        // --- RX Test: 10바이트 연속 수신 테스트 ---
        $display("TB: Starting 10-byte RX test...");
        
        for (i = 0; i < 10; i = i + 1) begin
            $display("TB: Sending byte %d: 0x%h", i, test_data[i]);
            uart_send_byte(test_data[i]);
            #(10 * 16 * DVSR * CLK_PERIOD / 2);
        end
        
        $display("TB: All 10 bytes sent.");

        // 수신 완료 대기
        #(10 * 10 * 16 * DVSR * CLK_PERIOD);
        
        if (rx_count == 10 && error_count == 0) begin
            $display("TB: *** FINAL SUCCESS: All 10 bytes received correctly! ***");
        end else begin
            $display("TB: *** FINAL FAILURE: Received %d/10 bytes, %d errors. ***", rx_count, error_count);
        end

        $display("TB: Simulation Finished.");
        $finish;
    end

    // 4. Monitor for received data
    always @(posedge rx_done) begin
        $display("TB: rx_done pulse detected! (Byte %d)", rx_count);
        
        if (rx_count < 10) begin
            if (rd_data === test_data[rx_count]) begin
                $display("TB: SUCCESS! Byte %d: Received 0x%h (Expected 0x%h)",
                         rx_count, rd_data, test_data[rx_count]);
            end else begin
                $display("TB: FAILURE! Byte %d: Received 0x%h (Expected 0x%h)",
                         rx_count, rd_data, test_data[rx_count]);
                error_count = error_count + 1;
            end
            rx_count = rx_count + 1;
        end else begin
            $display("TB: WARNING! Received more than 10 bytes.");
            error_count = error_count + 1;
        end
    end
    
    // Task: Send a byte to RX line
    task uart_send_byte(input [DBIT-1:0] data);
        integer i;
        localparam integer BIT_TIME = 16 * DVSR * CLK_PERIOD;
    begin
        rx <= 0; // Start Bit
        #(BIT_TIME);
        for (i = 0; i < DBIT; i = i + 1) begin
            rx <= data[i];
            #(BIT_TIME);
        end
        rx <= 1; // Stop Bit
        #(BIT_TIME);
    end
    endtask

endmodule
