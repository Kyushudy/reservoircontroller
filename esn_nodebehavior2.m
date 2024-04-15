clear; clc;
close all;

addpath('./esn/');

%% load reservoir
Nrlist = [10 20 50 500];
SRlist = [1.7 1.1 1.1 1.1];

for k = 1 % 1:39(24), 2:8, 3:2(71 6), 4:98
Nr = Nrlist(k);
SR = SRlist(k);

for No = [24] % 

clear("esn", 'Wcontrol', 'outsin', 'outlorenz');

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];
load(filename, 'esn', 'Wcontrol', 'outsin', 'outlorenz');

if exist("esn", 'var') ~= 1
    disp([filename ' fail in generation']);
    continue;
end
sizeinput = 1;
esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', 1, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', 0.01, 'normmethod', 1, 'ifxnorm', 1);
% esn.Woutmat = Wcontrol;
% S_sin = squeeze(outsin.yout{2}.Values.S_esn.Data)';
% Contribution_sin = abs(Wcontrol(10:end)).*sum(abs(S_sin));
% S_lorenz = squeeze(outlorenz.yout{2}.Values.S_esn.Data)';
% Contribution_lorenz = abs(Wcontrol(10:end)).*sum(abs(S_lorenz));
% transparency = Contribution_sin + Contribution_lorenz;
% transparency = transparency./max(transparency);

%% behavior test % min 40 mid 45 max 50
time = 0:0.01:30;
input = 0*time'; 
input(time>15) = 1;

dt = 0.01;
stoptime = 29;
washout = 0.1*stoptime/dt;
n = 3;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input, input, dt);
esn.traindatacollect("esn.slx", washout);

disp(filename);
figsize = [10,10,2,1.8];
figpos = [0.32 0.39 0.63 0.6];

figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',figsize);
set(gca,'Position', figpos);
set(gcf,'Visible','on');

tstep = 0:0.01:29;
inputstep = esn.train_reservoirReadout(2,1:2901);
p1 = plot(tstep, inputstep, 'k');
p1.LineWidth = 1.2;
grid on;
hold on;
internalstatesstep = esn.train_internalState(1:2901,:);
p2 = plot(tstep, internalstatesstep);
ylabel('S');
xlim([13 20]);
ylim([-1.3 1.3]);

% behavior test2 % min 48 mid 64 max 80
time = 0:0.01:100;
w1 = 1.86304523267102;
w2 = 1.44360739576384;
w3 = 3.54011133985333;
A1 = -0.0490045122748814;
A2 = -0.0895899692005687;
A3 = 0.150760235583392;
input = 5*(A1*sin(w1*time)' + A2*sin(w2*time)' + A3*sin(w3*time)');

stoptime = 100;
washout = 0.1*stoptime/dt;
n = 3;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input, input, dt);
esn.traindatacollect("esn.slx", washout);


figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',figsize);
set(gca,'Position', figpos);
set(gcf,'Visible','on');

tsin = time;
inputsin = esn.train_reservoirReadout(2,:);
p1 = plot(tsin, inputsin, 'k');
p1.LineWidth = 1.2;
grid on;
hold on;
internalstatessin = esn.train_internalState(:,:);
p2 = plot(tsin, internalstatessin);
xlabel('t', 'Position', [6.5 -2]);
ylabel('S');
xlim([5 8]);
ylim([-1.3 1.3]);

%% normalized
maxsin = max(internalstatessin(1000:1500,:));
minsin = min(internalstatessin(1000:1500,:));
for i = 1:Nr
    if internalstatessin(1280,i) < internalstatessin(1021,i)
        num = maxsin(i);
        maxsin(i) = minsin(i);
        minsin(i) = num;
    end
end
maxstep = internalstatesstep(end,:);
minstep = internalstatesstep(1500,:);
normstep = (internalstatesstep - minstep)./(maxstep - minstep);
normsin = ((internalstatessin - minsin)./(maxsin - minsin).*2)-1;

figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',figsize);
set(gca,'Position', figpos);
set(gcf,'Visible','on');

t = 0:0.01:29;
p1 = plot(t,inputstep, 'k');
p1.LineWidth = 1.2;
hold on;
grid on;
p2 = plot(t,normstep);
% xlabel('t');
xlim([13 20]);
% xticks([0.4 0.5]);
ylim([-1 1.8]);
ylabel('S_{normed}');

figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position',figsize);
set(gca,'Position', figpos);
set(gcf,'Visible','on');

t = 0:0.01:100;
p1 = plot(t,inputsin, 'k');
p1.LineWidth = 1.2;
hold on;
grid on;
p2 = plot(t,normsin);
% for i = 1:10
%     p2(i).Color = colors(i,:);
% end
% xlabel('t');
xlim([5 8]);
ylim([-1.3 1.3]);
xlabel('t', 'Position', [6.5 -2]);
ylabel('S_{normed}');

end
end

Y = fft(internalstatessin(1:end,:));
L = size(Y,1);
Fs = 100;
x = Fs/L*(0:L-1);
figure('Color',[1 1 1]);
set(gcf,'unit','centimeters','position', [10 10 8 6]);
% set(gca,'Position', figpos);
set(gcf,'Visible','on');
plot(x,abs(Y));
xlim([0 1]);

function [SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input, tar, dt)
    inputDim = 1;    
    tarDim = 1; 
    
    % input = input*2-1;
    [numx, ~] = size(input);

    time = 0:dt:(numx-1)*dt;

    clear elems;
    for j = 1:inputDim
        elems(j) = Simulink.BusElement;
        elems(j).Name = ['x' num2str(j)];
    end
    SinusoidBus = Simulink.Bus;
    SinusoidBus.Elements = elems;
    clear busin;
    busin.x1 = timeseries(input,time);

    clear elems;
    for j = 1:tarDim
        elems(j) = Simulink.BusElement;
        elems(j).Name = ['x' num2str(j)];
    end
    SinusoidBustar = Simulink.Bus;
    SinusoidBustar.Elements = elems;
    clear busintar;
    busintar.x1 = timeseries(tar,time);

end

function [SinusoidBus, busin, SinusoidBustar, busintar] = create_buscontrol_input(input, tar, dt)
    inputDim = 4;    
    tarDim = 1; 
    
    % input = input*2-1;
    [numx, ~] = size(input);

    time = 0:dt:(numx-1)*dt;

    clear elems;
    for j = 1:inputDim
        elems(j) = Simulink.BusElement;
        elems(j).Name = ['x' num2str(j)];
    end
    SinusoidBus = Simulink.Bus;
    SinusoidBus.Elements = elems;
    clear busin;
    busin.x1 = timeseries(input,time);
    busin.x2 = timeseries(0*input,time);
    busin.x3 = timeseries(0*input,time);
    busin.x4 = timeseries(0*input,time);

    clear elems;
    for j = 1:tarDim
        elems(j) = Simulink.BusElement;
        elems(j).Name = ['x' num2str(j)];
    end
    SinusoidBustar = Simulink.Bus;
    SinusoidBustar.Elements = elems;
    clear busintar;
    busintar.x1 = timeseries(tar,time);

end
