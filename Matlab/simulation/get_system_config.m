function cfg = get_system_config(mod_type, N_symb, channel_mode, enable_fiber, enable_dcf, pulse_override)
% GET_SYSTEM_CONFIG Build a standardized parameter struct for comm_system.
%
% Inputs:
%   mod_type       - 'PAM2', 'QPSK', 'PAM4', or '16QAM'
%   N_symb         - Number of symbols to simulate per SNR point
%   channel_mode   - (optional) 'dac_adc' (default) or 'discrete'
%   enable_fiber   - (optional) true to include SMF fiber L1 (default: true)
%   enable_dcf     - (optional) true to include DCF fiber L2 (default: true)
%   pulse_override - (optional) 'ssrc' or 'nrz' to override Slide 9 default

    if nargin < 3 || isempty(channel_mode)
        channel_mode = 'dac_adc';
    end
    if nargin < 4 || isempty(enable_fiber)
        enable_fiber = true;
    end
    if nargin < 5 || isempty(enable_dcf)
        enable_dcf = true;
    end

    cfg.mod_type     = upper(strtrim(mod_type));
    cfg.N_symb       = N_symb;
    cfg.channel_mode = lower(strtrim(channel_mode));

    % Task 2.1 sampling & pulse-shaping parameters (Slide 9)
    cfg.sps_tx = 2;                        % Upsampling rate before SSRC / NRZ
    cfg.sps_ch = 8;                        % Channel sampling rate after DAC
    cfg.beta   = 0.1;                      % SSRC roll-off factor
    cfg.span   = 32;                       % SSRC filter span in symbols

    % Task 3.1 & 3.2 optical fiber + DCF parameters (Slides 10, 12-13)
    cfg.enable_fiber = logical(enable_fiber);
    cfg.enable_dcf   = logical(enable_dcf);
    cfg.SR           = 100e9;              % Symbol rate: 100 GSymb/s
    cfg.F_samp       = cfg.sps_ch * cfg.SR;% Sampling rate: 800 GHz
    cfg.lambda       = 1550e-9;            % Wavelength: 1550 nm [m]
    cfg.D1           = 17e-6;              % SMF dispersion: 17 ps/(nm*km) = 17e-6 [s/m^2]
    cfg.L1           = 20e3;               % SMF length: 20 km [m]
    cfg.D2           = -100e-6;            % DCF dispersion: -100 ps/(nm*km) = -100e-6 [s/m^2]
    cfg.L2           = 3.4e3;              % DCF length: 3.4 km [m]  (L1*D1 + L2*D2 = 0)

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

    if nargin >= 6 && ~isempty(pulse_override)
        cfg.pulse = lower(strtrim(pulse_override));
    end

    cfg.N_bits = cfg.k * cfg.N_symb;
end
