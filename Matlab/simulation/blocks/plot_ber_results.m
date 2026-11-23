function plot_ber_results(SNR_dB, cfg, sim_BER_dac, sim_SER_dac, th_BER, th_SER, sim_BER_disc, sim_SER_disc)
% PLOT_BER_RESULTS Plot simulated BER/SER curves against theoretical curves.

    has_disc = (nargin >= 8) && ~isempty(sim_BER_disc);
    is_pam2  = strcmpi(cfg.mod_type, 'PAM2');

    figure;
    semilogy(SNR_dB, sim_BER_dac, 'rx-', 'LineWidth', 1.5, 'MarkerSize', 8); hold on;
    semilogy(SNR_dB, th_BER,      'k--', 'LineWidth', 1.5);
    leg = {'Numeric BER (Task 2.1 DAC/ADC)', 'Theory BER'};

    if has_disc
        semilogy(SNR_dB, sim_BER_disc, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
        leg{end+1} = 'Numeric BER (Discrete)';
    end

    if ~is_pam2
        semilogy(SNR_dB, sim_SER_dac, 'm+-', 'LineWidth', 1.5, 'MarkerSize', 8);
        semilogy(SNR_dB, th_SER,      'g--', 'LineWidth', 1.5);
        leg = [leg, {'Numeric SER (Task 2.1 DAC/ADC)', 'Theory SER'}];
        if has_disc
            semilogy(SNR_dB, sim_SER_disc, 'cs-', 'LineWidth', 1.5, 'MarkerSize', 6);
            leg{end+1} = 'Numeric SER (Discrete)';
        end
    end

    grid on;
    xlabel('SNR (E_b / N_0) [dB]');
    ylabel('Error Rate');
    title(sprintf('%s Error Rates — Task 2.1 DAC/ADC (%s, SPS 2 \\rightarrow 8 \\rightarrow 2)', ...
        cfg.mod_type, upper(cfg.pulse)));
    legend(leg, 'Location', 'southwest');
end
