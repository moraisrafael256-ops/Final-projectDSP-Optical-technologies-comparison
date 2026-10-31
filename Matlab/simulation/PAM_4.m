% System simulation parameters for PAM-4
N_bits = 1e6; % Total number of random bits
N_symb = N_bits / 2; % Number of symbols (2 bits per PAM-4 symbol)
SNR_dB = 0:1:10; % Vector of Signal-to-Noise Ratio (Eb/N0) in dB
SNR_lin = 10.^(SNR_dB / 10); % Conversion from dB to linear scale

% Preallocate arrays to store results
simulated_BER = zeros(1, length(SNR_dB));
theoretical_BER = zeros(1, length(SNR_dB));
simulated_SER = zeros(1, length(SNR_dB));
theoretical_SER = zeros(1, length(SNR_dB));

for k = 1:length(SNR_dB)
    % 1. Generate bit stream 
    b1 = randi([0 1], 1, N_symb); 
    b2 = randi([0 1], 1, N_symb); 
    
    % 2. Symbol mapping with Gray coding (PAM-4)
    % Mapping: 
    % 00 -> -3
    % 01 -> -1
    % 11 -> +1
    % 10 -> +3
    S_k = zeros(1, N_symb);
    S_k(b1 == 0 & b2 == 0) = -3;
    S_k(b1 == 0 & b2 == 1) = -1;
    S_k(b1 == 1 & b2 == 1) =  1;
    S_k(b1 == 1 & b2 == 0) =  3;
    
    % 3. Add noise - AWGN channel
    % The symbols are {-3, -1, 1, 3}. 
    % Average symbol energy Es = (9 + 1 + 1 + 9) / 4 = 5.
    % Since there are 2 bits per symbol, average bit energy Eb = Es / 2 = 2.5.
    % To maintain the requested Eb/N0, we calculate N0 based on this Eb:
    N0 = 2.5 / SNR_lin(k);
    
    % Generate real Gaussian noise (1D modulation)
    n_k = sqrt(N0 / 2) * randn(1, N_symb); 
    
    % Received signal
    r_k = S_k + n_k; 
    
    % 4. Decision according to the sliding thresholds
    % Start with all decision vector elements as -3
    dec_S = -3 * ones(1, N_symb);
    
    % Find vector indices and set decisions
    dec_S(r_k >= -2) = -1;
    dec_S(r_k >= 0)  =  1;
    dec_S(r_k >= 2)  =  3; % Standard threshold is 2 (correcting the rI>=1 typo)
    
    % 5. Demapping back to bits (Inverse Gray coding)
    dec_b1 = zeros(1, N_symb);
    dec_b2 = zeros(1, N_symb);
    
    % b1 is 1 if symbol is +1 or +3
    dec_b1(dec_S == 1 | dec_S == 3) = 1;
    % b2 is 1 if symbol is -1 or +1
    dec_b2(dec_S == -1 | dec_S == 1) = 1;
    
    % 6. Calculate BER and SER numerically
    % Bit errors
    err_b1 = (b1 ~= dec_b1);
    err_b2 = (b2 ~= dec_b2);
    
    total_bit_errors = sum(err_b1) + sum(err_b2);
    simulated_BER(k) = total_bit_errors / N_bits;
    
    % Symbol errors
    err_symb = (S_k ~= dec_S);
    simulated_SER(k) = sum(err_symb) / N_symb;
    
    % 7. Theoretical calculation for PAM-4
    % Theoretical SER for PAM-M: 2*(M-1)/M * Q(sqrt( (6*log2(M)/(M^2-1)) * Eb/N0 ))
    % For M=4: 1.5 * Q(sqrt(0.8 * Eb/N0))
    p_s = 1.5 * qfunc(sqrt(0.8 * SNR_lin(k)));
    theoretical_SER(k) = p_s;
    
    % Theoretical BER with Gray coding is approximately SER / log2(M)
    theoretical_BER(k) = p_s / 2;
end

% Plot the graph - Compare BER and SER
figure;
semilogy(SNR_dB, simulated_BER, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
semilogy(SNR_dB, theoretical_BER, 'k--', 'LineWidth', 1.5);
semilogy(SNR_dB, simulated_SER, 'rs-', 'LineWidth', 1.5, 'MarkerSize', 6);
semilogy(SNR_dB, theoretical_SER, 'g--', 'LineWidth', 1.5);
grid on;
xlabel('SNR (E_b/N_0) [dB]');
ylabel('Error Rate');
title('PAM-4 Error Rates: BER vs SER');
legend('Numeric BER', 'Theory BER', 'Numeric SER', 'Theory SER');