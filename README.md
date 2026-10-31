# Final-projectDSP-Optical-technologies-comparison
Master's thesis project simulating and comparing IM-DD (e.g., PAM-4) and Coherent optical technologies (e.g., 16-QAM) for high-speed, next-generation Data Center Interconnects (DCIs). Includes DSP algorithms, BER/SNR analysis, and performance benchmarking.
# IM-DD vs. Coherent Optical Technologies for Next-Generation Data Centers

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2023a-blue.svg)](https://www.mathworks.com/)

## Overview
This repository contains the simulation code, datasets, and documentation for my Final Master's Degree Project. The research focuses on evaluating and comparing two leading optical communication paradigms for Next-Generation Data Center Interconnects (DCIs):
1. **IM-DD (Intensity Modulation - Direct Detection):** Primarily focusing on PAM-4, which is currently the industry standard for short-reach, low-cost intra-datacenter links.
2. **Coherent Technologies:** Focusing on higher-order modulations (e.g., QPSK, 16-QAM) equipped with Digital Signal Processing (DSP), which are traditionally used in long-haul networks but are becoming increasingly relevant for short-reach DCIs due to growing bandwidth demands.

The project simulates physical layer models, applies DSP compensation algorithms, and extracts key performance metrics such as Bit Error Rate (BER), Symbol Error Rate (SER), and Error Vector Magnitude (EVM) under varying Signal-to-Noise Ratios (SNR).

## Key Features
* **Modulation Simulations:** Implementations of PAM-2, PAM-4, QPSK, and 16-QAM with Gray coding.
* **Channel Modeling:** AWGN channels, optical fiber impairments (Chromatic Dispersion, Phase Noise), and bandwidth limitations.
* **DSP Algorithms:** Transmitter and receiver-side DSP, including phase recovery and equalization.
* **Performance Analysis:** Scripts for plotting theoretical vs. empirical BER/SER curves and generating constellation diagrams.

## Repository Structure
```text
├── src/                  # Source code for simulations (MATLAB/Python)
│   ├── modulations/      # PAM-4, 16-QAM, QPSK generation and decoding
│   ├── channel_models/   # AWGN, Phase Noise, and Dispersion models
│   └── dsp/              # Digital Signal Processing algorithms
├── docs/                 # Project documentation, methodology, and the final thesis report (PDF)
├── results/              # Generated plots, BER/SER curves, and constellation diagrams
├── main_simulation.m     # Main entry script to run the comparative analysis
└── README.md             # Project overview and execution guide
