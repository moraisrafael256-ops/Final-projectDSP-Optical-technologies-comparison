% System simulation parameters for PAM-4[cite: 2]
N_bits = 1e6; % Total number of random bits[cite: 2]
N_symb = N_bits / 2; % Number of symbols (2 bits per PAM-4 symbol)[cite: 2]
SNR_dB = 0:1:10; % Vector of Signal-to-Noise Ratio (Eb/N0) in dB[cite: 2]
SNR_lin = 10.^(SNR_dB / 10); % Conversion from dB to linear scale[cite: 2]

% Preallocate arrays to store results[cite: 2]
simulated_BER = zeros(1, length(SNR_dB));
simulated_SER = zeros(1, length(SNR_dB));
simulated_BER_ssrc = zeros(1, length(SNR_dB)); % Added for SSRC
simulated_SER_ssrc = zeros(1, length(SNR_dB)); % Added for SSRC
theoretical_BER = zeros(1, length(SNR_dB));
theoretical_SER = zeros(1, length(SNR_dB));

for k = 1:length(SNR_dB)
    % 1. Generate bit stream[cite: 2]
    b1 = randi([0 1], 1, N_symb); 
    b2 = randi([0 1], 1, N_symb); 
    
    % 2. Symbol mapping with Gray coding (PAM-4)[cite: 2]
    S_k = zeros(1, N_symb);
    S_k(b1 == 0 & b2 == 0) = -3;
    S_k(b1 == 0 & b2 == 1) = -1;
    S_k(b1 == 1 & b2 == 1) =  1;
    S_k(b1 == 1 & b2 == 0) =  3;
    
    % 3. Add noise - AWGN channel[cite: 2]
    N0 = 2.5 / SNR_lin(k);
    
    % --- Discrete Channel ---
    n_k = sqrt(N0 / 2) * randn(1, N_symb); 
    r_k = S_k + n_k; 
    
    % --- SSRC Continuous Channel ---
    r_k_ssrc = ssrc_awgn_channel(S_k, N0, false);
    
    % 4. Decision according to the sliding thresholds (Discrete & SSRC)[cite: 2]
    dec_S = -3 * ones(1, N_symb);
    dec_S(r_k >= -2) = -1;
    dec_S(r_k >= 0)  =  1;
    dec_S(r_k >= 2)  =  3; 
    
    dec_S_ssrc = -3 * ones(1, N_symb);
    dec_S_ssrc(r_k_ssrc >= -2) = -1;
    dec_S_ssrc(r_k_ssrc >= 0)  =  1;
    dec_S_ssrc(r_k_ssrc >= 2)  =  3;
    
    % 5. Demapping back to bits (Discrete & SSRC)[cite: 2]
    dec_b1 = (dec_S == 1 | dec_S == 3);
    dec_b2 = (dec_S == -1 | dec_S == 1);
    
    dec_b1_ssrc = (dec_S_ssrc == 1 | dec_S_ssrc == 3);
    dec_b2_ssrc = (dec_S_ssrc == -1 | dec_S_ssrc == 1);
    
    % 6. Calculate BER and SER numerically[cite: 2]
    simulated_BER(k) = (sum(b1 ~= dec_b1) + sum(b2 ~= dec_b2)) / N_bits;
    simulated_SER(k) = sum(S_k ~= dec_S) / N_symb;
    
    simulated_BER_ssrc(k) = (sum(b1 ~= dec_b1_ssrc) + sum(b2 ~= dec_b2_ssrc)) / N_bits;
    simulated_SER_ssrc(k) = sum(S_k ~= dec_S_ssrc) / N_symb;
    
    % 7. Theoretical calculation for PAM-4[cite: 2]
    p_s = 1.5 * qfunc(sqrt(0.8 * SNR_lin(k)));
    theoretical_SER(k) = p_s;
    theoretical_BER(k) = p_s / 2;
end

% Plot the graph - Compare BER and SER[cite: 2]
figure;
semilogy(SNR_dB, simulated_BER, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
semilogy(SNR_dB, simulated_BER_ssrc, 'cx-', 'LineWidth', 1.5, 'MarkerSize', 8);
semilogy(SNR_dB, theoretical_BER, 'k--', 'LineWidth', 1.5);
semilogy(SNR_dB, simulated_SER, 'rs-', 'LineWidth', 1.5, 'MarkerSize', 6);
semilogy(SNR_dB, simulated_SER_ssrc, 'm+-', 'LineWidth', 1.5, 'MarkerSize', 8);
semilogy(SNR_dB, theoretical_SER, 'g--', 'LineWidth', 1.5);
grid on;
xlabel('SNR (E_b/N_0) [dB]');
ylabel('Error Rate');
title('PAM-4 Error Rates: Discrete vs SSRC vs Theory');
legend('Numeric BER (Discrete)', 'Numeric BER (SSRC)', 'Theory BER', ...
       'Numeric SER (Discrete)', 'Numeric SER (SSRC)', 'Theory SER');