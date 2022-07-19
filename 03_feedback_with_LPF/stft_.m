function [X, f, t] =stft_(x, N, L, S, fs)
%	STFT
%	x  : input signal
%	N  : Segment length or Window
%	L  : FFT length (>=N)
%	S  : Shift length
%	fs : Sampling frequency


% Setting parameters
if length(N) > 1
	W = N / mean(N);
	N = length(N);
else
	W = hanning(N);
end

% Expectation
if S < 1
	error('Please set (Shift size) > 0')	
end

if L < N
	error('Please set FFT size >= segment size')
end

% Setting
Frames = ceil( (length(x) - N) / S ) + 1;
X = zeros(Frames, L);
n = (1:N);

% Array for FFT
for i = 1:Frames
	Over = (N+(i-1)*S) - length(x);
	if Over > 0
		X(i, 1:N-Over) = W(1:N-Over).*x(1+(i-1)*S:end);
	else
		X(i, 1:N) = W.*x(n+(i-1)*S);
	end
end

% FFT
X = fft(X, L, 2);

f = fs/L .*(0:L-1);
f = f(1:end/2);
t = (0:Frames-1) .* (S/fs);

