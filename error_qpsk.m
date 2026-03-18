clc;
clear;
close all;

N = 1e5;
EbNo_dB = -4:2:12;
M = 4;

bits = randi([0 1], N, 1);

bits_reshaped = reshape(bits, 2, []).';

symbols = (2*bits_reshaped(:,1)-1) + 1j*(2*bits_reshaped(:,2)-1);
symbols = symbols/sqrt(2);

figure;
scatter(real(symbols), imag(symbols), 'k', 'filled');
grid on;
axis equal;
xlabel('In-phase');
ylabel('Quadrature');
title('QPSK Constellation Diagram');

BER_sim = zeros(size(EbNo_dB));

for i = 1:length(EbNo_dB)

    EbNo = 10^(EbNo_dB(i)/10);

    noise_var = 1/(4*EbNo);   % (keeping your structure)

    noise = sqrt(noise_var) * ...
        (randn(size(symbols)) + 1j*randn(size(symbols)));

    received = symbols + noise;

    detected_bits = [real(received)>0 imag(received)>0];

    detected_bits = reshape(detected_bits.', N, 1);

    BER_sim(i) = sum(bits ~= detected_bits)/N;

end

BER_theory = 0.5*erfc(sqrt(10.^(EbNo_dB/10)));

figure;
semilogy(EbNo_dB, BER_sim, 'ro-', 'LineWidth', 1.5);
hold on;
semilogy(EbNo_dB, BER_theory, 'k-', 'LineWidth', 1.5);
xlabel('E_b/N_0 (dB)');
ylabel('BER');
title('QPSK BER over AWGN');
legend('Simulated','Theoretical');
grid on;
