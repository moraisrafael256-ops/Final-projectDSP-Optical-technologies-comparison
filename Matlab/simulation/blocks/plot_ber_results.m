function plot_ber_results(SNR_dB, cfg, sim_BER_dcf, sim_SER_dcf, th_BER, th_SER, sim_BER_uncomp, sim_SER_uncomp)
% PLOT_BER_RESULTS Plot Task 3.2 (Fiber + Ideal DCF) vs. Uncompensated Fiber vs. Theory.

    has_uncomp = (nargin >= 8) && ~isempty(sim_BER_uncomp);
    is_pam2    = strcmpi(cfg.mod_type, 'PAM2');

    figure;
    semilogy(SNR_dB, sim_BER_dcf, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6); hold on;
    semilogy(SNR_dB, th_BER,      'k--', 'LineWidth', 1.5);
    leg = {'Numeric BER (Fiber + Ideal DCF)', 'Theory BER'};

    if has_uncomp
        semilogy(SNR_dB, sim_BER_uncomp, 'rx-', 'LineWidth', 1.5, 'MarkerSize', 7);
        leg{end+1} = 'Numeric BER (Uncompensated Fiber)';
    end

    if ~is_pam2
        semilogy(SNR_dB, sim_SER_dcf, 'cs-', 'LineWidth', 1.5, 'MarkerSize', 6);
        semilogy(SNR_dB, th_SER,      'g--', 'LineWidth', 1.5);
        leg = [leg, {'Numeric SER (Fiber + Ideal DCF)', 'Theory SER'}];
        if has_uncomp
            semilogy(SNR_dB, sim_SER_uncomp, 'm+-', 'LineWidth', 1.5, 'MarkerSize', 7);
            leg{end+1} = 'Numeric SER (Uncompensated Fiber)';
        end
    end

    grid on;
    xlabel('SNR (E_b / N_0) [dB]');
    ylabel('Error Rate');
    title(sprintf('%s Error Rates — Task 3.2 Ideal DCF (L_1=%.0f km, L_2=%.1f km, S_R=%.0f Gbaud)', ...
        cfg.mod_type, cfg.L1 / 1e3, cfg.L2 / 1e3, cfg.SR / 1e9));
    legend(leg, 'Location', 'southwest');
end
