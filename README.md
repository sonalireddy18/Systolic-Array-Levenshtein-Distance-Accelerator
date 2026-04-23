# Systolic Array Levenshtein Distance Accelerator

A high-performance hardware accelerator for computing the **Levenshtein Distance** (Edit Distance) between strings using a **Systolic Array** architecture. This project is implemented in Verilog and verified against a Python-based Golden Model.

## Overview
The **Levenshtein Distance** is the minimum number of single-character edits (insertions, deletions, or substitutions) required to change one word into another. This project offloads the computationally expensive string-matching process from the CPU to a dedicated hardware accelerator.

By utilizing a **Systolic Array** of Processing Elements (PEs), the design achieves $O(N+M)$ throughput, providing a significant performance boost over traditional $O(N \times M)$ software implementations.

### The Algorithm
The core logic follows the Dynamic Programming approach, implemented at the RTL level:
$$d_{i,j} = \min(d_{i-1,j} + 1, d_{i,j-1} + 1, d_{i-1,j-1} + \text{cost})$$

## Architecture
The system consists of a chain of **Processing Elements (PEs)**. Each PE is responsible for a single character comparison, passing intermediate distances through pipeline registers to the next unit.

* **Systolic Data Flow:** Characters "pulse" through the array, allowing the hardware to work on multiple parts of the comparison simultaneously.
* **Pipeline Registers:** Strategic register placement breaks long combinational paths, allowing for high clock frequencies (critical for FPGA/ASIC targets).
* **FSM Controller:** A Finite State Machine manages the string input stream, handles boundary conditions, and flushes the pipeline to extract final results.



##  Project Structure
* `pe.v`: Fundamental Processing Element logic.
* `edit_distance_top.v`: Top-level module instantiating the PE array.
* `controller.v`: FSM for data flow control.
* `tb_edit_distance.v`: Testbench with 5 comprehensive test cases.
* `golden_model.py`: Reference implementation for RTL verification.

## 🛠️ Execution
### Prerequisites
* **Icarus Verilog** (Verilog Compiler)
* **Python 3.x**

### Compilation & Simulation
1. **Compile & Run Verilog:**
   ```bash
   iverilog -o sim.vvp pe.v edit_distance_top.v controller.v tb_edit_distance.v
   vvp sim.vvp
2. **Verify with Golden Model**
   ```bash
   python golden_model.py

##  Verification Results

The hardware accelerator was tested against the Python **Golden Model** using a variety of edge cases. All tests passed with 100% logic parity.

| Case | String A | String B | Expected Distance | Status |
| :--- | :--- | :--- | :---: | :--- |
| 1 | `KITT` | `SITT` | 1 |  PASS |
| 2 | `BOOK` | `BACK` | 2 |  PASS |
| 3 | `FAST` | `FAST` | 0 |  PASS |
| 4 | `CHAT` | `CATS` | 2 |  PASS |
| 5 | `COOL` | `POOL` | 1 |  PASS |

> **Note:** Simulations were performed using Icarus Verilog and timing was verified to be consistent with the $O(N+M)$ systolic array architecture.


## 👥 Team & Roles
| Member | Role | Responsibilities |
| :--- | :--- | :--- |
| **Harini** | Architect & PE Designer | Logic design for the core PE and cost calculation. |
| **Sonali** | System Integrator | PE array chaining and structural modeling. |
| **Vennela** | Controller & I/O | FSM implementation for timing and data alignment. |
| **Priyanka** | Verification Lead | Multi-case testbench and Python Golden Model verification. |  

## Academic Context
This project was developed as a final theory project for the **Computer Organization and Architecture (CS2007)** course at **Indian Institute of Information Technology Design and Manufacturing (IIITDM), Kancheepuram**.

