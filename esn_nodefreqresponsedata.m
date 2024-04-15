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

clear("outsin", "outlorenz");

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];
load(filename, 'esn', 'outfreq');

if exist("outfreq", 'var') ~= 1
    disp([filename ' fail in freqresponse']);
    cmagdistri = nan;
    cphasedelaydistri = nan;
    maglist = zeros(30,Nr);
    phaselist = zeros(30,Nr);
    save(filename, "maglist", "phaselist", '-append');
    % save(filename, "cmagdistri", "cphasedelaydistri", '-append');
    continue;
end

maglist = zeros(30,Nr);
phaselist = zeros(30,Nr);
for i = 1:Nr
    [mag,phase,wout] = bode(outfreq{i});
    mag = squeeze(mag);
    phase = squeeze(phase);
    if phase(1) > 100
        phase = phase - 180;
    elseif phase(1) < -100
        phase = phase + 180;
    end
    maglist(:,i) = mag;
    phaselist(:,i) = phase;
end

% cmagdistri = var(maglist, 1, "all");
% cphasedelaydistri = var(phaselist, 1, "all");

disp([filename ' succeed']);
w = logspace(-1,2,30);
save(filename,"w", "maglist", "phaselist", '-append');
% save(filename, "cmagdistri", "cphasedelaydistri", '-append');

figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',[5,5,8,6]);
% set(gca,'Position', [0.13 0.17 0.75 0.75]);
set(gcf,'Visible','on');

for i = 1:50
w = logspace(-1,2,30);
mag = maglist(:,i);
phase = phaselist(:,i);
subplot(2,1,1);
semilogx(w, 20*log10(mag));
ylabel('magnitude (dB)');
hold on;
subplot(2,1,2);
if phase(1) > 100
    phase = phase - 180;
elseif phase(1) < -100
    phase = phase + 180;
end
semilogx(w, phase);
xlabel('Frequency (rad/s)');
ylabel('phase (deg)');
hold on;
end

end
end