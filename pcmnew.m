clc;
clear;
close all;

%% Parameters
fm = 2;            % Message frequency
fs = 50;           % Sampling frequency
A = 5;             % Amplitude
duration = 1;
n_plot = 3;        % Number of bits for PCM

%% Analog Signal
t = 0:0.001:duration;
x_analog = A * sin(2*pi*fm*t);

%% Sampling
ts = 0:1/fs:duration;
x_sampled = A * sin(2*pi*fm*ts);

%% Quantization
L = 2^n_plot;              % Number of levels
Vmax = A;
Vmin = -A;
step_size = (Vmax - Vmin) / L;

levels = Vmin + step_size/2 : step_size : Vmax - step_size/2;
[~, index] = min(abs(x_sampled' - levels), [], 2);
x_quantized = levels(index);

%% Encoding (Binary Conversion)
index_zero_based = index - 1;
binary_matrix = dec2bin(index_zero_based, n_plot);

% Convert to serial bit stream
bits = binary_matrix';
bit_stream = bits(:) - '0';

%% ✅ DISPLAY 3-BIT WORDS IN ONE LINE
disp('3-bit PCM Bit Stream (each group = one sample):');
disp(strjoin(cellstr(binary_matrix),' '));

%% ================= Waveforms =================
figure('Name', 'PCM Waveforms', 'Color', 'w');

subplot(4,1,1);
plot(t, x_analog, 'LineWidth', 1.5);
title('1. Analog Input Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(4,1,2);
stem(ts, x_sampled, 'filled', 'MarkerSize', 4);
title('2. Sampled Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(4,1,3);
stairs(ts, x_quantized, 'LineWidth', 1.5);
title(['3. Quantized Output (', num2str(n_plot), '-bit)']);
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(4,1,4);
stairs(bit_stream, 'LineWidth', 1.5);
title('4. Encoded Output (Serial Bit Stream)');
xlabel('Bit Index');
ylabel('Binary Value');
ylim([-0.2 1.2]);
grid on;

%% ================= SNR vs Number of Bits =================
n_bits_array = 2:12;
snr_values = zeros(size(n_bits_array));

for i = 1:length(n_bits_array)

    n = n_bits_array(i);
    L_levels = 2^n;
    step = (Vmax - Vmin) / L_levels;
    
    lvl = Vmin + step/2 : step : Vmax - step/2;
    [~, idx] = min(abs(x_sampled' - lvl), [], 2);
    x_q = lvl(idx);
    
    signal_power = mean(x_sampled.^2);
    noise_power = mean((x_sampled - x_q).^2);
    
    snr_values(i) = 10 * log10(signal_power / noise_power);
end

figure('Name', 'SNR Analysis', 'Color', 'w');
plot(n_bits_array, snr_values, '-o', 'LineWidth', 2, 'MarkerFaceColor', 'b');
title('SNR vs Number of Bits per Symbol');
xlabel('Number of Bits (n)');
ylabel('SNR (dB)');
grid on;

%% ================= SQNR vs Number of Bits =================
n_bits_sqnr = 2:12;
sqnr_values = zeros(size(n_bits_sqnr));

for k = 1:length(n_bits_sqnr)

    n = n_bits_sqnr(k);
    Lq = 2^n;
    delta = (Vmax - Vmin) / Lq;

    q_levels = Vmin + delta/2 : delta : Vmax - delta/2;
    [~, q_index] = min(abs(x_sampled' - q_levels), [], 2);
    xq = q_levels(q_index);

    Ps = mean(x_sampled.^2);           % Signal power
    Pq = mean((x_sampled - xq).^2);    % Quantization noise power

    sqnr_values(k) = 10 * log10(Ps / Pq);
end

figure('Name', 'SQNR Analysis', 'Color', 'w');
plot(n_bits_sqnr, sqnr_values, '-s', 'LineWidth', 2, 'MarkerFaceColor', 'r');
xlabel('Number of Bits per Symbol (n)');
ylabel('SQNR (dB)');
title('SQNR vs Number of Bits per Symbol');
grid on;
