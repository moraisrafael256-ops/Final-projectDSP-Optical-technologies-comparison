function S_k = modulate_bits(bits, mod_type)
% MODULATE_BITS Map a 1D bit vector into Gray-coded PAM/QAM symbols.
%
% Mapping matches Task2-3.pptx Slides 2-5:
%   PAM2  : 0 -> -1, 1 -> +1
%   QPSK  : (b1,b2) -> (2*b1-1) + 1j*(2*b2-1)
%   PAM4  : 00 -> -3, 01 -> -1, 11 -> +1, 10 -> +3
%   16QAM : (b1,b2) -> I (PAM4), (b3,b4) -> Q (PAM4), S = I + 1j*Q

    switch upper(mod_type)
        case 'PAM2'
            S_k = 2 * bits - 1;
        case 'QPSK'
            B   = reshape(bits, 2, []);
            S_k = (2 * B(1,:) - 1) + 1j * (2 * B(2,:) - 1);
        case 'PAM4'
            B   = reshape(bits, 2, []);
            S_k = map_pam4_gray(B(1,:), B(2,:));
        case '16QAM'
            B   = reshape(bits, 4, []);
            I   = map_pam4_gray(B(1,:), B(2,:));
            Q   = map_pam4_gray(B(3,:), B(4,:));
            S_k = I + 1j * Q;
        otherwise
            error('Unsupported modulation: %s', mod_type);
    end
end

function sym = map_pam4_gray(b1, b2)
    sym = (2 * b1 - 1) .* (3 - 2 * b2);
end
