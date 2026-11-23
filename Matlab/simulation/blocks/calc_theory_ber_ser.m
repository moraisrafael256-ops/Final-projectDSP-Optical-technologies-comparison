function [th_BER, th_SER] = calc_theory_ber_ser(SNR_dB, mod_type)
% CALC_THEORY_BER_SER Theoretical AWGN BER and SER vs. Eb/N0 [dB].

    SNR_lin = 10.^(SNR_dB / 10);

    switch upper(mod_type)
        case 'PAM2'
            th_BER = qfunc(sqrt(2 * SNR_lin));
            th_SER = th_BER;
        case 'QPSK'
            p_bit  = qfunc(sqrt(2 * SNR_lin));
            th_BER = p_bit;
            th_SER = 2 * p_bit - p_bit.^2;
        case 'PAM4'
            th_SER = 1.5 * qfunc(sqrt(0.8 * SNR_lin));
            th_BER = th_SER / 2;
        case '16QAM'
            p_sqrtM = 1.5 * qfunc(sqrt(0.8 * SNR_lin));
            th_SER  = 1 - (1 - p_sqrtM).^2;
            th_BER  = th_SER / 4;
        otherwise
            error('Unsupported modulation: %s', mod_type);
    end
end
