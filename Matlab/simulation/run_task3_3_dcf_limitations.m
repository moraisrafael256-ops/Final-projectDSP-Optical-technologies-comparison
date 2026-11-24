%% Task 3.3 — DCF Limitations Wrapper (Non-Ideal CD Compensation)
% Evaluates BER vs. fiber length mismatch delta_L = -4e3 : 100 : 4e3 [m]
% for QPSK and 16QAM at SR = 50, 100, and 200 Gbaud (Slide 14).

clear; clc; close all;
addpath('blocks');

%% 1. Simulation parameters
mod_list   = {'QPSK', '16QAM'};
SR_list    = [50e9, 100e9, 200e9];   % 50, 100, 200 Gbaud
delta_L    = -4e3 : 100 : 4e3;       % Length mismatch [m] (-4 km to +4 km)
L1_nom     = 20e3;                   % Nominal SMF length: 20 km [m]
target_ber = 1e-3;                   % Operating BER at delta_L = 0
N_symb     = 5e4;                    % 1e5 bits (QPSK) / 2e5 bits (16QAM) -> ~100-200 errors at 1e-3

%% 2. Sweep Modulations, Baud Rates, and delta_L
for m = 1:length(mod_list)
    mod_type = mod_list{m};
    snr_dB   = find_snr_for_ber(target_ber, mod_type);

    fprintf('=== %s: Operating Eb/N0 = %.2f dB (for BER = %.0e at delta_L = 0) ===\n', ...
        mod_type, snr_dB, target_ber);

    ber_matrix = zeros(length(SR_list), length(delta_L));

    for r = 1:length(SR_list)
        cfg      = get_system_config(mod_type, N_symb, 'dac_adc', true, true);
        cfg.SR   = SR_list(r);
        cfg.F_samp = cfg.sps_ch * cfg.SR;

        fprintf('  Simulating S_R = %.0f Gbaud (%d delta_L points)...\n', ...
            cfg.SR / 1e9, length(delta_L));

        for d = 1:length(delta_L)
            cfg.L1 = L1_nom + delta_L(d);
            ber_matrix(r, d) = comm_system(cfg, snr_dB);
        end
    end

    % Plot bathtub curves for this modulation format
    plot_dcf_limitations(delta_L, ber_matrix, SR_list, mod_type, snr_dB, target_ber);
end

fprintf('\nTask 3.3 sweep complete.\n');
