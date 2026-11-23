function h = design_pulse_filter(cfg)
% DESIGN_PULSE_FILTER Design unit-energy pulse-shaping / matched filter.
%   'ssrc' -> Square-Root Raised Cosine (for QPSK and 16QAM at SPS=2)
%   'nrz'  -> Rectangular NRZ pulse (for PAM2 and PAM4 at SPS=2)

    switch lower(cfg.pulse)
        case 'ssrc'
            h = rcosdesign(cfg.beta, cfg.span, cfg.sps_tx, 'sqrt');
        case 'nrz'
            h = ones(1, cfg.sps_tx) / sqrt(cfg.sps_tx);
        otherwise
            error('Unsupported pulse type: %s. Use ''ssrc'' or ''nrz''.', cfg.pulse);
    end
end
