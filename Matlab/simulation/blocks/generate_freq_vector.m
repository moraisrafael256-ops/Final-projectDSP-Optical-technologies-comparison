function [f, t, df] = generate_freq_vector(N_samp, F_samp)
% GENERATE_FREQ_VECTOR Build time vector t and fftshift-aligned frequency vector f.
%
% Inputs:
%   N_samp - Number of samples in the time-domain signal x(t)
%   F_samp - Sampling frequency [Hz] (F_samp = sps_ch * SR)
%
% Outputs:
%   f      - Frequency vector [Hz] aligned with fftshift(fft(x)), DC=0 at floor(N/2)+1
%   t      - Time vector [s] = (0 : N_samp-1) * dt
%   df     - Frequency resolution [Hz] = F_samp / N_samp

    dt = 1 / F_samp;
    t  = (0 : N_samp - 1) * dt;
    df = F_samp / N_samp;

    % Exact fftshift-aligned frequency grid for both even and odd N_samp
    f  = (-floor(N_samp / 2) : ceil(N_samp / 2) - 1) * df;
end
