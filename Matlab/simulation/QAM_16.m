% System simulation parameters for 16-QAM
N_bits = 4e5; % Total number of random bits (multiple of 4)
N_symb = N_bits / 4; % Number of symbols (4 bits per 16-QAM symbol)
SNR_dB = 0:1:10; % Vector of Signal-to-Noise Ratio (Eb/N0) in dB
SNR_lin = 10.^(SNR_dB / 10); % Conversion from dB to linear scale

% Preallocate arrays to store results
simulated_BER = zeros(1, length(SNR_dB));
theoretical_BER = zeros(1, length(SNR_dB));
simulated_SER = zeros(1, length(SNR_dB));
theoretical_SER = zeros(1, length(SNR_dB));

for k = 1:length(SNR_dB)
    % 1. Generate bit stream for 4 bits per symbol
    b1 = randi([0 1], 1, N_symb); 
    b2 = randi([0 1], 1, N_symb); 
    b3 = randi([0 1], 1, N_symb); 
    b4 = randi([0 1], 1, N_symb); 
    
    % 2. Symbol mapping with Gray coding (PAM-4 for I and Q)
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
    
    % Define complex symbol as S = I + 1j*Q
    S_k = I + 1j * Q; 
    
    % 3. Add noise - AWGN channel
    % The symbols are +/-1, +/-3 in both I and Q.
    % Average symbol energy Es = E(|I|^2) + E(|Q|^2) = 5 + 5 = 10.
    % Bit energy Eb = Es / 4 = 10 / 4 = 2.5.
    N0 = 2.5 / SNR_lin(k);
    
    % Generate complex Gaussian noise
    n_k = sqrt(N0 / 2) * (randn(1, N_symb) + 1j * randn(1, N_symb)); 
    
    % Received signal: r = S + n = rI + jrQ
    r_k = S_k + n_k; 
    r_I = real(r_k);
    r_Q = imag(r_k);
    
    % 4. Decision for I and Q according to decision law for 4-PAM
    % Start that all the decision vector elements are -3
    dec_I = -3 * ones(1, N_symb);
    dec_Q = -3 * ones(1, N_symb);
    
    % Find vector indices and set decisions for I
    dec_I(r_I >= -2) = -1;
    dec_I(r_I >= 0)  =  1;
    dec_I(r_I >= 2)  =  3; 
    
    % Find vector indices and set decisions for Q
    dec_Q(r_Q >= -2) = -1;
    dec_Q(r_Q >= 0)  =  1;
    dec_Q(r_Q >= 2)  =  3;
    
    % 5. Symbol to bit conversion (Inverse Gray coding)
    dec_b1 = zeros(1, N_symb); dec_b2 = zeros(1, N_symb);
    dec_b3 = zeros(1, N_symb); dec_b4 = zeros(1, N_symb);
    
    dec_b1(dec_I == 1 | dec_I == 3) = 1;
    dec_b2(dec_I == -1 | dec_I == 1) = 1;
    
    dec_b3(dec_Q == 1 | dec_Q == 3) = 1;
    dec_b4(dec_Q == -1 | dec_Q == 1) = 1;
    
    % 6. Calculate SER and BER numerically
    % Error_bit = error_b1 + error_b2 + error_b3 + error_b4
    err_b1 = sum(b1 ~= dec_b1);
    err_b2 = sum(b2 ~= dec_b2);
    err_b3 = sum(b3 ~= dec_b3);
    err_b4 = sum(b4 ~= dec_b4);
    
    % BER = sum(Error_bit)/(4Nsymb)
    total_bit_errors = err_b1 + err_b2 + err_b3 + err_b4;
    simulated_BER(k) = total_bit_errors / (4 * N_symb); 
    
    % SER = sum(Error_symb)/(Nsymb)
    err_symb = (I ~= dec_I) | (Q ~= dec_Q);
    simulated_SER(k) = sum(err_symb) / N_symb;
    
    % 7. Theoretical results for 16-QAM
    % Probability of error in one dimension (PAM-4)
    P_sqrtM = 1.5 * qfunc(sqrt(0.8 * SNR_lin(k)));
    
    % SER for square QAM: 1 - (1 - P_sqrtM)^2
    theoretical_SER(k) = 1 - (1 - P_sqrtM)^2;
    
    % Theoretical BER with Gray coding is approximately SER / log2(M)
    theoretical_BER(k) = theoretical_SER(k) / 4;
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
title('16-QAM Error Rates: BER vs SER');
legend('Numeric BER', 'Theory BER', 'Numeric SER', 'Theory SER');
% --- 16-QAM Constellation Diagram ---
% Set a specific SNR for the plot (e.g., 15 dB)
SNR_dB_plot = 15; 
SNR_lin_plot = 10^(SNR_dB_plot / 10);
N0_plot = 2.5 / SNR_lin_plot;

% Generate noise and received signal for the chosen SNR
n_k_plot = sqrt(N0_plot / 2) * (randn(1, N_symb) + 1j * randn(1, N_symb)); 
r_k_plot = S_k + n_k_plot; 

% Plotting
figure;
% Plot the noisy received symbols (blue dots)
plot(real(r_k_plot), imag(r_k_plot), 'b.', 'MarkerSize', 2); 
hold on;
% Plot the ideal transmitted symbols (red stars)
plot(real(S_k), imag(S_k), 'r*', 'MarkerSize', 8, 'LineWidth', 1.5); 

grid on;
xlabel('In-Phase (I)');
ylabel('Quadrature (Q)');
title(['16-QAM Constellation Diagram (SNR = ', num2str(SNR_dB_plot), ' dB)']);
legend('Received Noisy Symbols', 'Ideal Symbols');
axis([-5 5 -5 5]); % Keep axes scaled properly