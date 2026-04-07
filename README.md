# VLSI-ARCHITECTURE-FOR-NPU-MNIST-CLASSIFIER

# Project Overview
This project implements a Neural Processing Unit (NPU) using Verilog for MNIST digit classification. The design focuses on efficient computation using hardware modules.

# Modules
- NPU Core
- FSM (Finite State Machine)
- MAC (Multiply Accumulate Unit)
- FIFO
- Comparator
- PISO, ReLU, Output MUX

## Tools Used
- Verilog HDL
- Cadence (Simulation & Synthesis)

# Features
- Modular design approach
- Simulation and verification using testbenches
- Performance analysis (Area, Power, Timing)

# Project Structure
- `source/` → Design files  
- `testbench/` → Testbench files  
- `Netlisst/` → Synthesized netlists  
- `reports/` → Area, power, timing reports  
- `constraints/` → SDC/XDC constraint files  

# Outcome
Designed and validated an NPU architecture suitable for basic neural network inference tasks.
