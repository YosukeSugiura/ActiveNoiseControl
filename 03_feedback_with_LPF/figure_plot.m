%
%	�X�y�N�g���̐}��
% ----------------------------------------
%	�쐬�ҁF ���Y�z��
%	�쐬���F 2022.7.19
%


%% �܂��͉��L�̃v���O���������s����
run feedback_with_2ndpathEstimation.m
run feedback_LPF_with_2ndpathEstimation.m
clear all;
close all;

%% wav�t�@�C���̓ǂݍ���
[in, ~]			= audioread('input.wav');
[out, ~]		= audioread('output_FB.wav');
[out_LPF, fs]	= audioread('output_FB_LPF.wav');
len				= length(in);

%% �X�y�N�g��

% �����̃X�y�N�g���O�����擾
S = 2048;
N = 8192;
[X_in, f, t]	= stft_(in, S, N, S/16, fs);
[X_out, f, t]	= stft_(out, S, N, S/16, fs);
[X_lpf, f, t]	= stft_(out_LPF, S, N, S/16, fs);

% ������(�����)�̕��σX�y�N�g�����v�Z
L = 500;
X_in_ave		= mean(abs(X_in(end-L:end,:)),1);	% �Ō��L�t���[�����̃X�y�N�g���𕽋�
X_out_ave		= mean(abs(X_out(end-L:end,:)),1);	% �Ō��L�t���[�����̃X�y�N�g���𕽋�
X_lpf_ave		= mean(abs(X_lpf(end-L:end,:)),1);	% �Ō��L�t���[�����̃X�y�N�g���𕽋�

% �ΐ��X�P�[���̃p���[�X�y�N�g��
P_in_ave = 20*log10(X_in_ave(1:N/2)+10^(-8));
P_out_ave = 20*log10(X_out_ave(1:N/2)+10^(-8));
P_lpf_ave = 20*log10(X_lpf_ave(1:N/2)+10^(-8));


%% �}��
% �g�`
figure(1);
plot((1:len)./fs, in, 'Color','r'); hold on;
plot((1:len)./fs, out, 'Color',[0 0.4470 0.7410]);
plot((1:len)./fs, out_LPF, 'Color',[0.4660 0.6740 0.1880]); hold off;
xlabel('Time [s]');
ylabel('Value');
title('Waveform');
legend('Input','FB-ANC','FB-ANC with LPF');

% �X�y�N�g���O����
figure(2);
plot(f, P_in_ave, 'LineWidth', 1, 'Color','r'); hold on;
plot(f, P_out_ave, 'LineWidth', 2, 'Color',[0 0.4470 0.7410]);
plot(f, P_lpf_ave, 'LineWidth', 2, 'Color',[0.4660 0.6740 0.1880]); hold off;
xlabel('Frequency [Hz]');
ylabel('Power [dB]');
title('Spectra');
legend('Input','FB-ANC','FB-ANC with LPF');
ylim([-35, 40])

% �X�y�N�g���O�����̍�
figure(3);
plot(f, P_out_ave-P_lpf_ave, 'LineWidth', 2);
xlabel('Frequency [Hz]');
ylabel('Improvement [dB]');
title('Improvement from FB-ANC');