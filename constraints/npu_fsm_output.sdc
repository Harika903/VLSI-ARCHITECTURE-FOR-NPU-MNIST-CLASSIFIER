# ####################################################################

#  Created by Genus(TM) Synthesis Solution 20.11-s111_1 on Sat Feb 28 15:17:08 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design npu_fsm

create_clock -name "clk" -period 1.0 -waveform {0.0 0.5} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports rst]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports start]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports fifo_full]
set_input_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports EN_COMP]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports EN_BUF_IN]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports EN_MAC]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports EN_ReLU]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports LATCH_RELU]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports FIFO_WR_EN]
set_output_delay -clock [get_clocks clk] -add_delay -max 0.5 [get_ports done]
set_max_transition -clock_path 0.15 [get_clocks clk]
set_input_transition 0.5 [get_ports clk]
set_input_transition 0.5 [get_ports rst]
set_input_transition 0.5 [get_ports start]
set_input_transition 0.5 [get_ports fifo_full]
set_input_transition 0.5 [get_ports EN_COMP]
set_clock_uncertainty -setup 0.3 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]
