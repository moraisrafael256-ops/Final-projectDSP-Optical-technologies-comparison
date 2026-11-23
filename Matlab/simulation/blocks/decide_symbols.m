function S_hat = decide_symbols(r_k, mod_type)
% DECIDE_SYMBOLS Hard-decision slicer for PAM2, QPSK, PAM4, and 16QAM.

    switch upper(mod_type)
        case 'PAM2'
            S_hat = 2 * (real(r_k) >= 0) - 1;
        case 'QPSK'
            S_hat = (2 * (real(r_k) >= 0) - 1) + 1j * (2 * (imag(r_k) >= 0) - 1);
        case 'PAM4'
            S_hat = slice_pam4(real(r_k));
        case '16QAM'
            S_hat = slice_pam4(real(r_k)) + 1j * slice_pam4(imag(r_k));
        otherwise
            error('Unsupported modulation: %s', mod_type);
    end
end

function d = slice_pam4(x)
    d = -3 * ones(size(x));
    d(x >= -2) = -1;
    d(x >=  0) =  1;
    d(x >=  2) =  3;
end
