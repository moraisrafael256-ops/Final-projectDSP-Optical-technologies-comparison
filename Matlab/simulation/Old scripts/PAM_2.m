% System simulation parameters[cite: 5]
N_bits = 1e6; % Number of random bits generated per cycle (Bit stream source)[cite: 5]
SNR_dB = 0:1:10; % Vector of Signal-to-Noise Ratio values (SNR / Eb/N0) in dB[cite: 5]
SNR_lin = 10.^(SNR_dB / 10); % Conversion from dB to linear scale[cite: 5]

% Preallocate arrays to store results[cite: 5]
simulated_BER = zeros(1, length(SNR_dB));
simulated_BER_ssrc = zeros(1, length(SNR_dB)); % Added for SSRC
theoretical_BER = zeros(1, length(SNR_dB));

for k = 1:length(SNR_dB)
    % 1. Generate random bit stream - Bit stream source[cite: 5]
    bits = randi([0 1], 1, N_bits); 
    
    % 2. Symbol mapping (PAM-2)[cite: 5]
    s_k = 2*bits - 1; 
    
    % 3. Add noise - AWGN channel (Discrete & SSRC Continuous)[cite: 1, 5]
    N0 = 1 / SNR_lin(k);
    
    % --- Discrete Channel ---
    n_k = sqrt(N0 / 2) * randn(1, N_bits); 
    r_k = s_k + n_k; 
    
    % --- SSRC Continuous Channel ---
    r_k_ssrc = ssrc_awgn_channel(s_k, N0, false);
    
    % 4. Decision[cite: 5]
    detected_bits = r_k > 0; 
    detected_bits_ssrc = r_k_ssrc > 0; % SSRC decision
    
    % 5. Calculate BER[cite: 5]
    simulated_BER(k) = sum(bits ~= detected_bits) / N_bits;
    simulated_BER_ssrc(k) = sum(bits ~= detected_bits_ssrc) / N_bits;
    
    % 6. Theoretical calculation[cite: 5]
    theoretical_BER(k) = qfunc(sqrt(2 * SNR_lin(k)));
end

% Plot the graph - Plot BER as function of SNR[cite: 5]
figure;
semilogy(SNR_dB, simulated_BER, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
semilogy(SNR_dB, simulated_BER_ssrc, 'rx-', 'LineWidth', 1.5, 'MarkerSize', 8);
semilogy(SNR_dB, theoretical_BER, 'g*--', 'LineWidth', 1.5, 'MarkerSize', 8);
grid on;
xlabel('SNR [dB]');
ylabel('Bit Error Rate (BER)');
title('PAM-2 BER vs SNR (Discrete vs SSRC)');
legend('Numeric BER (Discrete)', 'Numeric BER (SSRC)', 'Theory BER');