clear; clc;
close all;

addpath('./esn/');

%% load reservoir
Nrlist = [10 20 50 500];
SRlist = [1.7 1.1 1.1 1.1];

for k = 1:4 % 1:4
Nr = Nrlist(k);
SR = SRlist(k);

for No = 1:100 % 1:100

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];

clear("esn");
load(filename, 'esn');

if exist("esn", 'var') ~= 1
    disp([filename ' fail in generation']);
    continue;
end
sizeinput = 1;
esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', 1, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', 0.01, 'normmethod', 1, 'ifxnorm', 1);

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

tstep = 0:0.01:29;
inputstep = esn.train_reservoirReadout(2,1:2901);
internalstatesstep = esn.train_internalState(1:2901,:);

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

tsin = time;
inputsin = esn.train_reservoirReadout(2,:);
internalstatessin = esn.train_internalState(:,:);

%% normalized
maxsin = max(internalstatessin(1000:1500,:));
minsin = min(internalstatessin(1000:1500,:));
for i = 1:esn.Nr
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

save(filename, 'tsin', 'tstep', 'inputstep', 'inputsin', 'internalstatesstep', 'internalstatessin', 'normstep', 'normsin', '-append');

end
end

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
