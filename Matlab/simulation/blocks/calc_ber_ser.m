function [ber, ser] = calc_ber_ser(tx_bits, rx_bits, S_k, S_hat)
% CALC_BER_SER Compute numerical Bit Error Rate (BER) and Symbol Error Rate (SER).
    ber = sum(tx_bits ~= rx_bits) / length(tx_bits);
    ser = sum(S_k ~= S_hat) / length(S_k);
end
