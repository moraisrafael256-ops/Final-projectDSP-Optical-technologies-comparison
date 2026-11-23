function x_up = tx_upsample(S_k, sps_tx)
% TX_UPSAMPLE Insert (sps_tx - 1) zeros between symbols (Task 2.1: SPS = 2).
    x_up = upsample(S_k, sps_tx);
end
