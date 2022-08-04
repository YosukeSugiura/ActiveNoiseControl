%
%	�\����������+LPC (�t�H�[�h�o�b�N�^)
%	* �Q���o�H�̐��肠��(���m�Ƃ���)
% ----------------------------------------
%	�쐬�ҁF ���Y�z��
%	�쐬���F 2022.7.18
%

clear;
close all;


%% �ݒ�ϐ� (�C�ӂɐݒ�)
%-------------------------------------
% �X�s�[�J�E�}�C�N�ԋ���(cm)
Dist_2nd	= 3;				% 2���o�H�̋���(cm)

% �K���t�B���^�̎���
N_1st		= 500;				% ��������t�B���^ W(z) �̎���
N_2nd		= 150;				% �Q���o�H���f�� C_h(z) �̎���
N_LPF		= 100;				% ���`�\���@�̎���

% �K���t�B���^�̐ݒ�
mu			= 1.5;				% �X�V�X�e�b�v�T�C�Y for ��������t�B���^
mu_h		= 0.001;			% �X�V�X�e�b�v�T�C�Y for 2���o�H���f��
mu_lpf		= 1.5;				% �X�V�X�e�b�v�T�C�Y for ���`�\����
L_preEst	= 10000;			% ���O����ɗp���鏉���T���v����
%-------------------------------------

%% �����̎擾
[s,fs]		= audioread('../00_data/harmonics.wav');	% �����M��
len			= length(s);

%% �C���p���X�����̎擾 (������Ȃ���)
Imp_2nd		= csvread('../00_data/impulse2.dat');	% �Q���o�H�̃C���p���X����

% �Q���o�H(�X�s�[�J�P)�̃C���p���X�������쐬
smpl		= max( [1, floor(Dist_2nd* 0.1/340.29 * fs)] ); % �x����
if smpl <= 200
	Imp_2nd		= Imp_2nd(200-smpl:end)';
else
	Imp_2nd		= [zeros(smpl-200,1);Imp_2nd]';
end
L_2nd = length(Imp_2nd);

%% �z�񏉊���
% -- Filter --
w			= zeros(1,N_1st);							% ��������t�B���^�̌W��
ch			= zeros(1,N_2nd);							% �Q���o�H���f���̌W�� (���m)
h			= zeros(1,N_LPF);							% ���`�\����̌W��
% -- Buffer --
y_buf		= zeros(max(L_2nd,N_2nd),1);				% �Q���o�H�o�b�t�@
d_h_buf		= zeros(max(N_1st,N_2nd),1);				% ���������o�b�t�@
r_buf		= zeros(N_1st,1);							% �t�B���^�[�h���������o�b�t�@
e_buf1		= zeros(N_LPF,1);							% ���`�\����o�b�t�@
e_buf2		= zeros(N_LPF,1);							% ���`�\����o�b�t�@
e_buf3		= zeros(N_LPF,1);							% ���`�\����o�b�t�@
% -- ���� --
in			= zeros(len,1);								% �덷�}�C�N�ł� (�덷�M��)
out			= zeros(len,1);								% ���� (�덷�M��)
pred		= zeros(len,1);								% ���`�\����̏o�� (�덷�M��)
error		= zeros(len,1);								% �덷
% -- �v�Z�p --
out_2nd		= 0;

%% ��������V�~�����[�V����
tic;

% == ���O���� ==
for loop=1:L_preEst-1
	
	% -- ���F�G�� --
	yh			= randn(1);						% ���F�G��
	y_buf		= [yh; y_buf(1:end-1)];			% ���F�G���o�b�t�@ (FILO)
	
	% -- �Q���o�H��ʉ߂������F�G�� --
	eh			= Imp_2nd * y_buf(1:L_2nd);
	
	% -- �t�B���^�[�h���F�G�� --
	rh			= ch * y_buf(1:N_2nd);	
	
	% -- �덷 --
	er			= rh - eh;
	
	% -- NLMS�A���S���Y�� --
	ch		= ch - mu_h * er .* y_buf(1:N_2nd)' ./mean(y_buf(1:N_2nd).^2);	% �X�V
	
end

for loop=1:len-N_1st

	% -- �Q�ƐM�� --
	x			= s(loop);						% �Q�ƐM��
	
	% -- �P���o�H��ʉ߂������� --
	% #�t�B�[�h�o�b�N�^�ł͂P���o�H�̐�����s���K�v���Ȃ��D
	d			= x;
	
	% -- ����M�� --
	y			= w * d_h_buf(1:N_1st);			% y = ��w(i)d^(n-i)
	
	% -- �Q���o�H��ʉ߂�������M�� --
	y_buf		= [y; y_buf(1:end-1)];			% ����M���o�b�t�@
	y_h			= Imp_2nd * y_buf(1:L_2nd);		% �Q���o�H��ʉ߂�������M��
	
	% -- �덷�M��(�덷�}�C�N�ւ̓��͐M��) --
	e			= d + y_h;						% e(n) = d(n)+y^(n)
	
	% -- ���`�\�����ʉ߂����덷�M��
	e_h			= h * e_buf1;					% e^(n) = ��h(i)e(n-i-1)
	
	% -- �Q���o�H���f������ݍ��񂾐���M��+���`�\���� --
	y_t			= ch * y_buf(1:N_2nd);			% y(n)��2���o�H���f��(ch)����ݍ���
	y_d			= h * e_buf2;					% y'(n) : 2���o���f���̏o�͂�LPF��ʂ�
	e_buf2		= [y_t; e_buf2(1:end-1)];		% �o�b�t�@
	
	% -- �������� --
	%d_h			= e_h - y_d;					% d^(n) : e^(n)-y'(n)
	d_h			= e_h - y_t;
	d_h_buf		= [d_h; d_h_buf(1:end-1)];		% �o�b�t�@
	
	% -- �t�B���^�[�h��������+���`�\���� --
	r			= ch * d_h_buf(1:N_2nd);		% d^(n)��2���o�H���f��(ch)����ݍ���
	%r_h			= h * e_buf3;					% r^(n) : 2���o�H���f���̏o�͂�LPF��ʂ�
	%e_buf3		= [r; e_buf3(1:end-1)];			% �o�b�t�@
	 
	% -- Filtered-X NLMS�A���S���Y�� --
	w			= w - mu * e.* r_buf' ./(sum(r_buf.^2)+1);	% �X�V
	r_buf		= [r; r_buf(1:end-1)];		% �o�b�t�@ (Filtered-X NLMS�p)
	%w			= w - mu * e_h .* r_buf' ./(sum(r_buf.^2)+1);	% �X�V
	%r_buf		= [r; r_buf(1:end-1)];			% �o�b�t�@
	
	% -- LPF�X�V --
	h			= h - mu_lpf * (e_h-e) .* e_buf1' ./(sum(e_buf1.^2)+1);	% �X�V
	e_buf1		= [e; e_buf1(1:end-1)];			% �o�b�t�@
	
	in(loop)	= d;
	out(loop)	= e;
	pred(loop)	= y_t;
	%error(loop)	= e_h-e;
end

toc;

%% �g�`�̃v���b�g
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('time [s]');
ylabel('Amplitude');
legend('Output (without ANC)','Output (with ANC)');

%% �X�y�N�g���O�����̃v���b�g
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

%% �X�y�N�g���̃v���b�g
% ������(�����)�̕��σX�y�N�g�����v�Z
L = 300;
P_in_ave = 20*log10(mean(abs(X_in(end-L:end,:)),1)+10^(-8));	% �Ō��L�t���[�����̃X�y�N�g���𕽋�
P_out_ave = 20*log10(mean(abs(X_out(end-L:end,:)),1)+10^(-8));	% �Ō��L�t���[�����̃X�y�N�g���𕽋�

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


%% wav�ۑ�
audiowrite('input.wav',in,fs);
audiowrite('output_FB_LPF.wav',out,fs);

