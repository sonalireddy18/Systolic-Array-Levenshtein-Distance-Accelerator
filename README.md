# Systolic Array Levenshtein Distance Accelerator

A high-performance hardware accelerator for computing the **Levenshtein Distance** (Edit Distance) between strings using a **Systolic Array** architecture. This project is implemented in Verilog and verified against a Python-based Golden Model.

---

## Overview

The **Levenshtein Distance** is the minimum number of single-character edits (insertions, deletions, or substitutions) required to transform one string into another.

This project accelerates the computationally expensive string-matching process using a dedicated hardware architecture instead of a traditional sequential CPU implementation.

By exploiting **spatial parallelism** through a systolic array architecture, the design enables pipelined computation with significantly improved throughput and reduced effective processing latency compared to software-based Dynamic Programming implementations.

---

## The Algorithm

The accelerator implements the standard Dynamic Programming recurrence relation for Edit Distance computation:

\[
d_{i,j} = \min(d_{i-1,j} + 1,\ d_{i,j-1} + 1,\ d_{i-1,j-1} + \text{cost})
\]

where:

- **Insertion**  → \(d_{i,j-1} + 1\)
- **Deletion** → \(d_{i-1,j} + 1\)
- **Substitution** → \(d_{i-1,j-1} + \text{cost}\)

and:

- `cost = 0` if characters match
- `cost = 1` otherwise

---

## Architecture

The system consists of a chain of **Processing Elements (PEs)** organized as a **Systolic Array**.

Each Processing Element computes one Dynamic Programming cell update per cycle using local neighbor dependencies:
- top
- left
- diagonal

while forwarding intermediate values to adjacent PEs.

### Systolic Data Flow

```text
char_a --> [PE0] --> [PE1] --> [PE2] --> [PE3]
              |        |        |        |
             'S'      'I'      'T'      'T'
```

### Key Design Features

* **Systolic Parallelism**  
  Multiple DP-cell computations occur simultaneously through pipelined data propagation.

* **Pipeline Registers**  
  Registers inside Processing Elements reduce long combinational paths and improve timing performance for FPGA/ASIC implementations.

* **FSM-Based Controller**  
  A dedicated controller streams characters, initializes DP boundary conditions, and flushes the pipeline to obtain the final result.

* **Parameterized Design**  
  The accelerator is scalable and can support different string lengths by modifying the `LENGTH` parameter.

---

## Project Structure

| File | Description |
|---|---|
| `pe.v` | Processing Element implementation |
| `edit_distance_top.v` | Top-level systolic array module |
| `controller.v` | FSM controller for data streaming |
| `tb_edit_distance.v` | Comprehensive Verilog testbench |
| `golden_model.py` | Python reference implementation |

---

## Execution

### Prerequisites

* **Icarus Verilog**
* **Python 3.x**

---

## Compilation & Simulation

### 1. Compile and Run Verilog Simulation

```bash
iverilog -o sim.vvp pe.v edit_distance_top.v controller.v tb_edit_distance.v
vvp sim.vvp
```

### 2. Verify with Python Golden Model

```bash
python golden_model.py
```

---

## Verification Results

The hardware accelerator was verified against the Python Golden Model using multiple test cases.

All tests passed successfully with complete logic parity.

| Case | String A | String B | Expected Distance | Status |
| :--- | :--- | :--- | :---: | :--- |
| 1 | `KITT` | `SITT` | 1 | PASS |
| 2 | `BOOK` | `BACK` | 2 | PASS |
| 3 | `FAST` | `FAST` | 0 | PASS |
| 4 | `CHAT` | `CATS` | 2 | PASS |
| 5 | `COOL` | `POOL` | 1 | PASS |

> Simulations were performed using Icarus Verilog, and timing behavior was verified to be consistent with the pipelined systolic-array architecture.

---

## Output Screenshot

![Output](output%20screenshot.png)



---

## Academic Context

This project was developed as a final theory project for the **Computer Organization and Architecture (CS2007)** course at the **Indian Institute of Information Technology Design and Manufacturing (IIITDM), Kancheepuram**.
