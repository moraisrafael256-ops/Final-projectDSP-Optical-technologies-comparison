# Task 2.1 — Modular Communications System (DAC & ADC)

Modular MATLAB simulation environment for **Task 2.1 (DAC and ADC)** supporting `PAM2`, `QPSK`, `PAM4`, and `16QAM`.

## Quick Start
1. Open MATLAB and set your Current Folder to `task2_1_modular_comm_system/`.
2. Open `run_ber_wrapper.m`.
3. Set `mod_type` to `'QPSK'`, `'16QAM'`, `'PAM2'`, or `'PAM4'` and run the script.

## Architecture
- `run_ber_wrapper.m` — Top-level BER/SER sweep and plotting wrapper.
- `get_system_config.m` — Central configuration factory (automatically selects SSRC at SPS=2 for QPSK/16-QAM and NRZ at SPS=2 for PAM-2/PAM-4).
- `comm_system.m` — Step-by-step communications chain (TX -> DAC -> Channel -> ADC -> RX -> BER/SER). Includes a marked hook between `dac_resample` and `add_awgn_channel` for plugging in `fiber.m` and DCF in Tasks 3.1–3.3.
- `blocks/` — Independent function per signal-processing block:
  - `generate_bits.m`
  - `modulate_bits.m`
  - `tx_upsample.m`
  - `design_pulse_filter.m`
  - `pulse_filter.m`
  - `dac_resample.m`
  - `add_awgn_channel.m`
  - `adc_resample.m`
  - `rx_downsample.m`
  - `decide_symbols.m`
  - `demodulate_symbols.m`
  - `calc_ber_ser.m`
  - `calc_theory_ber_ser.m`
  - `plot_ber_results.m`
