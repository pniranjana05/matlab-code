clc;
clear;
close all;

N = 1e5;
EbNodB = -4:2:12;

EbNo = 10.^(EbNodB/10);
No = 1./EbNo;

bits = randi([0 1],1,N);
s = 2*bits - 1;

BER_Sim = zeros(size(EbNodB));

for i = 1:length(EbNodB)
    
    noise = sqrt(No(i)/2) * randn(1,N);
    r = s + noise;
    
    bits_detected = r > 0;
    
    BER_Sim(i) = sum(bits ~= bits_detected)/N;
    
end

BER_theory = qfunc(sqrt(2*EbNo));

figure;
semilogy(EbNodB, BER_Sim, 'o-', 'LineWidth', 1.5);
hold on;
semilogy(EbNodB, BER_theory, 'k-', 'LineWidth', 1.5);

xlabel('Eb/N0 (dB)');
ylabel('BER (P_b)');
title('Probability of Bit Error for BPSK over AWGN channel');
legend('BPSK Sim', 'BPSK Theory');
grid on;

% Constellation Diagram
figure;
scatter(real(s), imag(s), 'b*');
xlabel('In-phase');
ylabel('Quadrature');
title('Signal Constellation Diagram');
axis([-1.2 1.2 -0.1 0.1]);
grid on;
