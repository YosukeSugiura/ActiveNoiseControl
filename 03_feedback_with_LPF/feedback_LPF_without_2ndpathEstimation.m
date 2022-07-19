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
N_1st		= 200;				% ��������t�B���^ W(z) �̎���
N_2nd		= 150;				% �Q���o�H���f�� C_h(z) �̎���
N_LPF		= 200;				% ���`�\���@�̎���

% �K���t�B���^�̐ݒ�
mu			= 0.1;				% �X�V�X�e�b�v�T�C�Y for ��������t�B���^
mu_h		= 0.001;			% �X�V�X�e�b�v�T�C�Y for 2���o�H���f��
mu_lpf		= 0.1;				% �X�V�X�e�b�v�T�C�Y for ���`�\����
g_p			= 0.9;				% NLMS�p���σp�����[�^
L_preEst	= 10000;			% ���O����ɗp���鏉���T���v����
%-------------------------------------

%% �����̎擾
[s,fs]		= audioread('../00_data/cleaner.wav');	% �����M��
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
w			= rand(1,N_1st);							% ��������t�B���^�̌W��
ch			= Imp_2nd(1:N_2nd);							% �Q���o�H���f���̌W�� (���m)
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
% -- �v�Z�p --
out_2nd		= 0;


%% ��������V�~�����[�V����
tic;

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
	d_h			= e_h - y_d;					% d^(n) : e^(n)-y'(n)
	d_h_buf		= [d_h; d_h_buf(1:end-1)];		% �o�b�t�@
	
	% -- �t�B���^�[�h��������+���`�\���� --
	r			= ch * d_h_buf(1:N_2nd);		% d^(n)��2���o�H���f��(ch)����ݍ���
	r_h			= h * e_buf3;					% r^(n) : 2���o�H���f���̏o�͂�LPF��ʂ�
	e_buf3		= [r; e_buf3(1:end-1)];			% �o�b�t�@
	r_buf		= [r_h; r_buf(1:end-1)];		% �o�b�t�@ (Filtered-X NLMS�p)
	 
	% -- Filtered-X NLMS�A���S���Y�� --
	w			= w - mu * e_h.* r_buf' ./(mean(r_buf.^2)+0.1);	% �X�V
	
	% -- LPF�X�V --
	h			= h + mu_lpf * (e-e_h) .* e_buf1' ./(mean(e_buf1.^2)+0.1);	% �X�V
	e_buf1		= [e; e_buf1(1:end-1)];			% �o�b�t�@
	
	in(loop)	= d;
	out(loop)	= e;
	
end

toc;

%% �g�`�O���t

% �g�`�v���b�g
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('Time [s]');
ylabel('Amplitude');
legend('Output (without ANC)','Output (with ANC)');

% �X�y�N�g���O����
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

% �X�y�N�g���O����
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

%% wav�ۑ�
audiowrite('input.wav',in,fs);
audiowrite('output_FB_LPF.wav',out,fs);


