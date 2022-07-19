%
%	�\���������� (�t�H�[�h�o�b�N�^)
%	* �Q���o�H�̐��肠��(���m�Ƃ���)
% ----------------------------------------
%	�쐬�ҁF ���Y�z��
%	�쐬���F 2019.5.13
%

clear;
close all;


%% �ݒ�ϐ� (�C�ӂɐݒ�)
%-------------------------------------
% �X�s�[�J�E�}�C�N�ԋ���(cm)
Dist_2nd	= 3;				% 2���o�H�̋���(cm)

% �K���t�B���^�̎���
N_1st		= 300;				% ��������t�B���^ W(z) �̎���
N_2nd		= 150;				% �Q���o�H���f�� C_h(z) �̎���

% �K���t�B���^�̐ݒ�
mu			= 0.02;				% �X�V�X�e�b�v�T�C�Y for ��������t�B���^
mu_h		= 0.001;			% �X�V�X�e�b�v�T�C�Y for 2���o�H���f��
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
ch			= zeros(1,N_2nd);							% �Q���o�H���f���̌W�� (���m)
% -- Buffer --
y_buf		= zeros(max(L_2nd,N_2nd),1);				% �Q���o�H�o�b�t�@
d_h_buf		= zeros(max(N_1st,N_2nd),1);				% ���������o�b�t�@
r_buf		= zeros(1, N_1st);							% �t�B���^�[�h���������o�b�t�@
% -- ���� --
in			= zeros(len,1);								% �덷�}�C�N�ł� (�덷�M��)
out			= zeros(len,1);								% ���� (�덷�M��)
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
	y_h			= w * d_h_buf(1:N_1st);
	
	% -- �Q���o�H��ʉ߂�������M�� --
	y_buf		= [y_h; y_buf(1:end-1)];		% ����M���o�b�t�@
	out_2nd		= Imp_2nd * y_buf(1:L_2nd);		% �Q���o�H��ʉ߂�������M��

	% -- �덷�M�� --
	e			= d + out_2nd;
	
	% -- �Q���o�H���f������ݍ��񂾐���M��(=�^�����䉹) --
	y_pseudo	= ch * y_buf(1:N_2nd);
	
	% -- �������� --
	d_h			= e - y_pseudo;
	d_h_buf		= [d_h; d_h_buf(1:end-1)];		% �o�b�t�@
	
	% -- �t�B���^�[�h�������� --
	r			= ch * d_h_buf(1:N_2nd);
	r_buf		= [r, r_buf(1:end-1)];			% �o�b�t�@
	
	% -- Filtered-X NLMS�A���S���Y�� --
	w			= w - mu * e .* r_buf ./(mean(r_buf.^2)+1);	% �X�V

	in(loop)	= d;
	out(loop)	= e;
	
end

toc;

%% �g�`�O���t

% �}�̃v���b�g
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
% �}�̐ݒ�
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('time [s]');
ylabel('Amplitude');
legend('Output (without ANC)','Output (with ANC)');


%% wav�ۑ�
audiowrite('input.wav',in,fs);
audiowrite('output_FB.wav',out,fs);


