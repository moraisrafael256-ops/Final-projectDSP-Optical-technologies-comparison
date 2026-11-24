function plot_dcf_limitations(delta_L_m, ber_matrix, SR_list, mod_type, snr_dB, target_ber)
% PLOT_DCF_LIMITATIONS Plot BER vs. delta_L [km] across baud rates (Task 3.3).
%
% Inputs:
%   delta_L_m  - Vector of fiber length offsets [m] (e.g., -4e3:100:4e3)
%   ber_matrix - Matrix of size [length(SR_list) x length(delta_L_m)]
%   SR_list    - Vector of symbol rates [Hz] (e.g., [50e9, 100e9, 200e9])
%   mod_type   - Modulation string ('QPSK' or '16QAM')
%   snr_dB     - Operating Eb/N0 [dB] chosen for target_ber at delta_L = 0
%   target_ber - Nominal BER at ideal compensation (e.g., 1e-3)

    styles = {'b-o', 'r-x', 'm-s', 'g-^'};
    delta_L_km = delta_L_m / 1e3;

    figure;
    hold on;
    leg = cell(1, length(SR_list) + 1);
    for r = 1:length(SR_list)
        st = styles{mod(r - 1, length(styles)) + 1};
        semilogy(delta_L_km, ber_matrix(r, :), st, 'LineWidth', 1.5, 'MarkerSize', 4);
        leg{r} = sprintf('S_R = %.0f Gbaud', SR_list(r) / 1e9);
    end

    % Nominal target BER reference line
    yline(target_ber, 'k--', 'LineWidth', 1.2);
    leg{end} = sprintf('Target BER = %.0e (\DeltaL = 0)', target_ber);

    set(gca, 'YScale', 'log');
    grid on;
    ylim([1e-4, 1]);
    xlabel('\DeltaL [km]  (L_1 = 20 km + \DeltaL)');
    ylabel('Bit Error Rate (BER)');
    title(sprintf('%s — Task 3.3 DCF Limitations (E_b/N_0 = %.2f dB)', mod_type, snr_dB));
    legend(leg, 'Location', 'south');
end
