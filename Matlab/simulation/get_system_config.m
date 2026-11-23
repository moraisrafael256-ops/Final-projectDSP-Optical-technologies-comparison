function cfg = get_system_config(mod_type, N_symb, channel_mode, pulse_override)
% GET_SYSTEM_CONFIG Build a standardized parameter struct for comm_system.
%
% Inputs:
%   mod_type       - 'PAM2', 'QPSK', 'PAM4', or '16QAM'
%   N_symb         - Number of symbols to simulate per SNR point
%   channel_mode   - (optional) 'dac_adc' (default, Task 2.1) or 'discrete'
%   pulse_override - (optional) 'ssrc' or 'nrz' to override Slide 9 default
%
% Output:
%   cfg            - Configuration struct passed to comm_system()

    if nargin < 3 || isempty(channel_mode)
        channel_mode = 'dac_adc';
    end

    cfg.mod_type     = upper(strtrim(mod_type));
    cfg.N_symb       = N_symb;
    cfg.channel_mode = lower(strtrim(channel_mode));

    % Task 2.1 sampling & pulse-shaping parameters (Slide 9)
    cfg.sps_tx = 2;       % Upsampling rate before SSRC / NRZ
    cfg.sps_ch = 8;       % Continuous-channel rate after DAC resample(x,4,1)
    cfg.osr    = cfg.sps_ch / cfg.sps_tx;  % Oversampling ratio = 4
    cfg.beta   = 0.1;     % SSRC roll-off factor
    cfg.span   = 32;      % SSRC filter span in symbols

    switch cfg.mod_type
        case 'PAM2'
            cfg.k          = 1;
            cfg.Eb         = 1.0;
            cfg.is_complex = false;
            cfg.pulse      = 'nrz';
        case 'QPSK'
            cfg.k          = 2;
            cfg.Eb         = 1.0;
            cfg.is_complex = true;
            cfg.pulse      = 'ssrc';
        case 'PAM4'
            cfg.k          = 2;
            cfg.Eb         = 2.5;
            cfg.is_complex = false;
            cfg.pulse      = 'nrz';
        case '16QAM'
            cfg.k          = 4;
            cfg.Eb         = 2.5;
            cfg.is_complex = true;
            cfg.pulse      = 'ssrc';
        otherwise
            error('Unsupported mod_type: %s. Use PAM2, QPSK, PAM4, or 16QAM.', mod_type);
    end

    if nargin >= 4 && ~isempty(pulse_override)
        cfg.pulse = lower(strtrim(pulse_override));
    end

    cfg.N_bits = cfg.k * cfg.N_symb;
end
