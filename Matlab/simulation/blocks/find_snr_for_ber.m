function snr_dB = find_snr_for_ber(target_ber, mod_type)
% FIND_SNR_FOR_BER Solve for Eb/N0 [dB] that achieves target_ber in ideal AWGN.
%
% Example:
%   snr_dB = find_snr_for_ber(1e-3, 'QPSK')   % ~6.79 dB
%   snr_dB = find_snr_for_ber(1e-3, '16QAM')  % ~10.52 dB

    obj    = @(snr) calc_theory_ber_ser(snr, mod_type) - target_ber;
    snr_dB = fzero(obj, [0, 25]);
end
