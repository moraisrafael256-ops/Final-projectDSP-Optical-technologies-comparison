%% Task 3.2 — Ideal DCF Optical Dispersion Compensation Wrapper
% Verifies perfect fit with theoretical BER/SER after ideal CD compensation
% (L1*D1 + L2*D2 = 0) for QPSK and 16QAM (Slides 12-13).

clear; clc; close all;
addpath('blocks');

%% 1. User Settings
mod_list           = {'QPSK', '16QAM'};  % Slide 12-13 required formats
N_symb             = 2e5;                % Increase to 1e6 for smoother 10 dB tails
SNR_dB             = 0:1:10;             % Eb/N0 sweep in dB
compare_uncomp     = true;               % Overlay uncompensated 20 km fiber
plot_constellation = true;               % Plot constellation before vs. after DCF
constellation_snr  = 15;                 % SNR [dB] for constellation snapshot

%% 2. Verify Ideal Dispersion Compensation Condition
cfg_check = get_system_config('QPSK', N_symb, 'dac_adc', true, true);
residual_ps_nm = (cfg_check.L1 / 1e3) * (cfg_check.D1 * 1e6) + ...
                 (cfg_check.L2 / 1e3) * (cfg_check.D2 * 1e6);
fprintf('Task 3.2 Parameters: L1 = %.1f km (D1 = %.1f ps/nm-km), L2 = %.1f km (D2 = %.1f ps/nm-km)\n', ...
    cfg_check.L1 / 1e3, cfg_check.D1 * 1e6, cfg_check.L2 / 1e3, cfg_check.D2 * 1e6);
fprintf('Residual dispersion L1*D1 + L2*D2 = %.4f ps/nm (ideal = 0)\n\n', residual_ps_nm);

%% 3. Run Sweep for Each Modulation Format
for m = 1:length(mod_list)
    mod_type = mod_list{m};
    cfg_dcf    = get_system_config(mod_type, N_symb, 'dac_adc', true, true);
    cfg_uncomp = get_system_config(mod_type, N_symb, 'dac_adc', true, false);

    num_snr        = length(SNR_dB);
    sim_BER_dcf    = zeros(1, num_snr);
    sim_SER_dcf    = zeros(1, num_snr);
    sim_BER_uncomp = zeros(1, num_snr);
    sim_SER_uncomp = zeros(1, num_snr);

    fprintf('Running %s (Fiber + Ideal DCF)...\n', cfg_dcf.mod_type);
    for k = 1:num_snr
        [sim_BER_dcf(k), sim_SER_dcf(k)] = comm_system(cfg_dcf, SNR_dB(k));
        if compare_uncomp
            [sim_BER_uncomp(k), sim_SER_uncomp(k)] = comm_system(cfg_uncomp, SNR_dB(k));
        end
    end

    [th_BER, th_SER] = calc_theory_ber_ser(SNR_dB, cfg_dcf.mod_type);

    if compare_uncomp
        plot_ber_results(SNR_dB, cfg_dcf, sim_BER_dcf, sim_SER_dcf, th_BER, th_SER, ...
            sim_BER_uncomp, sim_SER_uncomp);
    else
        plot_ber_results(SNR_dB, cfg_dcf, sim_BER_dcf, sim_SER_dcf, th_BER, th_SER);
    end

    % Constellation comparison: Uncompensated vs. Ideal DCF
    if plot_constellation && cfg_dcf.is_complex
        cfg_snap_uncomp = get_system_config(mod_type, min(N_symb, 2e4), 'dac_adc', true, false);
        cfg_snap_dcf    = get_system_config(mod_type, min(N_symb, 2e4), 'dac_adc', true, true);
        [~, ~, r_uncomp, S_uncomp] = comm_system(cfg_snap_uncomp, constellation_snr);
        [~, ~, r_dcf,    S_dcf]    = comm_system(cfg_snap_dcf,    constellation_snr);

        figure;
        subplot(1, 2, 1);
        plot(real(r_uncomp), imag(r_uncomp), 'b.', 'MarkerSize', 3); hold on;
        plot(real(S_uncomp), imag(S_uncomp), 'r*', 'MarkerSize', 8, 'LineWidth', 1.5);
        grid on; axis equal;
        xlabel('In-Phase (I)'); ylabel('Quadrature (Q)');
        title(sprintf('%s After 20 km Fiber (Uncompensated)', cfg_dcf.mod_type));

        subplot(1, 2, 2);
        plot(real(r_dcf), imag(r_dcf), 'b.', 'MarkerSize', 3); hold on;
        plot(real(S_dcf), imag(S_dcf), 'r*', 'MarkerSize', 8, 'LineWidth', 1.5);
        grid on; axis equal;
        xlabel('In-Phase (I)'); ylabel('Quadrature (Q)');
        title(sprintf('%s After Ideal DCF (SNR = %g dB)', cfg_dcf.mod_type, constellation_snr));
    end
end
