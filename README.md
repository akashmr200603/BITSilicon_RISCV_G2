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

## Repository Organization

- `design/rtl/` : Verilog/SystemVerilog RTL source files for the pipelined core
- `design/include/` : Common definitions/macros/header files
- `design/constraints/` : Synthesis/STA constraints
- `simulation/tb/` : Testbench and models
- `simulation/tests/` : Test cases (basic, hazard, branch/jump, memory)
- `simulation/scripts/` : Simulator run scripts
- `simulation/waves/` : Waveform dumps (VCD/FST)
- `simulation/results/` : Logs and simulation output
- `programs/` : Assembly and compiled binaries used by testbench
- `verification/` : Assertions, coverage, and reports
- `docs/` : Architecture and pipeline documentation

---

## How to Fork and Add Your Files

### 1) Fork this repository

1. Open: `https://github.com/akashmr200603/BITSilicon_RISCV_G2`
2. Click **Fork** (top-right)
3. Create the fork in your own GitHub account

### 2) Clone your fork locally

```bash
git clone https://github.com/<your-username>/BITSilicon_RISCV_G2.git
cd BITSilicon_RISCV_G2
```

### 3) Add upstream remote (recommended)

```bash
git remote add upstream https://github.com/akashmr200603/BITSilicon_RISCV_G2.git
git remote -v
```

### 4) Add files to the correct directories

- Put RTL files in `design/rtl/`
- Put include/header files in `design/include/`
- Put testbench files in `simulation/tb/`
- Put test programs in `simulation/tests/` or `programs/asm/`
- Put simulator scripts in `simulation/scripts/`
- Put generated waveforms/logs only if required (prefer ignoring large files)

### 5) Commit and push

```bash
git checkout -b feature/add-riscv-files
git add .
git commit -m "Add 5-stage RISC-V core design and simulation files"
git push origin feature/add-riscv-files
```

### 6) Open Pull Request

1. Go to your fork on GitHub
2. Click **Compare & pull request**
3. Set base repo: `akashmr200603/BITSilicon_RISCV_G2`
4. Submit PR with clear description of added modules/tests

---

## Suggested .gitignore

```gitignore
# Build artifacts
*.o
*.out
*.log
*.jou
*.pb

# Simulation outputs
*.vcd
*.fst
*.wlf
*.fsdb

# Temporary files
*.tmp
*.swp
.DS_Store

# Tool-generated directories
work/
transcript
simv*
csrc/
obj_dir/
```

---

## Contribution Checklist

- [ ] RTL compiles without errors
- [ ] Testbench runs basic instruction tests
- [ ] Hazard forwarding/stalling tested
- [ ] Branch/jump behavior validated
- [ ] README/docs updated for any new module
- [ ] PR includes simulation log summary
