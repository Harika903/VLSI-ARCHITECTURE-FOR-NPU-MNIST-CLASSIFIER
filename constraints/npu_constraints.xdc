# Clock constraint for NPU
create_clock -name npu_clk -period 10.0 [get_ports clk]
