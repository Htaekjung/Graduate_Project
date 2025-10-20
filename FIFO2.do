onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 30 BRAM
add wave -noupdate /tb_Topmodule/DUT/bram/iClk
add wave -noupdate /tb_Topmodule/DUT/bram/iRst
add wave -noupdate /tb_Topmodule/DUT/bram/iData
add wave -noupdate /tb_Topmodule/DUT/bram/oDone_sig
add wave -noupdate /tb_Topmodule/DUT/bram/oData
add wave -noupdate /tb_Topmodule/DUT/bram/enb
add wave -noupdate /tb_Topmodule/DUT/bram/tile_row_cnt
add wave -noupdate /tb_Topmodule/DUT/bram/tile_col_cnt
add wave -noupdate /tb_Topmodule/DUT/bram/tile_x_cnt
add wave -noupdate /tb_Topmodule/DUT/bram/tile_y_cnt
add wave -noupdate /tb_Topmodule/DUT/bram/addra
add wave -noupdate /tb_Topmodule/DUT/bram/addrb
add wave -noupdate /tb_Topmodule/DUT/bram/dina
add wave -noupdate /tb_Topmodule/DUT/bram/rsta
add wave -noupdate /tb_Topmodule/DUT/bram/rstb
add wave -noupdate /tb_Topmodule/DUT/bram/clka
add wave -noupdate /tb_Topmodule/DUT/bram/clkb
add wave -noupdate /tb_Topmodule/DUT/bram/ena
add wave -noupdate /tb_Topmodule/DUT/bram/regceb
add wave -noupdate /tb_Topmodule/DUT/bram/doutb
add wave -noupdate /tb_Topmodule/DUT/bram/state
add wave -noupdate /tb_Topmodule/DUT/bram/next_state
add wave -noupdate /tb_Topmodule/DUT/bram/delay_done
add wave -noupdate -divider -height 30 FIFO_1
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/iClk
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/iRst
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/state
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/next_state
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/addr_cnt
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/ping_reg
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/read_buffer_valid
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_bram_fifo_1/addra
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_bram_fifo_1/addrb
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/wea
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/ena
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/enb
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_bram_fifo_1/doutb
add wave -noupdate -divider FIFO1_Result
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/iStart
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_bram_fifo_1/iData
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_1/oDone
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_bram_fifo_1/oData
add wave -noupdate -divider -height 30 FIFO_2
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/iClk
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/iRst
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/state
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/next_state
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/addr_cnt
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/ping_reg
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/read_buffer_valid
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/addra
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/addrb
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/wea
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/ena
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/enb
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_bram_fifo_2/doutb
add wave -noupdate -divider FIFO2_Result
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/iStart
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_bram_fifo_2/iData
add wave -noupdate /tb_Topmodule/DUT/u_bram_fifo_2/oDone
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_bram_fifo_2/oData
add wave -noupdate -divider -height 30 WA
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/iClk
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/iRst
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/workload_allocator_sad/iData
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/iValid
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/oDecisionValid
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/pixel_count
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/write_to_A
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/workload_allocator_sad/s1_pixel_sum
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/workload_allocator_sad/s2_tile_average
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/workload_allocator_sad/s2_diff
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/workload_allocator_sad/s2_abs_diff
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/tile_is_done
add wave -noupdate -divider -height 30 WA_result
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/workload_allocator_sad/s2_sad_accumulator
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/workload_allocator_sad/s2_pixel_from_buffer
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/oRouteToCnn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12361847 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 368
configure wave -valuecolwidth 140
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {12222007 ps} {12816994 ps}
