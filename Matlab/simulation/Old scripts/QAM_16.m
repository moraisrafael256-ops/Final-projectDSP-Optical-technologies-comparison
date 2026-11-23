% System simulation parameters for 16-QAM[cite: 3]
N_bits = 4e5; % Total number of random bits (multiple of 4)[cite: 3]
N_symb = N_bits / 4; % Number of symbols (4 bits per 16-QAM symbol)[cite: 3]
SNR_dB = 0:1:10; % Vector of Signal-to-Noise Ratio (Eb/N0) in dB[cite: 3]
SNR_lin = 10.^(SNR_dB / 10); % Conversion from dB to linear scale[cite: 3]

% Preallocate arrays to store results[cite: 3]
simulated_BER = zeros(1, length(SNR_dB));
simulated_SER = zeros(1, length(SNR_dB));
simulated_BER_ssrc = zeros(1, length(SNR_dB)); % Added for SSRC
simulated_SER_ssrc = zeros(1, length(SNR_dB)); % Added for SSRC
theoretical_BER = zeros(1, length(SNR_dB));
theoretical_SER = zeros(1, length(SNR_dB));

for k = 1:length(SNR_dB)
    % 1. Generate bit stream for 4 bits per symbol[cite: 3]
    b1 = randi([0 1], 1, N_symb); 
    b2 = randi([0 1], 1, N_symb); 
    b3 = randi([0 1], 1, N_symb); 
    b4 = randi([0 1], 1, N_symb); 
    
    % 2. Symbol mapping with Gray coding (PAM-4 for I and Q)[cite: 3]
    I = zeros(1, N_symb);
    I(b1 == 0 & b2 == 0) = -3;
    I(b1 == 0 & b2 == 1) = -1;
    I(b1 == 1 & b2 == 1) =  1;
    I(b1 == 1 & b2 == 0) =  3;
    
    Q = zeros(1, N_symb);
    Q(b3 == 0 & b4 == 0) = -3;
    Q(b3 == 0 & b4 == 1) = -1;
    Q(b3 == 1 & b4 == 1) =  1;
    Q(b3 == 1 & b4 == 0) =  3;
    
    S_k = I + 1j * Q; 
    
    % 3. Add noise - AWGN channel[cite: 3]
    N0 = 2.5 / SNR_lin(k);
    
    % --- Discrete Channel ---
    n_k = sqrt(N0 / 2) * (randn(1, N_symb) + 1j * randn(1, N_symb)); 
    r_k = S_k + n_k; 
    r_I = real(r_k);
    r_Q = imag(r_k);
    
    % --- SSRC Continuous Channel ---
    r_k_ssrc = ssrc_awgn_channel(S_k, N0, true);
    r_I_ssrc = real(r_k_ssrc);
    r_Q_ssrc = imag(r_k_ssrc);
    
    % 4. Decision for I and Q (Discrete)[cite: 3]
    dec_I = -3 * ones(1, N_symb); dec_Q = -3 * ones(1, N_symb);
    dec_I(r_I >= -2) = -1; dec_I(r_I >= 0) = 1; dec_I(r_I >= 2) = 3; 
    dec_Q(r_Q >= -2) = -1; dec_Q(r_Q >= 0) = 1; dec_Q(r_Q >= 2) = 3;
    
    % 4b. Decision for I and Q (SSRC)
    dec_I_ssrc = -3 * ones(1, N_symb); dec_Q_ssrc = -3 * ones(1, N_symb);
    dec_I_ssrc(r_I_ssrc >= -2) = -1; dec_I_ssrc(r_I_ssrc >= 0) = 1; dec_I_ssrc(r_I_ssrc >= 2) = 3; 
    dec_Q_ssrc(r_Q_ssrc >= -2) = -1; dec_Q_ssrc(r_Q_ssrc >= 0) = 1; dec_Q_ssrc(r_Q_ssrc >= 2) = 3;
    
    % 5. Symbol to bit conversion (Discrete)[cite: 3]
    dec_b1 = (dec_I == 1 | dec_I == 3);
    dec_b2 = (dec_I == -1 | dec_I == 1);
    dec_b3 = (dec_Q == 1 | dec_Q == 3);
    dec_b4 = (dec_Q == -1 | dec_Q == 1);
    
    % 5b. Symbol to bit conversion (SSRC)
    dec_b1_ssrc = (dec_I_ssrc == 1 | dec_I_ssrc == 3);
    dec_b2_ssrc = (dec_I_ssrc == -1 | dec_I_ssrc == 1);
    dec_b3_ssrc = (dec_Q_ssrc == 1 | dec_Q_ssrc == 3);
    dec_b4_ssrc = (dec_Q_ssrc == -1 | dec_Q_ssrc == 1);
    
    % 6. Calculate SER and BER numerically (Discrete)[cite: 3]
    total_bit_errors = sum(b1 ~= dec_b1) + sum(b2 ~= dec_b2) + sum(b3 ~= dec_b3) + sum(b4 ~= dec_b4);
    simulated_BER(k) = total_bit_errors / (4 * N_symb); 
    simulated_SER(k) = sum((I ~= dec_I) | (Q ~= dec_Q)) / N_symb;
    
    % 6b. Calculate SER and BER numerically (SSRC)
    total_bit_errors_ssrc = sum(b1 ~= dec_b1_ssrc) + sum(b2 ~= dec_b2_ssrc) + sum(b3 ~= dec_b3_ssrc) + sum(b4 ~= dec_b4_ssrc);
    simulated_BER_ssrc(k) = total_bit_errors_ssrc / (4 * N_symb); 
    simulated_SER_ssrc(k) = sum((I ~= dec_I_ssrc) | (Q ~= dec_Q_ssrc)) / N_symb;
    
    % 7. Theoretical results for 16-QAM[cite: 3]
    P_sqrtM = 1.5 * qfunc(sqrt(0.8 * SNR_lin(k)));
    theoretical_SER(k) = 1 - (1 - P_sqrtM)^2;
    theoretical_BER(k) = theoretical_SER(k) / 4;
end

% Plot the graph - Compare BER and SER[cite: 3]
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
title('16-QAM Error Rates: Discrete vs SSRC vs Theory');
legend('Numeric BER (Discrete)', 'Numeric BER (SSRC)', 'Theory BER', ...
       'Numeric SER (Discrete)', 'Numeric SER (SSRC)', 'Theory SER');

% --- 16-QAM Constellation Diagram (SSRC Filtered at 15 dB) ---[cite: 3]
SNR_dB_plot = 15; 
SNR_lin_plot = 10^(SNR_dB_plot / 10);
N0_plot = 2.5 / SNR_lin_plot;

% Generate received signal after SSRC pulse shaping & matched filtering
r_k_plot_ssrc = ssrc_awgn_channel(S_k, N0_plot, true);

figure;
plot(real(r_k_plot_ssrc), imag(r_k_plot_ssrc), 'b.', 'MarkerSize', 2); 
hold on;
plot(real(S_k), imag(S_k), 'r*', 'MarkerSize', 8, 'LineWidth', 1.5); 
grid on;
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
title(['16-QAM Constellation Diagram with SSRC (SNR = ', num2str(SNR_dB_plot), ' dB)']);
legend('Received SSRC Symbols', 'Ideal Symbols');
axis([-5 5 -5 5]);