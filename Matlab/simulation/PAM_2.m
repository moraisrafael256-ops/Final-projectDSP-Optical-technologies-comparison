% System simulation parameters
N_bits = 1e6; % Number of random bits generated per cycle (Bit stream source)
SNR_dB = 0:1:10; % Vector of Signal-to-Noise Ratio values (SNR / Eb/N0) in dB
SNR_lin = 10.^(SNR_dB / 10); % Conversion from dB to linear scale

% Preallocate arrays to store results
simulated_BER = zeros(1, length(SNR_dB));
theoretical_BER = zeros(1, length(SNR_dB));

for k = 1:length(SNR_dB)
    % 1. Generate random bit stream - Bit stream source
    bits = randi([0 1], 1, N_bits); 
    
    % 2. Symbol mapping (PAM-2)
    % Map bit 0 to (-1) and bit 1 to (+1)
    s_k = 2*bits - 1; 
    
    % 3. Add noise - AWGN channel
    % Calculate noise variance according to SNR
    N0 = 1 / SNR_lin(k);
    n_k = sqrt(N0 / 2) * randn(1, N_bits); % Generate Gaussian noise (n_k)
    r_k = s_k + n_k; % Received signal after adding noise
    
    % 4. Decision
    % For PAM-2, the decision threshold is 0
    % If r_k > 0 decide 1, else decide 0
    detected_bits = r_k > 0; 
    
    % 5. Calculate BER - BER calculation
    % Sum the number of errors (where detected bit differs from original bit) and divide by total bits
    errors = sum(bits ~= detected_bits);
    simulated_BER(k) = errors / N_bits;
    
    % 6. Theoretical calculation vs Simulation (Theory BER)
    % Use Q-function to calculate the theoretical BER for PAM-2 (BPSK)
    theoretical_BER(k) = qfunc(sqrt(2 * SNR_lin(k)));
end

% Plot the graph - Plot BER as function of SNR
figure;
semilogy(SNR_dB, simulated_BER, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
semilogy(SNR_dB, theoretical_BER, 'g*--', 'LineWidth', 1.5, 'MarkerSize', 8);
grid on;
xlabel('SNR [dB]');
ylabel('Bit Error Rate (BER)');
title('PAM-2 BER vs SNR');
legend('Numeric BER', 'Theory BER');