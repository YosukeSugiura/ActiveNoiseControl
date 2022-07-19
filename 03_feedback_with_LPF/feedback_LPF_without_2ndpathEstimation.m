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
N_1st		= 200;				% 騒音制御フィルタ W(z) の次数
N_2nd		= 150;				% ２次経路モデル C_h(z) の次数
N_LPF		= 200;				% 線形予測機の次数

% 適応フィルタの設定
mu			= 0.1;				% 更新ステップサイズ for 騒音制御フィルタ
mu_h		= 0.001;			% 更新ステップサイズ for 2次経路モデル
mu_lpf		= 0.1;				% 更新ステップサイズ for 線形予測器
g_p			= 0.9;				% NLMS用平均パラメータ
L_preEst	= 10000;			% 事前推定に用いる初期サンプル長
%-------------------------------------

%% 騒音の取得
[s,fs]		= audioread('../00_data/cleaner.wav');	% 騒音信号
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
w			= rand(1,N_1st);							% 騒音制御フィルタの係数
ch			= Imp_2nd(1:N_2nd);							% ２次経路モデルの係数 (既知)
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
% -- 計算用 --
out_2nd		= 0;


%% 騒音制御シミュレーション
tic;

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
	d_h			= e_h - y_d;					% d^(n) : e^(n)-y'(n)
	d_h_buf		= [d_h; d_h_buf(1:end-1)];		% バッファ
	
	% -- フィルタード復元騒音+線形予測器 --
	r			= ch * d_h_buf(1:N_2nd);		% d^(n)に2次経路モデル(ch)を畳み込む
	r_h			= h * e_buf3;					% r^(n) : 2次経路モデルの出力にLPFを通す
	e_buf3		= [r; e_buf3(1:end-1)];			% バッファ
	r_buf		= [r_h; r_buf(1:end-1)];		% バッファ (Filtered-X NLMS用)
	 
	% -- Filtered-X NLMSアルゴリズム --
	w			= w - mu * e_h.* r_buf' ./(mean(r_buf.^2)+0.1);	% 更新
	
	% -- LPF更新 --
	h			= h + mu_lpf * (e-e_h) .* e_buf1' ./(mean(e_buf1.^2)+0.1);	% 更新
	e_buf1		= [e; e_buf1(1:end-1)];			% バッファ
	
	in(loop)	= d;
	out(loop)	= e;
	
end

toc;

%% 波形グラフ

% 波形プロット
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('Time [s]');
ylabel('Amplitude');
legend('Output (without ANC)','Output (with ANC)');

% スペクトログラム
figure(2);
[X_in, f, t] = stft_(in, 256, 512, 36, fs);
X_in = 20*log10(abs(X_in)+10^(-5))';
imagesc(t,f,X_in)
ylim([f(1),f(128)])
caxis([-100 50])
colormap hot
axis xy
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogrma of Input Nose');

% スペクトログラム
figure(3);
[X_out, f, t] = stft_(out, 256, 512, 36, fs);
X_out = 20*log10(abs(X_out)+10^(-5))';
imagesc(t,f,X_out)
ylim([f(1),f(128)])
caxis([-100 50])
colormap hot
axis xy
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogrma of Output Cancelled Noise');

%% wav保存
audiowrite('input.wav',in,fs);
audiowrite('output_FB_LPF.wav',out,fs);


