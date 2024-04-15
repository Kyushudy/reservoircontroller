clear;clc;
close all;

addpath('./esn/');

filename = 'esnseed\esn_Nr50SR11No2.mat';

load(filename, 'esn');

sizeinput = 1;
stoptime = 20000;
timeconst = 1;
dt = 10;

load("esn\reservoircapabilities.mat");

%% STM 1
data = data_stm;
n = 1;

esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', timeconst, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', dt, 'normmethod', 1, 'ifxnorm', 1);

washout = 0.1*stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1:stoptime/dt), data(1:stoptime/dt,n), dt);

esn.traindatacollect("esn.slx", washout);

[trainout, trY] = esn.train();

datanum = stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1+datanum:stoptime/dt+datanum), data(1+datanum:stoptime/dt+datanum,n), dt);

[predictout, prY] = esn.predict("esn.slx");
predictout{1} = double(predictout{1}>0.5);

coeff = cov(predictout{1}(washout+1:end), prY{1}(washout+1:end));
coeff_STM1 = coeff(1,2)*coeff(1,2)/coeff(1,1)/coeff(2,2);
internalState_STM1 = esn.train_internalState;
Wout_STM1 = esn.Wout{1};

%% STM 3
data = data_stm;
n = 3;

esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', timeconst, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', dt, 'normmethod', 1, 'ifxnorm', 1);

washout = 0.1*stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1:stoptime/dt), data(1:stoptime/dt,n), dt);

esn.traindatacollect("esn.slx", washout);

[trainout, trY] = esn.train();

datanum = stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1+datanum:stoptime/dt+datanum), data(1+datanum:stoptime/dt+datanum,n), dt);

[predictout, prY] = esn.predict("esn.slx");
predictout{1} = double(predictout{1}>0.5);

coeff = cov(predictout{1}(washout+1:end), prY{1}(washout+1:end));
coeff_STM3 = coeff(1,2)*coeff(1,2)/coeff(1,1)/coeff(2,2);
internalState_STM3 = esn.train_internalState;
Wout_STM3 = esn.Wout{1};

%% PC 1
data = data_pc;
n = 1;

esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', timeconst, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', dt, 'normmethod', 1, 'ifxnorm', 1);

washout = 0.1*stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1:stoptime/dt), data(1:stoptime/dt,n), dt);

esn.traindatacollect("esn.slx", washout);

[trainout, trY] = esn.train();

datanum = stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1+datanum:stoptime/dt+datanum), data(1+datanum:stoptime/dt+datanum,n), dt);

[predictout, prY] = esn.predict("esn.slx");
predictout{1} = double(predictout{1}>0.5);

coeff = cov(predictout{1}(washout+1:end), prY{1}(washout+1:end));
coeff_PC1 = coeff(1,2)*coeff(1,2)/coeff(1,1)/coeff(2,2);
internalState_PC1 = esn.train_internalState;
Wout_PC1 = esn.Wout{1};

%% PC 3
data = data_pc;
n = 3;

esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', timeconst, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', dt, 'normmethod', 1, 'ifxnorm', 1);

washout = 0.1*stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1:stoptime/dt), data(1:stoptime/dt,n), dt);

esn.traindatacollect("esn.slx", washout);

[trainout, trY] = esn.train();

datanum = stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1+datanum:stoptime/dt+datanum), data(1+datanum:stoptime/dt+datanum,n), dt);

[predictout, prY] = esn.predict("esn.slx");
predictout{1} = double(predictout{1}>0.5);

coeff = cov(predictout{1}(washout+1:end), prY{1}(washout+1:end));
coeff_PC3 = coeff(1,2)*coeff(1,2)/coeff(1,1)/coeff(2,2);
internalState_PC3 = esn.train_internalState;
Wout_PC3 = esn.Wout{1};

%% control
load(filename, 'outsin', 'outlorenz', 'Wcontrol');
internalState_sin = squeeze(outsin.yout{2}.Values.S_esn.Data);
Wout_sin = Wcontrol;
internalState_lorenz = squeeze(outlorenz.yout{2}.Values.S_esn.Data);
Wout_lorenz = Wcontrol;


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