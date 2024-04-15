clear;clc;
close all;

addpath('./esn/');

%% load reservoir
Nrlist = [10 20 50 500];
SRlist = [1.7 1.1 1.1 1.1];

for k = 1:4 % 1:4
Nr = Nrlist(k);
SR = SRlist(k);

for No = 1:100 % 1:100, ESN10 best 39 4 58 42 35, worst 24 75 54 5 22

clear("esn");

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];
load(filename, 'esn');

if exist("esn", 'var') ~= 1
    disp([filename ' fail in generation']);
    nodebehavior_t = nan;
    nodebehavior_inputstep = nan;
    nodebehavior_normstep = nan;
    nodebehavior_inputsin = nan;
    nodebehavior_normsin = nan;
    save(filename, "nodebehavior_t", "nodebehavior_inputstep", "nodebehavior_normstep", ...
        "nodebehavior_inputsin", "nodebehavior_normsin", '-append');
    continue;
end
sizeinput = 1;
esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', 0.01, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', 0.01, 'normmethod', 1, 'ifxnorm', 1);


%% behavior test % min 40 mid 45 max 50
input = zeros(300,1); 
index = 1:300;
input(index(mod(index,100)>49)) = 1;

dt = 0.01;
stoptime = 2;
washout = 0.1*stoptime/dt;
n = 3;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(10:stoptime/dt+9), input(10-n:stoptime/dt+9-n), dt);
esn.traindatacollect("esn.slx", washout);

% figure();
inputstep = esn.train_reservoirReadout(2,1:201);
% plot(inputstep, 'k');
% grid on;
% hold on;
internalstatesstep = esn.train_internalState(1:201,:);
% plot(internalstatesstep);
% title('Internal states of the reservoir');
% xlabel('t');

%% behavior test2 % min 48 mid 64 max 80
index = 1:300;
input = sin(0.1*(index-10))';

stoptime = 2;
washout = 0.1*stoptime/dt;
n = 3;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(10:stoptime/dt+9), input(10-n:stoptime/dt+9-n), dt);
esn.traindatacollect("esn.slx", washout);

% figure();
inputsin = esn.train_reservoirReadout(2,1:201);
% plot(inputsin, 'k');
% grid on;
% hold on;
internalstatessin = esn.train_internalState(1:201,:);
% plot(internalstatessin);
% title('Internal states of the reservoir');
% xlabel('t');

%% normalized
maxsin = max(internalstatessin(50:end,:));
minsin = min(internalstatessin(50:end,:));
for i = 1:Nr
    if internalstatessin(75,i) < internalstatessin(55,i)
        num = maxsin(i);
        maxsin(i) = minsin(i);
        minsin(i) = num;
    end
end
maxstep = internalstatesstep(70,:);
minstep = internalstatesstep(20,:);
normstep = (internalstatesstep - minstep)./(maxstep - minstep);
normsin = ((internalstatessin - minsin)./(maxsin - minsin).*2)-1;

% figure('Color',[1 1 1]);
% % set(gcf,'unit','centimeters','position',[5,5,3,3]);
% % set(gca,'Position', [0.18 0.17 0.75 0.75]);
% % set(gcf,'Visible','on');
% 
t = 0:0.01:2;
% p1 = plot(t,inputstep, 'k');
% p1.LineWidth = 1.2;
% hold on;
% grid on;
% p2 = plot(t,normstep);
% % xlabel('t');
% xlim([0.35 0.55]);
% xticks([0.4 0.5]);
% ylim([-1 2]);
% 
% figure('Color',[1 1 1]);
% % set(gcf,'unit','centimeters','position',[5,5,3,3]);
% % set(gca,'Position', [0.18 0.17 0.75 0.75]);
% % set(gcf,'Visible','on');
% 
% t = 0:0.01:2;
% p1 = plot(t,inputsin, 'k');
% p1.LineWidth = 1.2;
% hold on;
% grid on;
% p2 = plot(t,normsin);
% % for i = 1:10
% %     p2(i).Color = colors(i,:);
% % end
% % xlabel('t');
% xlim([0 1]);
% ylim([-2 2]);

nodebehavior_t = t;
nodebehavior_inputstep = inputstep;
nodebehavior_normstep = normstep;
nodebehavior_inputsin = inputsin;
nodebehavior_normsin = normsin;

disp([filename ' succeed']);
save(filename, "nodebehavior_t", "nodebehavior_inputstep", "nodebehavior_normstep", ...
    "nodebehavior_inputsin", "nodebehavior_normsin", '-append');

end
end





%% function
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