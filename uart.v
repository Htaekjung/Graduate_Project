`timescale 1ns / 1ps

   module uart
	#(parameter DBIT=8,SB_TICK=16,DVSR=326,DVSR_WIDTH=9,FIFO_W=2) //DBIT=databits , SB_TICK=stop_bits tick(16 per bit) , DVSR= clk/(16*BaudRate) , DVSR_WIDTH=array size needed by DVSR,FIFO_WIDTH+fifo size(2^x) )
	(
	input clk,
	input rst_n,
	input rd_uart,
	input rx,
	output[7:0] rd_data,
	output rx_done
    );
	 
	 wire s_tick;

	baud_generator #(.N(DVSR),.N_width(DVSR_WIDTH)) m0
	(
	.clk(clk),
	.rst_n(rst_n),
	.s_tick(s_tick)
    );
	 
	 uart_rx #(.DBIT(DBIT),.SB_TICK(SB_TICK)) m1 //DBIT=data bits , SB_TICK=ticks for stop bit (16 for 1 bit ,32 for 2 bits)
	(
		.clk(clk),
		.rst_n(rst_n),
		.rx(rx),
		.s_tick(s_tick),
		.rx_done_tick(rx_done),
		.dout(rd_data)
    );

endmodule
