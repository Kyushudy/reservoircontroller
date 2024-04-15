clear;clc;
close all;

addpath('./esn/');

%% load data
Nrlist = [10 20 50 500];
SRlist = [1.7 1.1 1.1 1.1];

for k = 1:4 % 1:4
Nr = Nrlist(k);
SR = SRlist(k);

for No = 1:100 % 1:100

clear("outsin", "outlorenz");

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];
load(filename, 'outsin', 'outlorenz');

if exist("outlorenz", 'var') ~= 1
    disp([filename ' fail in control']);
    edtwsin = nan;
    edtwlorenz = nan;
    save(filename, "edtwsin", "edtwlorenz", '-append');
    continue;
end

disp([filename ' succeed']);

time = squeeze(outsin.yout{3}.Values.r.Time);
r = squeeze(outsin.yout{3}.Values.r.Data(1,1,:));
rdot = squeeze(outsin.yout{3}.Values.r.Data(2,1,:));
x = squeeze(outsin.yout{1}.Values.x_c.Data);
xdot = squeeze(outsin.yout{1}.Values.xdot_c.Data);

edtwsin = dtw(x, r);
disp(['edtwsin = ' num2str(edtwsin)]);

time = squeeze(outlorenz.yout{3}.Values.r.Time);
r = squeeze(outlorenz.yout{3}.Values.r.Data(1,1,:));
rdot = squeeze(outlorenz.yout{3}.Values.r.Data(2,1,:));
x = squeeze(outlorenz.yout{1}.Values.x_c.Data);
xdot = squeeze(outlorenz.yout{1}.Values.xdot_c.Data);

edtwlorenz = dtw(x, r);
disp(['edtwlorenz = ' num2str(edtwlorenz)]);

save(filename, "edtwsin", "edtwlorenz", '-append');

end
end