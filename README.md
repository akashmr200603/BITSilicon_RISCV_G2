# 5-Stage Pipelined RISC-V Processor 🚀

![RISC-V](https://img.shields.io/badge/ISA-RISC--V-blue)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Language](https://img.shields.io/badge/Language-Verilog%20%2F%20SystemVerilog-brightgreen)

## 📌 Project Overview
This repository contains the RTL design, verification environment, and documentation for a 32-bit, 5-stage pipelined RISC-V processor (RV32I Base Integer Instruction Set). 

This project is built from scratch and aims to implement a fully functional pipeline with hazard detection.

## 🏗️ Architecture
The processor follows the classic 5-stage RISC pipeline architecture:

1. **Instruction Fetch (IF):** Fetches the next instruction from instruction memory and updates the Program Counter (PC).
2. **Instruction Decode (ID):** Decodes the fetched instruction, reads operands from the Register File, and generates control signals.
3. **Execute (EX):** Performs Arithmetic Logic Unit (ALU) operations and calculates branch addresses.
4. **Memory (MEM):** Handles Data Memory read/write operations for Load/Store instructions.
5. **Write Back (WB):** Writes ALU results or loaded memory data back to the Register File.

### Advanced Features
* **Hazard Unit:** Handles Read-After-Write (RAW), Write-After-Write (WAW), and Write-After-Read (WAR) hazards.
