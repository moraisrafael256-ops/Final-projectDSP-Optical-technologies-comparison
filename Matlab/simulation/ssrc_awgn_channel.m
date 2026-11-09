function r_k_ssrc = ssrc_awgn_channel(S_k, N0, is_complex)
    % Pulse shaping parameters according to Task #2[cite: 1]
    SPS = 8;      % Samples per symbol[cite: 1]
    beta = 0.1;   % Roll-off factor[cite: 1]
    span = 32;    % Filter span in symbols (16 gives very low ISI for beta=0.1)

    % 1. Design SSRC filter (normalized to unit energy by default)[cite: 1]
    h_ssrc = rcosdesign(beta, span, SPS, 'sqrt');

    % 2. Upsample symbols by SPS = 8[cite: 1]
    S_up = upsample(S_k, SPS);

    % 3. Transmitter SSRC filtering[cite: 1]
    s_t = conv(S_up, h_ssrc);

    % 4. Add AWGN in continuous channel[cite: 1]
    if is_complex
        n_t = sqrt(N0 / 2) * (randn(size(s_t)) + 1j * randn(size(s_t)));
    else
        n_t = sqrt(N0 / 2) * randn(size(s_t));
    end
    r_t = s_t + n_t;

    % 5. Receiver Matched SSRC filtering[cite: 1]
    y_t = conv(r_t, h_ssrc);

    % 6. Remove edge samples (total group delay = span * SPS at each end)[cite: 1]
    total_delay = span * SPS;
    y_trimmed = y_t(total_delay + 1 : end - total_delay);

    % 7. Downsample by 8 back to symbol rate[cite: 1]
    r_k_ssrc = downsample(y_trimmed, SPS);
end