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

%% �X�y�N�g��

% �����̃X�y�N�g���O�����擾
[X_in, f, t]	= stft_(in, 256, 1024, 36, fs);
[X_out, f, t]	= stft_(out, 256, 1024, 36, fs);
[X_lpf, f, t]	= stft_(out_LPF, 256, 1024, 36, fs);

% ������(�����)�̕��σX�y�N�g�����v�Z
L = 500;
X_in_ave		= mean(abs(X_in(end-L:end,:)),1);	% �Ō��L�t���[�����̃X�y�N�g���𕽋�
X_out_ave		= mean(abs(X_out(end-L:end,:)),1);	% �Ō��L�t���[�����̃X�y�N�g���𕽋�
X_lpf_ave		= mean(abs(X_lpf(end-L:end,:)),1);	% �Ō��L�t���[�����̃X�y�N�g���𕽋�

% �ΐ��X�P�[���̃p���[�X�y�N�g��
P_in_ave = 20*log10(X_in_ave(1:512)+10^(-8));
P_out_ave = 20*log10(X_out_ave(1:512)+10^(-8));
P_lpf_ave = 20*log10(X_lpf_ave(1:512)+10^(-8));

figure(1);
plot(f, P_in_ave(1:512), 'LineWidth', 1); hold on;
plot(f, P_out_ave(1:512), 'LineWidth', 1);
plot(f, P_lpf_ave(1:512), 'LineWidth', 1); hold off;
xlabel('Frequency [Hz]');
ylabel('Power [dB]');
title('Spectra');
legend('Input','FB-ANC','FB-ANC with LPF');
ylim([-35, 15])

