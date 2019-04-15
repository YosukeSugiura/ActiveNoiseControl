%
%	�\���������� (�t�H�[�h�t�H���[�h�^)
%	* �Q���o�H�̐��肠��(�V�X�e������@)
% ----------------------------------------
%	�쐬�ҁF ���Y�z��
%	�쐬���F 2019.4.11
%

clear;
close all;


%% �ݒ�ϐ� (�C�ӂɐݒ�)
%-------------------------------------
% �X�s�[�J�E�}�C�N�ԋ���(cm)
Dist_1st	= 10;				% 1���o�H�̋���(cm)
Dist_2nd	= 3;				% 2���o�H�̋���(cm)

% �K���t�B���^�̎���
N_1st		= 120;				% ��������t�B���^ W(z) �̎���
N_2nd		= 100;				% �Q���o�H���f�� C_h(z) �̎���

% �K���t�B���^�̐ݒ�
mu			= 0.02;				% �X�V�X�e�b�v�T�C�Y for ��������t�B���^
mu_h		= 0.01;				% �X�V�X�e�b�v�T�C�Y for 2���o�H���f��
g_p			= 0.9;				% NLMS�p���σp�����[�^
L_preEst	= 10000;			% ���O����ɗp���鏉���T���v����
%-------------------------------------

%% �����̎擾
[s,fs]		= audioread('../00_data/cleaner.wav');	% �����M��
len			= length(s);

%% �C���p���X�����̎擾 (������Ȃ���)
Imp_1st		= csvread('../00_data/impulse1.dat');	% �P���o�H�̃C���p���X����
Imp_2nd		= csvread('../00_data/impulse2.dat');	% �Q���o�H�̃C���p���X����

% �P���o�H�̃C���p���X�������쐬
smpl		= max( [1, floor(Dist_1st* 0.1/340.29 * fs)] ); % �x����
if smpl <= 200
	Imp_1st		= Imp_1st(200-smpl:end)';
else
	Imp_1st		= [zeros(smpl-200,1);Imp_1st]';
end
L_1st = length(Imp_1st);

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
x_buf		= zeros(max([L_1st,N_1st, N_2nd]),1);		% �Q�ƐM���o�b�t�@
xh_buf		= zeros(max([L_2nd,N_2nd]),1);				% ���O����p �t�B���^�[�h���F�G���o�b�t�@
y_buf		= zeros(max(L_2nd,N_2nd),1);				% �Q���o�H�o�b�t�@
r_buf		= zeros(1, N_1st);
% -- ���� --
in			= zeros(len,1);								% �덷�}�C�N�ł� (�덷�M��)
out			= zeros(len,1);								% ���� (�덷�M��)
% -- �v�Z�p --
p_in		= 1;
p_1st		= 1;
out_2nd		= 0;


%% ��������V�~�����[�V����
tic;

% == ���O���� ==
for loop=1:L_preEst-1
	
	% -- ���F�G�� --
	xh			= randn(1);						% ���F�G��
	xh_buf		= [xh; xh_buf(1:end-1)];		% ���F�G���o�b�t�@ (FILO)
	
	% -- �Q���o�H��ʉ߂������F�G�� --
	eh			= Imp_2nd * xh_buf(1:L_2nd);
	
	% -- �t�B���^�[�h���F�G�� --
	rh			= ch * xh_buf(1:N_2nd);	
	
	% -- �덷 --
	er			= rh - eh;
	
	% -- NLMS�A���S���Y�� --
	ch		= ch - mu_h * er .* xh_buf(1:N_2nd)' ./mean(xh_buf(1:N_2nd).^2);	% �X�V
	
end

% == �������� ==
for loop=1:len
		

	% -- �Q�ƐM�� --
	x			= s(loop);						% �Q�ƐM��
	x_buf		= [x; x_buf(1:end-1)];			% �Q�ƐM���o�b�t�@ (FILO)
	
	% -- �P���o�H��ʉ߂������� --
	out_1st		= Imp_1st * x_buf(1:L_1st);
	
	% -- ����M�� --
	out_filter	= w * x_buf(1:N_1st);
	
	% -- �Q���o�H��ʉ߂�������M�� --
	y_buf		= [out_filter; y_buf(1:end-1)];	% ����M���o�b�t�@
	out_2nd		= Imp_2nd * y_buf(1:L_2nd);		% �Q���o�H��ʉ߂�������M��

	% -- �덷�M�� --
	e			= out_1st + out_2nd;
	
	% -- �t�B���^�[�h�Q�ƐM�� --
	r			= ch * x_buf(1:N_2nd);			% �t�B���^�[�h�Q�ƐM��
	r_buf		= [r, r_buf(1:end-1)];			% �o�b�t�@
		
	% -- Filtered-X NLMS�A���S���Y�� --
	w			= w - mu * e .* r_buf ./mean(r_buf.^2);	% �X�V

	in(loop)	= out_1st;
	out(loop)	= e;
	
end

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

% �}�̃v���b�g
figure(2);
plot(Imp_2nd); hold on;
plot(ch); hold off;
% �}�̐ݒ�
title('Impulse Response');
xlim([1, max(N_2nd,L_2nd)]);
xlabel('Samples');
ylabel('Amplitude');
legend('True','Estimated');


%% wav�ۑ�
audiowrite('input.wav',in,fs);
audiowrite('output.wav',out,fs);


