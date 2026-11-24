function [y, beta2, H_CD] = fiber(x, f, D, lambda, L)
% FIBER Chromatic dispersion optical fiber channel model (Task 3.1, Slides 10-11).
%
% Inputs:
%   x      - Input time-domain complex envelope signal s(t)
%   f      - Frequency vector [Hz], aligned with fftshift(fft(x))
%   D      - Dispersion parameter [s/m^2] (e.g., 17 ps/(nm*km) = 17e-6 s/m^2)
%   lambda - Optical carrier wavelength [m] (e.g., 1550e-9 m)
%   L      - Fiber length [m] (e.g., 20e3 m)
%
% Outputs:
%   y      - Dispersed output time-domain signal
%   beta2  - Group velocity dispersion parameter [s^2/m]
%   H_CD   - Fiber chromatic dispersion transfer function in frequency domain

    c     = 3e8;                             % Speed of light [m/s]
    beta2 = -(D * lambda^2) / (2 * pi * c);  % [s^2/m] from D = -(2*pi*c/lambda^2)*beta2

    w     = 2 * pi * f;
    H_CD  = exp(1j * (beta2 / 2) * (w.^2) * L);

    % Slide 11 frequency-domain propagation pipeline:
    X  = fft(x);
    X1 = fftshift(X);
    Y  = X1 .* H_CD;
    Y1 = ifftshift(Y);
    y  = ifft(Y1);
end
