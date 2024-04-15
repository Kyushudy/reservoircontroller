clear; clc;
close all;

%% Text Size
set(0,'DefaultAxesFontsize',8);
set(0,'DefaultTextFontsize',8);

%% Text Fonts
set(0,'DefaultTextFontname','Arial');
set(0,'DefaultAxesFontname','Arial');

Nrlist = [10 20 50 500];
SRlist = [1.7 1.1 1.1 1.1];

CRlistESN20 = zeros(100,1);

for k = 2 % 1:4
Nr = Nrlist(k);
SR = SRlist(k);

for No = 1:100 % 1:100

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];

figsize = [10 10 3.5 3.5];
figsize2 = [10 15 3.5 3.5];
figpos = [0.34 0.27 0.6 0.6];

load("data\fig2_robot_test.mat");

Y = fft(x_sin(:,1:end)');
L = size(Y,1);
Fs = 100;
x = Fs/L*(0:L-1);

xlimit = 1:1000;
Yrob = abs(Y(xlimit,:))/max(abs(Y(xlimit,:)), [], "all");
Yrob_m = max(Yrob, [], 2);

% figure('Color',[1 1 1]);
% set(gcf,'unit','centimeters','position', figsize);
% set(gca,'Position', figpos);
% set(gcf,'Visible','on');
% plot(x(xlimit),Yrob_m);
% % plot(x(xlimit),abs(Y(xlimit,:)));
% xlim([0 1]);
% ylim([0 1.2]);
% ylabel("|fft(x)|");
% xlabel("f (Hz)");
% title("Robot FFT");

load(filename);

disp(filename);
disp(edtwlorenz);

Y = fft(internalstatessin(1:end,:));
L = size(Y,1);
Fs = 100;
x = Fs/L*(0:L-1);

Yres = abs(Y(xlimit,:))/max(abs(Y(xlimit,:)), [], "all");
Yres_m = max(Yres, [], 2);

% figure('Color',[1 1 1]);
% set(gcf,'unit','centimeters','position', figsize2);
% set(gca,'Position', figpos);
% set(gcf,'Visible','on');
% plot(x(xlimit),Yres_m);
% % plot(x(xlimit),abs(Y(xlimit,:)));
% xlim([0 1]);
% ylim([0 1.2]);
% ylabel("|fft(S)|");
% xlabel("f (Hz)");
% title("??? Reservoir");

CR = sum(min(Yrob_m, Yres_m))/sum(Yrob_m);
disp(CR);
save(filename, 'CR', '-append');

CRlistESN20(No) = CR;

end

end