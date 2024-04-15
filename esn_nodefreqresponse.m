clear;clc;
% close all;

addpath('./esn/');

%% load reservoir
Nrlist = [10 20 50 500];
SRlist = [1.7 1.1 1.1 1.1];

for k = 3 % 1:4
Nr = Nrlist(k);
SR = SRlist(k);

for No = 2 % 1:100

clear("esn");

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];
load(filename, 'esn');

if exist("esn", 'var') ~= 1
    disp([filename ' fail in generation']);
    % save(filename, "", '-append');
    continue;
end

sizeinput = 1;
esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', 1, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', 0.01, 'normmethod', 1, 'ifxnorm', 1);

w = logspace(-1,2,30);

sim("esn\esn_OnlineFreqRespEstimEx.slx");

freqdata = logsout{1}.Values;

outfreq = cell(Nr, 1);
for i = 1:Nr
    freqdatasave = resample(logsout{4}.Values, 0:0.01:2000);
    freqdata.PlantOutput.Data = squeeze(freqdatasave.Data(i,1,:) - freqdatasave.Data(i,1,200/0.01+1));
    outfreq{i} = frestimate(freqdata,w,'rad/s');
end

disp([filename ' succeed']);
save(filename, "outfreq", '-append');

% figure('Color',[1 1 1]);
% set(gcf,'unit','centimeters','position',[5,5,8,6]);
% % set(gca,'Position', [0.13 0.17 0.75 0.75]);
% set(gcf,'Visible','on');
% 
% for i = 1:10
% [mag,phase,wout] = bode(outfreq{i});
% mag = squeeze(mag);
% phase = squeeze(phase);
% % nn = 30;
% % mag = squeeze(mag(1:nn));
% % phase = squeeze(phase(1:nn));
% % wout = wout(1:nn);
% % w = w(1:nn);
% subplot(2,1,1);
% semilogx(w, 20*log10(mag));
% ylabel('magnitude (dB)');
% hold on;
% subplot(2,1,2);
% if phase(1) > 100
%     phase = phase - 180;
% elseif phase(1) < -100
%     phase = phase + 180;
% end
% semilogx(w, phase);
% xlabel('Frequency (rad/s)');
% ylabel('phase (deg)');
% hold on;
% end

end
end