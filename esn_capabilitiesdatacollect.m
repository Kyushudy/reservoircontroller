clear;clc;
close all;

addpath('./esn/');

%% esn create

Nrlist = [10 20 50 500];
SRlist = [1.7 1.1 1.1 1.1];

for k = 1:4
Nr = Nrlist(k);
SR = SRlist(k);

for No = 1:100

clear('esn');

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];
load(filename, 'esn');

sizeinput = 1;
stoptime = 20000;
timeconst = 1;
dt = 10;

%% capability task
load("esn\reservoircapabilities.mat");
stm_trainerror = zeros(10,1);
pc_trainerror = zeros(10,1);
stm_predicterror = zeros(10,1);
pc_predicterror = zeros(10,1);
stm_traincoeff = zeros(10,1);
pc_traincoeff = zeros(10,1);
stm_predictcoeff = zeros(10,1);
pc_predictcoeff = zeros(10,1);

for j = 1:10
data = data_stm;
n = j;

esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', timeconst, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', dt, 'normmethod', 1, 'ifxnorm', 1);

% esn.Win = zeros(Nr,1);
% esn.Wb = zeros(Nr,1);
% esn.Wr = zeros(Nr,Nr);

washout = 0.1*stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1:stoptime/dt), data(1:stoptime/dt,n), dt);

esn.traindatacollect("esn.slx", washout);

[trainout, trY] = esn.train();
% trainout{1} = double(trainout{1}>0.5);

datanum = stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1+datanum:stoptime/dt+datanum), data(1+datanum:stoptime/dt+datanum,n), dt);

[predictout, prY] = esn.predict("esn.slx");
predictout{1} = double(predictout{1}>0.5);


for i = 1:esn.sizeoutput
    stm_trainerror(j) = immse(trainout{i}(washout+1:end), trY{i}(washout+1:end));
    % fprintf('Train error of out %d: %g\n', i, stm_trainerror(j));
    coeff = cov(trainout{i}(washout+1:end), trY{i}(washout+1:end));
    stm_traincoeff(j) = coeff(1,2)*coeff(1,2)/coeff(1,1)/coeff(2,2);
    % fprintf('Train coeff of out %d: %g\n', i, stm_traincoeff(j));
end

for i = 1:esn.sizeoutput
    stm_predicterror(j) = immse(predictout{i}(washout+1:end), prY{i}(washout+1:end));
    % fprintf('Test error of out %d: %g\n', i, stm_predicterror(j));
    coeff = cov(predictout{i}(washout+1:end), prY{i}(washout+1:end));
    stm_predictcoeff(j) = coeff(1,2)*coeff(1,2)/coeff(1,1)/coeff(2,2);
    % fprintf('Test coeff of out %d: %g\n', i, stm_predictcoeff(j));
end

data = data_pc;

esn.clearrecord('sizeinput', sizeinput, 'nodenuminput', max(floor(esn.Nr/2/sizeinput), 1), 'sizeoutput', 1, ...
    'timeConst', timeconst, 'inputScaling', 1, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', dt, 'normmethod', 1, 'ifxnorm', 1);
% 
% esn.Win = zeros(Nr,1);
% esn.Wb = zeros(Nr,1);
% esn.Wr = zeros(Nr,Nr);

[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1:stoptime/dt), data(1:stoptime/dt,n), dt);

esn.traindatacollect("esn.slx", washout);

[trainout, trY] = esn.train();
trainout{1} = double(trainout{1}>0.5);

datanum = stoptime/dt;
[SinusoidBus, busin, SinusoidBustar, busintar] = create_bus_input(input(1+datanum:stoptime/dt+datanum), data(1+datanum:stoptime/dt+datanum,n), dt);

[predictout, prY] = esn.predict("esn.slx");
% predictout{1} = double(predictout{1}>0.5);


for i = 1:esn.sizeoutput
    pc_trainerror(j) = immse(trainout{i}(washout+1:end), trY{i}(washout+1:end));
    % fprintf('Train error of out %d: %g\n', i, pc_trainerror(j));
    coeff = cov(trainout{i}(washout+1:end), trY{i}(washout+1:end));
    pc_traincoeff(j) = coeff(1,2)*coeff(1,2)/coeff(1,1)/coeff(2,2);
    % fprintf('Train coeff of out %d: %g\n', i, pc_traincoeff(j));
end

for i = 1:esn.sizeoutput
    pc_predicterror(j) = immse(predictout{i}(washout+1:end), prY{i}(washout+1:end));
    % fprintf('Test error of out %d: %g\n', i, pc_predicterror(j));
    coeff = cov(predictout{i}(washout+1:end), prY{i}(washout+1:end));
    pc_predictcoeff(j) = coeff(1,2)*coeff(1,2)/coeff(1,1)/coeff(2,2);
    % fprintf('Test coeff of out %d: %g\n', i, pc_predictcoeff(j));
end
end

stm_allcoeff = sum(stm_predictcoeff);
pc_allcoeff = sum(pc_predictcoeff);

%%

% filename = ['esnseed/esn_Nr' num2str(esn.Nr) 'SR' num2str(SR*10) 'No' num2str(k)];
% 
disp([filename 'succeed']);
disp(stm_allcoeff);
disp(pc_allcoeff);
save(filename, 'stm_trainerror', 'pc_trainerror', 'stm_predicterror', 'pc_predicterror', ...
    'stm_traincoeff', 'pc_traincoeff', 'stm_predictcoeff', 'pc_predictcoeff', ...
    'stm_allcoeff', 'pc_allcoeff', '-append');

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