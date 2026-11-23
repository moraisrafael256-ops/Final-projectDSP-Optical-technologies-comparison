function s_t = dac_resample(x, sps_tx, sps_ch)
% DAC_RESAMPLE Upsample from sps_tx (2) to sps_ch (8) using resample(x, 4, 1).
    p = sps_ch / sps_tx;
    s_t = resample(x, p, 1);
end
