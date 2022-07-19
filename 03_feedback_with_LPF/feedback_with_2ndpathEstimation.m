%
%	能動騒音制御 (フォードバック型)
%	* ２次経路の推定あり(未知とする)
% ----------------------------------------
%	作成者： 杉浦陽介
%	作成日： 2019.5.13
%

clear;
close all;


%% 設定変数 (任意に設定)
%-------------------------------------
% スピーカ・マイク間距離(cm)
Dist_2nd	= 3;				% 2次経路の距離(cm)

% 適応フィルタの次数
N_1st		= 300;				% 騒音制御フィルタ W(z) の次数
N_2nd		= 150;				% ２次経路モデル C_h(z) の次数

% 適応フィルタの設定
mu			= 0.02;				% 更新ステップサイズ for 騒音制御フィルタ
mu_h		= 0.001;			% 更新ステップサイズ for 2次経路モデル
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
ch			= zeros(1,N_2nd);							% ２次経路モデルの係数 (未知)
% -- Buffer --
y_buf		= zeros(max(L_2nd,N_2nd),1);				% ２次経路バッファ
d_h_buf		= zeros(max(N_1st,N_2nd),1);				% 復元騒音バッファ
r_buf		= zeros(1, N_1st);							% フィルタード復元騒音バッファ
% -- 結果 --
in			= zeros(len,1);								% 誤差マイクでの (誤差信号)
out			= zeros(len,1);								% 結果 (誤差信号)
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
	y_h			= w * d_h_buf(1:N_1st);
	
	% -- ２次経路を通過した制御信号 --
	y_buf		= [y_h; y_buf(1:end-1)];		% 制御信号バッファ
	out_2nd		= Imp_2nd * y_buf(1:L_2nd);		% ２次経路を通過した制御信号

	% -- 誤差信号 --
	e			= d + out_2nd;
	
	% -- ２次経路モデルを畳み込んだ制御信号(=疑似制御音) --
	y_pseudo	= ch * y_buf(1:N_2nd);
	
	% -- 復元騒音 --
	d_h			= e - y_pseudo;
	d_h_buf		= [d_h; d_h_buf(1:end-1)];		% バッファ
	
	% -- フィルタード復元騒音 --
	r			= ch * d_h_buf(1:N_2nd);
	r_buf		= [r, r_buf(1:end-1)];			% バッファ
	
	% -- Filtered-X NLMSアルゴリズム --
	w			= w - mu * e .* r_buf ./(mean(r_buf.^2)+1);	% 更新

	in(loop)	= d;
	out(loop)	= e;
	
end

toc;

%% 波形グラフ

% 図のプロット
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
% 図の設定
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('time [s]');
ylabel('Amplitude');
legend('Output (without ANC)','Output (with ANC)');


%% wav保存
audiowrite('input.wav',in,fs);
audiowrite('output_FB.wav',out,fs);


