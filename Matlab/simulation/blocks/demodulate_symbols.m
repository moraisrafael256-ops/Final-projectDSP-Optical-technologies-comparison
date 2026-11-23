function rx_bits = demodulate_symbols(S_hat, mod_type)
% DEMODULATE_SYMBOLS Convert decided symbols back into a 1D bit row vector.
% Exact inverse of modulate_bits().

    switch upper(mod_type)
        case 'PAM2'
            rx_bits = double(real(S_hat) > 0);
        case 'QPSK'
            b1 = real(S_hat) > 0;
            b2 = imag(S_hat) > 0;
            B  = [b1; b2];
            rx_bits = double(B(:).');
        case 'PAM4'
            [b1, b2] = demap_pam4_gray(real(S_hat));
            B = [b1; b2];
            rx_bits = double(B(:).');
        case '16QAM'
            [b1, b2] = demap_pam4_gray(real(S_hat));
            [b3, b4] = demap_pam4_gray(imag(S_hat));
            B = [b1; b2; b3; b4];
            rx_bits = double(B(:).');
        otherwise
            error('Unsupported modulation: %s', mod_type);
    end
end

function [b1, b2] = demap_pam4_gray(sym)
    % Inverse Gray map: -3->00, -1->01, +1->11, +3->10
    b1 = (sym > 0);
    b2 = (abs(sym) == 1);
end
