function error = lqr_optfun(x)
% clear;clc;
% close all;
% 

R = x.R;
alpha = x.alpha;

% R, alpha

% R = x(1);
% alpha = x(2);

addpath('./esn/');
%% lqr
carrho = 1000;
penrho = 1000;
carlength = 0.05;
carwidth = 0.05;
cardepth = 0.05;
penlength = 0.2;
penwidth = 0.02;
pendepth = 0.02;

g = 9.80665;
m = penrho*penlength*penwidth*pendepth;
M = carrho*carlength*carwidth*cardepth;
l = penlength/2;

A = [0 1 0 0;
    0 0 -3*m*g/(m+4*M) 0;
    0 0 0 1;
    0 0 3*(m+M)*g/(m+4*M)/l 0];

B = [0;
    4/(m+4*M);
    0;
    -3/(m+4*M)/l];

C = [1 0 0 0;
    0 0 1 0];

D = [0;
    0];

Q = C'*C;
R = R; % 0.01~1
alpha = alpha; % 0~2

K = lqr(A+alpha*eye(4),B,Q,R);
assignin('base', 'K', K);

% %% lorenz control
% [SinusoidBus, busin] = create_bus_input();
% assignin('base', 'SinusoidBus', SinusoidBus);
% assignin('base', 'busin', busin);
% 
% outlorenz = sim("esn_CPcontrol2.slx");
% 
% %% output of control
% load('data\esn_Nr10SR17No3control.mat',"esn");
% u_esn = squeeze(outlorenz.yout{3}.Values.u_esn.Data(:,1));
% u_lqr = squeeze(outlorenz.yout{3}.Values.u_lqr.Data(1,1,:));
% r = squeeze(outlorenz.yout{3}.Values.r.Data(:,1,:));
% S_esn = squeeze(outlorenz.yout{2}.Values.S_esn.Data(:,1,:));
% x = squeeze(outlorenz.yout{2}.Values.xplan.Data(1:4,1,:)).*esn.xnorm;
% x_plan = squeeze(outlorenz.yout{2}.Values.xplan.Data(5:8,1,:)).*esn.xnorm;

%% sinusoid control

wf = 3;
assignin('base', 'wf', wf);
w1 = wf;
assignin('base', 'w1', w1);
w2 = 0;
assignin('base', 'w2', w2);
w3 = 0;
assignin('base', 'w3', w3);
A1 = 0.1;
assignin('base', 'A1', A1);
A2 = 0;
assignin('base', 'A2', A2);
A3 = 0;
assignin('base', 'A3', A3);

out = sim("esn_CPcontrol.slx");
%% output of control
load('data\esn_Nr10SR17No3control.mat',"esn");
u_esn = squeeze(out.yout{3}.Values.u_esn.Data(:,1));
u_lqr = squeeze(out.yout{3}.Values.u_lqr.Data(1,1,:));
r = squeeze(out.yout{3}.Values.r.Data(:,1,:));
S_esn = squeeze(out.yout{2}.Values.S_esn.Data(:,1,:));
x = squeeze(out.yout{2}.Values.xplan.Data(1:4,1,:)).*esn.xnorm;
x_plan = squeeze(out.yout{2}.Values.xplan.Data(5:8,1,:)).*esn.xnorm;

%% error

error = dtw(x(1,:), r(1,:));

end

%% function
function [SinusoidBus, busin] = create_bus_input()
    seqDim = 4;

    [X, Y, Z, T] = lorenz(28, 10, 8/3, [0, 0.5, 0.5], 0:0.01:25, 0.000001);
    % figure;
    % plot3(X,Y,Z);
    % xlabel('x');
    % ylabel('y');
    % zlabel('z');
    % figure;
    % plot(X(2:end),diff(X)/0.01);
    % xlabel('x');
    % ylabel('xdot');

    X = X(1+1000:end) - X(1+1000); 
    X = X/max(X)*0.3;

    time = 0:0.03:45;

    clear elems;
    for j = 1:seqDim
        elems(j) = Simulink.BusElement;
        elems(j).Name = ['x' num2str(j)];
    end
    SinusoidBus = Simulink.Bus;
    SinusoidBus.Elements = elems;
    clear busin;

    busin.x1 = timeseries(X,time);
    busin.x2 = timeseries([0; diff(X)/0.03],time);
    % busin.x2 = timeseries(0*X,time);
    busin.x3 = timeseries(0*X,time);
    busin.x4 = timeseries(0*X,time);

end
