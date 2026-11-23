function r_rx2 = adc_resample(r_t, sps_tx, sps_ch)
% ADC_RESAMPLE Downsample from sps_ch (8) to sps_tx (2) using resample(r_t, 2, 8),
% which includes an anti-aliasing low-pass filter before decimation.
    r_rx2 = resample(r_t, sps_tx, sps_ch);
end
