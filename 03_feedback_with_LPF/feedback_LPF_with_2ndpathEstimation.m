%
%	能動騒音制御+LPC (フォードバック型)
%	* ２次経路の推定あり(未知とする)
% ----------------------------------------
%	作成者： 杉浦陽介
%	作成日： 2022.7.18
%

clear;
close all;


%% 設定変数 (任意に設定)
%-------------------------------------
% スピーカ・マイク間距離(cm)
Dist_2nd	= 3;				% 2次経路の距離(cm)

% 適応フィルタの次数
N_1st		= 500;				% 騒音制御フィルタ W(z) の次数
N_2nd		= 150;				% ２次経路モデル C_h(z) の次数
N_LPF		= 100;				% 線形予測機の次数

% 適応フィルタの設定
mu			= 1.5;				% 更新ステップサイズ for 騒音制御フィルタ
mu_h		= 0.001;			% 更新ステップサイズ for 2次経路モデル
mu_lpf		= 1.5;				% 更新ステップサイズ for 線形予測器
L_preEst	= 10000;			% 事前推定に用いる初期サンプル長
%-------------------------------------

%% 騒音の取得
[s,fs]		= audioread('../00_data/harmonics.wav');	% 騒音信号
len			= length(s);

%% インパルス応答の取得 (いじらないで)
Imp_2nd		= csvread('../00_data/impulse2.dat');	% ２次経路のインパルス応答

% ２次経路(スピーカ１)のインパルス応答を作成
smpl		= max( [1, floor(Dist_2nd* 0.1/340.29 * fs)] ); % 遅延量
if smpl <= 200
	Imp_2nd		= Imp_2nd(200-smpl:end)';
else
	Imp_2nd		= [zeros(smpl-200,1);Imp_2nd]';
end
L_2nd = length(Imp_2nd);

%% 配列初期化
% -- Filter --
w			= zeros(1,N_1st);							% 騒音制御フィルタの係数
ch			= zeros(1,N_2nd);							% ２次経路モデルの係数 (未知)
h			= zeros(1,N_LPF);							% 線形予測器の係数
% -- Buffer --
y_buf		= zeros(max(L_2nd,N_2nd),1);				% ２次経路バッファ
d_h_buf		= zeros(max(N_1st,N_2nd),1);				% 復元騒音バッファ
r_buf		= zeros(N_1st,1);							% フィルタード復元騒音バッファ
e_buf1		= zeros(N_LPF,1);							% 線形予測器バッファ
e_buf2		= zeros(N_LPF,1);							% 線形予測器バッファ
e_buf3		= zeros(N_LPF,1);							% 線形予測器バッファ
% -- 結果 --
in			= zeros(len,1);								% 誤差マイクでの (誤差信号)
out			= zeros(len,1);								% 結果 (誤差信号)
pred		= zeros(len,1);								% 線形予測器の出力 (誤差信号)
error		= zeros(len,1);								% 誤差
% -- 計算用 --
out_2nd		= 0;

%% 騒音制御シミュレーション
tic;

% == 事前推定 ==
for loop=1:L_preEst-1
	
	% -- 白色雑音 --
	yh			= randn(1);						% 白色雑音
	y_buf		= [yh; y_buf(1:end-1)];			% 白色雑音バッファ (FILO)
	
	% -- ２次経路を通過した白色雑音 --
	eh			= Imp_2nd * y_buf(1:L_2nd);
	
	% -- フィルタード白色雑音 --
	rh			= ch * y_buf(1:N_2nd);	
	
	% -- 誤差 --
	er			= rh - eh;
	
	% -- NLMSアルゴリズム --
	ch		= ch - mu_h * er .* y_buf(1:N_2nd)' ./mean(y_buf(1:N_2nd).^2);	% 更新
	
end

for loop=1:len-N_1st

	% -- 参照信号 --
	x			= s(loop);						% 参照信号
	
	% -- １次経路を通過した騒音 --
	% #フィードバック型では１次経路の推定を行う必要がない．
	d			= x;
	
	% -- 制御信号 --
	y			= w * d_h_buf(1:N_1st);			% y = Σw(i)d^(n-i)
	
	% -- ２次経路を通過した制御信号 --
	y_buf		= [y; y_buf(1:end-1)];			% 制御信号バッファ
	y_h			= Imp_2nd * y_buf(1:L_2nd);		% ２次経路を通過した制御信号
	
	% -- 誤差信号(誤差マイクへの入力信号) --
	e			= d + y_h;						% e(n) = d(n)+y^(n)
	
	% -- 線形予測器を通過した誤差信号
	e_h			= h * e_buf1;					% e^(n) = Σh(i)e(n-i-1)
	
	% -- ２次経路モデルを畳み込んだ制御信号+線形予測器 --
	y_t			= ch * y_buf(1:N_2nd);			% y(n)に2次経路モデル(ch)を畳み込む
	y_d			= h * e_buf2;					% y'(n) : 2次経モデルの出力にLPFを通す
	e_buf2		= [y_t; e_buf2(1:end-1)];		% バッファ
	
	% -- 復元騒音 --
	%d_h			= e_h - y_d;					% d^(n) : e^(n)-y'(n)
	d_h			= e_h - y_t;
	d_h_buf		= [d_h; d_h_buf(1:end-1)];		% バッファ
	
	% -- フィルタード復元騒音+線形予測器 --
	r			= ch * d_h_buf(1:N_2nd);		% d^(n)に2次経路モデル(ch)を畳み込む
	%r_h			= h * e_buf3;					% r^(n) : 2次経路モデルの出力にLPFを通す
	%e_buf3		= [r; e_buf3(1:end-1)];			% バッファ
	 
	% -- Filtered-X NLMSアルゴリズム --
	w			= w - mu * e.* r_buf' ./(sum(r_buf.^2)+1);	% 更新
	r_buf		= [r; r_buf(1:end-1)];		% バッファ (Filtered-X NLMS用)
	%w			= w - mu * e_h .* r_buf' ./(sum(r_buf.^2)+1);	% 更新
	%r_buf		= [r; r_buf(1:end-1)];			% バッファ
	
	% -- LPF更新 --
	h			= h - mu_lpf * (e_h-e) .* e_buf1' ./(sum(e_buf1.^2)+1);	% 更新
	e_buf1		= [e; e_buf1(1:end-1)];			% バッファ
	
	in(loop)	= d;
	out(loop)	= e;
	pred(loop)	= y_t;
	%error(loop)	= e_h-e;
end

toc;

%% 波形のプロット
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('time [s]');
ylabel('Amplitude');
legend('Output (without ANC)','Output (with ANC)');

%% スペクトログラムのプロット
S = 2048;
N = 8192;
figure(2);
[X_in, f, t] = stft_(in, S, N, S/16, fs);
P_in = 20*log10(abs(X_in)+10^(-8))';
imagesc(t,f,P_in(1:N/2,:))
caxis([-100 50])
colormap hot
axis xy
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogrma of Input Nose');

figure(3);
[X_out, f, t] = stft_(out, S, N, S/16, fs);
P_out = 20*log10(abs(X_out)+10^(-8))';
imagesc(t,f,P_out(1:N/2,:))
caxis([-100 50])
colormap hot
axis xy
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogrma of Output Cancelled Noise');

%% スペクトルのプロット
% 収束後(制御後)の平均スペクトルを計算
L = 300;
P_in_ave = 20*log10(mean(abs(X_in(end-L:end,:)),1)+10^(-8));	% 最後のLフレーム分のスペクトルを平均
P_out_ave = 20*log10(mean(abs(X_out(end-L:end,:)),1)+10^(-8));	% 最後のLフレーム分のスペクトルを平均

[X_pred, f, t] = stft_(pred, S, N, S/16, fs);
P_pred_ave = 20*log10(mean(abs(X_pred(end-L:end,:)),1)+10^(-8));

figure(4);
plot(f, P_in_ave(1:N/2), 'LineWidth', 1.5, 'Color','r'); hold on;
plot(f, P_out_ave(1:N/2), 'LineWidth', 1.5, 'Color',[0 0.4470 0.7410]);
plot(f, P_pred_ave(1:N/2), 'LineWidth', 1.5, 'Color',[0.4660 0.6740 0.1880]);
hold off;
xlabel('Frequency [Hz]');
ylabel('Power [dB]');
title('Spectra');
legend('Input','FB-LPF-ANC');
ylim([-35, 40])


%% wav保存
audiowrite('input.wav',in,fs);
audiowrite('output_FB_LPF.wav',out,fs);

