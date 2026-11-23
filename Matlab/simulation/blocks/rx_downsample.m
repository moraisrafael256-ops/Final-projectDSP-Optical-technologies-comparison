function r_k = rx_downsample(y_rx2, sps_tx, h)
% RX_DOWNSAMPLE Remove combined TX+RX filter edge transients and downsample 2->1.
%
% Unified group delay:
%   SSRC (length = span*sps_tx + 1) -> total_delay = span*sps_tx
%   NRZ  (length = 2)               -> total_delay = 1
% In both cases, total_delay = length(h) - 1 aligns symbol 1 at index 1.

    total_delay = length(h) - 1;
    y_trimmed   = y_rx2(total_delay + 1 : end - total_delay);
    r_k         = downsample(y_trimmed, sps_tx, 0);
end
