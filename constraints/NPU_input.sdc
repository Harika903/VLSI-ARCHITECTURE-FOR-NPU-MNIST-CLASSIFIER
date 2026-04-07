create_clock -period 1 [get_ports clk]

set_input_delay -max 0.5 -clock clk [all_inputs]
set_input_transition 0.5 [all_inputs]

set_output_delay -max 0.5 -clock clk [all_outputs]


set_clock_uncertainty -setup 0.300 [get_clocks clk]
set_clock_uncertainty -hold 0.100 [get_clocks clk]
set_max_transition -clock_path 0.150 [get_clocks clk]
