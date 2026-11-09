% System simulation parameters for QPSK / 4-QAM[cite: 4]
N_bits = 1e6; % Total number of random bits[cite: 4]
N_symb = N_bits / 2; % Number of symbols (2 bits per QPSK symbol)[cite: 4]
SNR_dB = 0:1:10; % Vector of Signal-to-Noise Ratio values (Eb/N0) in dB[cite: 4]
SNR_lin = 10.^(SNR_dB / 10); % Conversion from dB to linear scale[cite: 4]

% Preallocate arrays to store results[cite: 4]
simulated_BER = zeros(1, length(SNR_dB));
simulated_SER = zeros(1, length(SNR_dB));
simulated_BER_ssrc = zeros(1, length(SNR_dB)); % Added for SSRC
simulated_SER_ssrc = zeros(1, length(SNR_dB)); % Added for SSRC
theoretical_BER = zeros(1, length(SNR_dB));
theoretical_SER = zeros(1, length(SNR_dB));

for k = 1:length(SNR_dB)
    % 1. Generate bit stream[cite: 4]
    b1 = randi([0 1], 1, N_symb); 
    b2 = randi([0 1], 1, N_symb); 
    
    % 2. Symbol mapping (QPSK / 4-QAM)[cite: 4]
    I = 2*b1 - 1; 
    Q = 2*b2 - 1; 
    S_k = I + 1j * Q; 
    
    % 3. Add noise - AWGN channel[cite: 4]
    N0 = 1 / SNR_lin(k);
    
    % --- Discrete Channel ---
    n_k = sqrt(N0 / 2) * (randn(1, N_symb) + 1j * randn(1, N_symb)); 
    r_k = S_k + n_k; 
    
    % --- SSRC Continuous Channel ---
    r_k_ssrc = ssrc_awgn_channel(S_k, N0, true);
    
    % 4. Decision (Discrete)[cite: 4]
    dec_b1 = real(r_k) > 0; 
    dec_b2 = imag(r_k) > 0; 
    
    % 4b. Decision (SSRC)
    dec_b1_ssrc = real(r_k_ssrc) > 0;
    dec_b2_ssrc = imag(r_k_ssrc) > 0;
    
    % 5. Calculate BER and SER numerically (Discrete)[cite: 4]
    err_b1 = (b1 ~= dec_b1);
    err_b2 = (b2 ~= dec_b2);
    simulated_BER(k) = (sum(err_b1) + sum(err_b2)) / N_bits;
    simulated_SER(k) = sum(err_b1 | err_b2) / N_symb;
    
    % 5b. Calculate BER and SER numerically (SSRC)
    err_b1_ssrc = (b1 ~= dec_b1_ssrc);
    err_b2_ssrc = (b2 ~= dec_b2_ssrc);
    simulated_BER_ssrc(k) = (sum(err_b1_ssrc) + sum(err_b2_ssrc)) / N_bits;
    simulated_SER_ssrc(k) = sum(err_b1_ssrc | err_b2_ssrc) / N_symb;
    
    % 6. Theoretical calculation[cite: 4]
    p_bit = qfunc(sqrt(2 * SNR_lin(k)));
    theoretical_BER(k) = p_bit;
    theoretical_SER(k) = 2*p_bit - p_bit^2;
end

% Plot the graph - Compare BER and SER[cite: 4]
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
title('QPSK (4-QAM) Error Rates: Discrete vs SSRC vs Theory');
legend('Numeric BER (Discrete)', 'Numeric BER (SSRC)', 'Theory BER', ...
       'Numeric SER (Discrete)', 'Numeric SER (SSRC)', 'Theory SER');