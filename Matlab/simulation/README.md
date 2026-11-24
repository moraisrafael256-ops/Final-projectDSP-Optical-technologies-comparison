# Task 3.3 — Modular Communications System (DAC/ADC + Fiber + DCF Limitations)

Complete modular MATLAB simulation environment covering **Task 1, Task 2.1, Task 3.1, Task 3.2, and Task 3.3 (DCF Limitations, Slide 14)**.

## Quick Start
1. Open MATLAB and set your Current Folder to `task3_3_modular_comm_system/`.
2. **Task 3.3 (DCF Limitations — $\Delta L$ Sweep):** Run `run_task3_3_dcf_limitations.m`.
   - Automatically solves for the exact $E_b/N_0$ giving $\text{BER} = 10^{-3}$ at $\Delta L = 0$ for **QPSK** (~6.79 dB) and **16-QAM** (~10.52 dB).
   - Sweeps $L_1 = 20\text{ km} + \Delta L$ for $\Delta L = -4000 : 100 : 4000\text{ m}$ across **50, 100, and 200 Gbaud**.
   - Plots BER vs. $\Delta L$ bathtub curves for each modulation format.
3. **Task 3.2 (Ideal DCF BER vs. SNR):** Run `run_ber_wrapper.m`.

## New & Updated Files for Task 3.3
- `run_task3_3_dcf_limitations.m` — Top-level wrapper for the Slide 14 $\Delta L$ and baud-rate sweep.
- `blocks/find_snr_for_ber.m` — Solves `calc_theory_ber_ser(snr, mod_type) == target_ber` via `fzero`.
- `blocks/plot_dcf_limitations.m` — Plots BER vs. $\Delta L$ [km] for 50, 100, and 200 Gbaud on a log y-axis.
- `comm_system.m` — Computes `F_samp = cfg.sps_ch * cfg.SR` dynamically so sweeping `cfg.SR` stays in sync automatically.
