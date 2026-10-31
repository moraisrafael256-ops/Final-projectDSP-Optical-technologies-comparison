% System simulation parameters for QPSK / 4-QAM
N_bits = 1e6; % Total number of random bits
N_symb = N_bits / 2; % Number of symbols (2 bits per QPSK symbol)
SNR_dB = 0:1:10; % Vector of Signal-to-Noise Ratio values (Eb/N0) in dB
SNR_lin = 10.^(SNR_dB / 10); % Conversion from dB to linear scale

% Preallocate arrays to store results
simulated_BER = zeros(1, length(SNR_dB));
theoretical_BER = zeros(1, length(SNR_dB));
simulated_SER = zeros(1, length(SNR_dB));
theoretical_SER = zeros(1, length(SNR_dB));

for k = 1:length(SNR_dB)
    % 1. Generate bit stream - Define two vectors of random bits b1 and b2
    b1 = randi([0 1], 1, N_symb); 
    b2 = randi([0 1], 1, N_symb); 
    
    % 2. Symbol mapping (QPSK / 4-QAM)
    I = 2*b1 - 1; 
    Q = 2*b2 - 1; 
    
    % Define complex symbol as S = I + 1j*Q
    S_k = I + 1j * Q; 
    
    % 3. Add noise - AWGN channel
    N0 = 1 / SNR_lin(k);
    
    % Generate complex Gaussian noise
    n_k = sqrt(N0 / 2) * (randn(1, N_symb) + 1j * randn(1, N_symb)); 
    
    % Received signal
    r_k = S_k + n_k; % r = S + n = rI + jrQ
    
    % 4. Decision
    % Make separate decisions for I and Q
    r_I = real(r_k);
    r_Q = imag(r_k);
    
    dec_b1 = r_I > 0; 
    dec_b2 = r_Q > 0; 
    
    % 5. Calculate BER and SER numerically
    % Bit errors
    err_b1 = (b1 ~= dec_b1);
    err_b2 = (b2 ~= dec_b2);
    
    total_bit_errors = sum(err_b1) + sum(err_b2);
    simulated_BER(k) = total_bit_errors / N_bits;
    
    % Symbol errors: A symbol is wrong if at least one of its bits is wrong
    symb_errors = err_b1 | err_b2;
    total_symb_errors = sum(symb_errors);
    simulated_SER(k) = total_symb_errors / N_symb; % SER = sum(Error_symb) / Nsymb
    
    % 6. Theoretical calculation
    % BER for QPSK is the same as BPSK
    p_bit = qfunc(sqrt(2 * SNR_lin(k)));
    theoretical_BER(k) = p_bit;
    
    % SER for QPSK: probability of at least one bit error in the symbol
    % SER = 1 - P(both bits correct) = 1 - (1 - p_bit)^2 = 2*p_bit - p_bit^2
    theoretical_SER(k) = 2*p_bit - p_bit^2;
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
title('QPSK (4-QAM) Error Rates: BER vs SER');
legend('Numeric BER', 'Theory BER', 'Numeric SER', 'Theory SER');