function bits = generate_bits(N_bits)
% GENERATE_BITS Generate a random binary row vector of length N_bits.
    bits = randi([0 1], 1, N_bits);
end
