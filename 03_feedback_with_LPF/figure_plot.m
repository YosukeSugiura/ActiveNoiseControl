%
%	スペクトルの図示
% ----------------------------------------
%	作成者： 杉浦陽介
%	作成日： 2022.7.19
%


%% まずは下記のプログラムを実行する
run feedback_with_2ndpathEstimation.m
run feedback_LPF_with_2ndpathEstimation.m
clear all;
close all;

%% wavファイルの読み込み
[in, ~]			= audioread('input.wav');
[out, ~]		= audioread('output_FB.wav');
[out_LPF, fs]	= audioread('output_FB_LPF.wav');

%% スペクトル

% 音声のスペクトログラム取得
[X_in, f, t]	= stft_(in, 256, 1024, 36, fs);
[X_out, f, t]	= stft_(out, 256, 1024, 36, fs);
[X_lpf, f, t]	= stft_(out_LPF, 256, 1024, 36, fs);

% 収束後(制御後)の平均スペクトルを計算
L = 500;
X_in_ave		= mean(abs(X_in(end-L:end,:)),1);	% 最後のLフレーム分のスペクトルを平均
X_out_ave		= mean(abs(X_out(end-L:end,:)),1);	% 最後のLフレーム分のスペクトルを平均
X_lpf_ave		= mean(abs(X_lpf(end-L:end,:)),1);	% 最後のLフレーム分のスペクトルを平均

% 対数スケールのパワースペクトル
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

