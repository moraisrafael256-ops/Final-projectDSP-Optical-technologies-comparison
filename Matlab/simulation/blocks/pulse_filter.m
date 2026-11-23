function y = pulse_filter(x, h)
% PULSE_FILTER Convolve signal x with pulse-shaping or matched filter h.
% Note: Both SSRC and NRZ are symmetric real filters, so h_rx = h_tx.
    y = conv(x, h);
end
