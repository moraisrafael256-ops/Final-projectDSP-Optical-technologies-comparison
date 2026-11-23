function r_t = add_awgn_channel(s_t, N0, is_complex, osr)
% ADD_AWGN_CHANNEL Add white Gaussian noise at the channel sampling rate.
%
% Important Task 2.1 scaling:
%   resample(x, 4, 1) keeps signal amplitude unchanged, while resample(r, 2, 8)
%   applies an anti-aliasing filter with passband 1/osr that reduces white noise
%   variance by osr (= 4). Scaling noise variance by osr preserves exact Eb/N0.

    if nargin < 4 || isempty(osr)
        osr = 1;
    end

    sigma = sqrt(osr * N0 / 2);
    if is_complex
        n_t = sigma * (randn(size(s_t)) + 1j * randn(size(s_t)));
    else
        n_t = sigma * randn(size(s_t));
    end
    r_t = s_t + n_t;
end
