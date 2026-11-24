function [ber, ser, r_k, S_k] = comm_system(cfg, SNR_dB)
% COMM_SYSTEM End-to-end modular communication chain (Tasks 1, 2.1, 3.1, 3.2, 3.3).
%
% Signal chain:
%   Bits -> Modulate -> Upsample(2) -> Pulse Shape (SSRC/NRZ) -> DAC resample(4,1)
%        -> Fiber L1,D1 -> DCF L2,D2 -> AWGN
%        -> ADC resample(2,8) -> Matched Filter -> Trim & Downsample(2,0)
%        -> Decision -> Demodulate -> BER & SER

    SNR_lin = 10^(SNR_dB / 10);
    N0      = cfg.Eb / SNR_lin;

    % 1. Bit stream source & symbol mapping
    tx_bits = generate_bits(cfg.N_bits);
    S_k     = modulate_bits(tx_bits, cfg.mod_type);

    if strcmpi(cfg.channel_mode, 'discrete')
        % Discrete baseline channel (Task 1)
        r_k = add_awgn_channel(S_k, N0, cfg.is_complex, 1);
    else
        % 2. Transmitter: Upsample (SPS=2) -> Pulse Shaping -> DAC (SPS=2->8)
        x_up2   = tx_upsample(S_k, cfg.sps_tx);
        h_pulse = design_pulse_filter(cfg);
        s_tx2   = pulse_filter(x_up2, h_pulse);
        s_t     = dac_resample(s_tx2, cfg.sps_tx, cfg.sps_ch);

        % 3. Optical Fiber (Task 3.1) + DCF Compensation (Task 3.2 / 3.3)
        need_freq = (cfg.enable_fiber && cfg.L1 ~= 0) || (cfg.enable_dcf && cfg.L2 ~= 0);
        if need_freq
            F_samp = cfg.sps_ch * cfg.SR;  % Always in sync with cfg.SR
            f      = generate_freq_vector(length(s_t), F_samp);
        end
        if cfg.enable_fiber && cfg.L1 ~= 0
            s_t = fiber(s_t, f, cfg.D1, cfg.lambda, cfg.L1);
        end
        if cfg.enable_dcf && cfg.L2 ~= 0
            s_t = fiber(s_t, f, cfg.D2, cfg.lambda, cfg.L2);
        end

        % 4. AWGN Channel
        r_t     = add_awgn_channel(s_t, N0, cfg.is_complex, cfg.sps_ch/cfg.sps_tx);

        % 5. Receiver: ADC (SPS=8->2) -> Matched Filter -> Downsample (2->1)
        r_rx2   = adc_resample(r_t, cfg.sps_tx, cfg.sps_ch);
        y_rx2   = pulse_filter(r_rx2, h_pulse);
        r_k     = rx_downsample(y_rx2, cfg.sps_tx, h_pulse);
    end

    % 6. Decision & symbol-to-bit conversion
    S_hat   = decide_symbols(r_k, cfg.mod_type);
    rx_bits = demodulate_symbols(S_hat, cfg.mod_type);

    % 7. Error-rate calculation
    [ber, ser] = calc_ber_ser(tx_bits, rx_bits, S_k, S_hat);
end
