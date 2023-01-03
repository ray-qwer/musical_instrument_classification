[x, fs] = audioread("..\music_samples\piano&other\piano\Piano.ff.E1.aiff");
x= x(:,1).';

outputs = getFeature(x,fs);

% t = [0:length(x)-1]./fs; f= 0:4000;
