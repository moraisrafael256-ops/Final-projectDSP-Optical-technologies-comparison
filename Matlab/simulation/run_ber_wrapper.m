%% Task 2.1 — Modular BER/SER Simulation Wrapper (DAC & ADC)
% Run this script to sweep Eb/N0 and compare simulated BER/SER against theory.
% To switch systems, change mod_type below to 'PAM2', 'QPSK', 'PAM4', or '16QAM'.

clear; clc; close all;
addpath('blocks');

%% 1. User Settings
mod_type           = '16QAM';   % Options: 'PAM2', 'QPSK', 'PAM4', '16QAM'
N_symb             = 2e6;      % Number of symbols per SNR point
SNR_dB             = 0:1:10;   % Eb/N0 sweep in dB
compare_discrete   = true;     % Also simulate Task 1 discrete AWGN baseline
plot_constellation = true;     % Plot received constellation (for QPSK / 16QAM)
constellation_snr  = 15;       % SNR [dB] for constellation snapshot

%% 2. Build System Configurations
cfg_dac = get_system_config(mod_type, N_symb, 'dac_adc');
if compare_discrete
    cfg_disc = get_system_config(mod_type, N_symb, 'discrete');
end

%% 3. Run SNR Sweep
num_snr      = length(SNR_dB);
sim_BER_dac  = zeros(1, num_snr);
sim_SER_dac  = zeros(1, num_snr);
sim_BER_disc = zeros(1, num_snr);
sim_SER_disc = zeros(1, num_snr);

fprintf('Running %s simulation (%s pulse, N_symb = %g)...\n', ...
    cfg_dac.mod_type, upper(cfg_dac.pulse), cfg_dac.N_symb);

for k = 1:num_snr
    [sim_BER_dac(k), sim_SER_dac(k)] = comm_system(cfg_dac, SNR_dB(k));
    if compare_discrete
        [sim_BER_disc(k), sim_SER_disc(k)] = comm_system(cfg_disc, SNR_dB(k));
    end
end

%% 4. Theoretical Curves
[th_BER, th_SER] = calc_theory_ber_ser(SNR_dB, cfg_dac.mod_type);

%% 5. Plot BER & SER
if compare_discrete
    plot_ber_results(SNR_dB, cfg_dac, sim_BER_dac, sim_SER_dac, th_BER, th_SER, ...
        sim_BER_disc, sim_SER_disc);
else
    plot_ber_results(SNR_dB, cfg_dac, sim_BER_dac, sim_SER_dac, th_BER, th_SER);
end

%% 6. Optional Constellation Diagram (Complex Modulations)
if plot_constellation && cfg_dac.is_complex
    cfg_snap = get_system_config(mod_type, min(N_symb, 2e4), 'dac_adc');
    [~, ~, r_k_snap, S_k_snap] = comm_system(cfg_snap, constellation_snr);
    figure;
    plot(real(r_k_snap), imag(r_k_snap), 'b.', 'MarkerSize', 3); hold on;
    plot(real(S_k_snap), imag(S_k_snap), 'r*', 'MarkerSize', 9, 'LineWidth', 1.5);
    grid on; axis equal;
    xlabel('In-Phase (I)');
    ylabel('Quadrature (Q)');
    title(sprintf('%s Constellation (Task 2.1 DAC/ADC, E_b/N_0 = %g dB)', ...
        cfg_dac.mod_type, constellation_snr));
    legend('Received Symbols', 'Ideal Symbols');
end
