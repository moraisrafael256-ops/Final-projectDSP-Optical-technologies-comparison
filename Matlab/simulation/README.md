# Task 3.2 — Modular Communications System with Ideal DCF Compensation

Extends the Task 3.1 optical fiber model to include **Task 3.2 (Dispersion Compensating Fiber — DCF, Slides 12–13)** satisfying $L_1 D_1 + L_2 D_2 = 0$.

## Quick Start
1. Open MATLAB and set your Current Folder to `task3_2_modular_comm_system/`.
2. Run `run_ber_wrapper.m`.
   - Runs **QPSK** and **16QAM** by default (as requested on Slides 12–13).
   - Verifies $L_1 D_1 + L_2 D_2 = 0$ ($L_1 = 20\text{ km}, D_1 = 17\text{ ps/(nm}\cdot\text{km)}, L_2 = 3.4\text{ km}, D_2 = -100\text{ ps/(nm}\cdot\text{km)}$).
   - Plots BER/SER (Fiber + Ideal DCF vs. Uncompensated Fiber vs. Theory) and side-by-side constellations (Uncompensated vs. DCF-compensated).

## What Changed from Task 3.1
- `get_system_config.m` — Added `enable_dcf`, `D2 = -100e-6` [s/m^2], and `L2 = 3.4e3` [m].
- `comm_system.m` — Reuses `fiber(s_t, f, cfg.D2, cfg.lambda, cfg.L2)` immediately after the SMF span when `cfg.enable_dcf` is `true`.
- `run_ber_wrapper.m` — Loops over `mod_list = {'QPSK', '16QAM'}` and compares Fiber + DCF against Uncompensated Fiber and Theory.
- `blocks/plot_ber_results.m` — Updated titles and legends for Task 3.2 DCF comparison.
