%
%	�����g�{�K�E�X���z���C�g�m�C�Y �����\�[�X�R�[�h
% ----------------------------------------
%	�쐬�ҁF ���Y�z��
%	�쐬���F 2019.9.25
%

clear;
close all;


%% �ݒ�ϐ� (�C�ӂɐݒ�)
%-------------------------------------
% wav�̐ݒ�
Time_length		= 5.0;				%	wav�̒���(�b)
Sampling_freq	= 16000;			%	�T���v�����O���g��

% �����g�m�C�Y�̐ݒ�
Sin_freq		= 700*(1:10);		%	�����g�̎��g��(�z��)
Sin_phase		= 2*pi*rand(1,10);	%	�����g�̈ʑ�(�z��)
Sin_amp			= 0.8.^(1:10);		%	�����g�̐U��(�z��)

% �K�E�X���z���C�g�m�C�Y�̐ݒ�
White_amp		= 0.5;				%	�K�E�X���z���C�g�m�C�Y�̐U��
%-------------------------------------

%% �m�C�Y����
Sample			= round(Time_length * Sampling_freq);	%	�T���v����

% ���������g�m�C�Y
Sinusoids		= zeros(Sample,1);
for i=1:Sample
	Sinusoids(i) = sum(Sin_amp .* sin( 2*pi * i * Sin_freq./Sampling_freq + Sin_phase ));	% ���������g�m�C�Y
end

% �z���C�g�m�C�Y
White			= White_amp * randn(Sample,1);

% �������킹���m�C�Y
Noise			= White + Sinusoids;

% �m�C�Y�̐U���̐��K��
Normalized_Pow	= 0.3;				% ���K���p�����[�^
Noise			= Normalized_Pow * Noise./ max(abs(Noise));


% wav�ւ̏����o��
audiowrite('artificial_harmonic.wav',Noise,Sampling_freq);


