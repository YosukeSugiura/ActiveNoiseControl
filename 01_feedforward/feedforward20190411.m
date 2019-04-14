%
%	能動騒音制御 (フォードフォワード型)
%	* ２次経路の推定なし(既知とする)
% ----------------------------------------
%	作成者： 杉浦陽介
%	作成日： 2019.4.11
%

clear;
close all;


%% 設定変数 (任意に設定)
%-------------------------------------
% スピーカ・マイク間距離(cm)
Dist_1st	= 5;				% 1次経路の距離(cm)
Dist_2nd	= 3;				% 2次経路の距離(cm)

% 適応フィルタの次数
N_1st		= 120;				% 騒音制御フィルタ W(z) の次数
N_2nd		= 100;				% ２次経路モデル C_h(z) の次数

% 適応フィルタの設定
mu			= 0.1;				% 更新ステップサイズ for 騒音制御フィルタ
g_p			= 0.9;				% NLMS用平均パラメータ
%-------------------------------------

%% 騒音の取得
[s,fs]		= audioread('../00_data/cleaner.wav');	% 騒音信号
len			= length(s);

%% インパルス応答の取得 (いじらないで)
Imp_1st		= csvread('../00_data/impulse1.dat');	% １次経路のインパルス応答
Imp_2nd		= csvread('../00_data/impulse2.dat');	% ２次経路のインパルス応答

% １次経路のインパルス応答を作成
smpl		= max( [1, floor(Dist_1st* 0.1/340.29 * fs)] ); % 遅延量
if smpl <= 200
	Imp_1st		= Imp_1st(200-smpl:end)';
else
	Imp_1st		= [zeros(smpl-200,1);Imp_1st]';
end
L_1st = length(Imp_1st);

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
c_h			= Imp_2nd(1:N_2nd);							% ２次経路モデルの係数 (既知)
% -- Buffer --
x_buf		= zeros(max([L_1st,N_1st, N_2nd]),1);		% 参照信号バッファ
y_buf		= zeros(max(L_2nd,N_2nd),1);				% ２次経路バッファ
r_buf	= zeros(1, N_1st);
% -- 結果 --
in			= zeros(len,1);								% 誤差マイクでの (誤差信号)
out			= zeros(len,1);								% 結果 (誤差信号)
% -- 計算用 --
p_in		= 1;
p_1st		= 1;
out_2nd		= 0;


%% 騒音制御シミュレーション
tic;

for loop=1:len-N_1st

	% -- 参照信号 --
	x			= s(loop);						% 参照信号
	x_buf		= [x; x_buf(1:end-1)];			% 参照信号バッファ (FILO)
	
	% -- １次経路を通過した騒音 --
	out_1st		= Imp_1st * x_buf(1:L_1st);
	
	% -- 制御信号 --
	out_filter	= w * x_buf(1:N_1st);
	
	% -- ２次経路を通過した制御信号 --
	y_buf		= [out_filter; y_buf(1:end-1)];	% 制御信号バッファ
	out_2nd		= Imp_2nd * y_buf(1:L_2nd);		% ２次経路を通過した制御信号

	% -- 誤差信号 --
	e			= out_1st + out_2nd;
	
	% -- フィルタード参照信号 --
	r			= c_h * x_buf(1:N_2nd);			% フィルタード参照信号
	r_buf		= [r, r_buf(1:end-1)];			% バッファ
	
	% -- Filtered-X NLMSアルゴリズム --
	w		= w - mu * e .* r_buf ./mean(x_buf(1:N_1st).^2);	% 更新

	in(loop)	= out_1st;
	out(loop)	= e;
	
end

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
audiowrite('output.wav',out,fs);

