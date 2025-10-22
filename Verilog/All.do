onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 30 {Top module}
add wave -noupdate /tb_Topmodule/DUT/iClk
add wave -noupdate /tb_Topmodule/DUT/iRst
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/iData
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/oData
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/wData_T2WF
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/wData_T2T
add wave -noupdate /tb_Topmodule/DUT/data_out
add wave -noupdate /tb_Topmodule/DUT/done_sig
add wave -noupdate /tb_Topmodule/DUT/done_1
add wave -noupdate /tb_Topmodule/DUT/done_2
add wave -noupdate /tb_Topmodule/DUT/wValid
add wave -noupdate /tb_Topmodule/DUT/counter
add wave -noupdate /tb_Topmodule/DUT/oRouteToCnn
add wave -noupdate /tb_Topmodule/DUT/oDecisionValid
add wave -noupdate /tb_Topmodule/DUT/r_Valid
add wave -noupdate /tb_Topmodule/DUT/oSNN_Result
add wave -noupdate /tb_Topmodule/DUT/oCNN_Result
add wave -noupdate /tb_Topmodule/DUT/oSNN_Valid
add wave -noupdate /tb_Topmodule/DUT/oCNN_Valid
add wave -noupdate /tb_Topmodule/DUT/Core_Valid
add wave -noupdate /tb_Topmodule/DUT/oDecisionValid_d1
add wave -noupdate /tb_Topmodule/DUT/oDecisionValid_d2
add wave -noupdate /tb_Topmodule/DUT/done_2_d1
add wave -noupdate /tb_Topmodule/DUT/done_2_d2
add wave -noupdate /tb_Topmodule/DUT/done_2_d3
add wave -noupdate /tb_Topmodule/DUT/wSNN_Valid
add wave -noupdate /tb_Topmodule/DUT/oRouteToCNN_d1
add wave -noupdate /tb_Topmodule/DUT/oRouteToCNN_d2
add wave -noupdate -divider -height 30 BRAM
add wave -noupdate /tb_Topmodule/DUT/bram/iClk
add wave -noupdate /tb_Topmodule/DUT/bram/iRst
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/bram/iData
add wave -noupdate /tb_Topmodule/DUT/bram/oDone_sig
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/bram/oData
add wave -noupdate /tb_Topmodule/DUT/bram/enb
add wave -noupdate /tb_Topmodule/DUT/bram/tile_row_cnt
add wave -noupdate /tb_Topmodule/DUT/bram/tile_col_cnt
add wave -noupdate /tb_Topmodule/DUT/bram/tile_x_cnt
add wave -noupdate /tb_Topmodule/DUT/bram/tile_y_cnt
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/bram/addra
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
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_bram_fifo_1/addr_cnt
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
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_bram_fifo_2/addra
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_bram_fifo_2/addrb
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
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/workload_allocator_sad/pixel_count
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
add wave -noupdate /tb_Topmodule/DUT/workload_allocator_sad/oDecisionValid
add wave -noupdate -divider -height 30 CNN
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/iStart
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/iValid
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/process_active
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_CNN_Core/wr_ptr
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/iStart
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/iValid
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/process_active
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_SNN_Core/wr_ptr
add wave -noupdate -divider -height 30 CNN
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/iClk
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/iRst
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/i
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_CNN_Core/wr_ptr
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/valid_d1
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/valid_d2
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/valid_d3
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_CNN_Core/line_buffer1
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_CNN_Core/line_buffer2
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/Gx
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/Gy
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/abs_Gx
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/abs_Gy
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/magnitude
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_CNN_Core/oResult
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/iData
add wave -noupdate /tb_Topmodule/DUT/u_CNN_Core/oValid
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/oValid
add wave -noupdate -divider -height 30 SNN
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_SNN_Core/line_buffer1
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_SNN_Core/line_buffer2
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/iClk
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/iRst
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_SNN_Core/iData
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/valid_d1
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/valid_d2
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/valid_d3
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/Gx
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/Gy
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/abs_Gx
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/abs_Gy
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/i
add wave -noupdate /tb_Topmodule/DUT/u_SNN_Core/magnitude
add wave -noupdate -radix unsigned /tb_Topmodule/DUT/u_SNN_Core/wr_ptr
add wave -noupdate -radix hexadecimal -childformat {{{/tb_Topmodule/DUT/u_SNN_Core/window[0]} -radix hexadecimal} {{/tb_Topmodule/DUT/u_SNN_Core/window[1]} -radix hexadecimal} {{/tb_Topmodule/DUT/u_SNN_Core/window[2]} -radix hexadecimal}} -expand -subitemconfig {{/tb_Topmodule/DUT/u_SNN_Core/window[0]} {-height 15 -radix hexadecimal} {/tb_Topmodule/DUT/u_SNN_Core/window[1]} {-height 15 -radix hexadecimal} {/tb_Topmodule/DUT/u_SNN_Core/window[2]} {-height 15 -radix hexadecimal}} /tb_Topmodule/DUT/u_SNN_Core/window
add wave -noupdate -radix hexadecimal /tb_Topmodule/DUT/u_SNN_Core/oResult
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3076699245 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 382
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
WaveRestoreZoom {3075554871 ps} {3078972802 ps}
