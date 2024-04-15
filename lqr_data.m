clear;clc;
close all;

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

ini_x_c = 0;
ini_xdot_c = 0;
ini_theta_p = 0;
ini_thetadot_p = 0;

% r = 0.2;

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

% 1 0 for ordinary LQR1
% 9.9967 0.48836 for best lorenz LQR2
% 0.010014 1.9993 for best sinusoid LQR3

R = 9.9967; % 0.01~10
alpha = 0.48836; % 0~2

K = lqr(A+alpha*eye(4),B,Q,R);

load('data\esn_Nr10SR17No3control.mat',"esn");
% lqrout = out;
% lqroutlorenz = outlorenz;
% save('data\controlrecords.mat',"lqrout","lqroutlorenz");

%% lqr control test
ini_x_c = 0;
ini_xdot_c = 0;
ini_theta_p = 0;
ini_thetadot_p = 0;

stoptime = 40;

t_lim = 40;
t_switch = 40;

wf = 3;
w1 = wf;
w2 = 0;
w3 = 0;
A1 = 0.1;
A2 = 0;
A3 = 0;

out = sim("esn_CPcontrol.slx");
%% output of control

u_esn = squeeze(out.yout{3}.Values.u_esn.Data(:,1));
u_lqr = squeeze(out.yout{3}.Values.u_lqr.Data(1,1,:));
r = squeeze(out.yout{3}.Values.r.Data(:,1,:));
S_esn = squeeze(out.yout{2}.Values.S_esn.Data(:,1,:));
x = squeeze(out.yout{2}.Values.xplan.Data(1:4,1,:)).*esn.xnorm;
x_plan = squeeze(out.yout{2}.Values.xplan.Data(5:8,1,:)).*esn.xnorm;

figure();
len = length(u_esn);
% XX = [1:len; 1:len; 1:len; 1:len]';
XX = 1:len;
XX = XX.*esn.timestep;
plot(XX, u_lqr, 'k');
hold on;
plot(XX, u_esn, 'r');
legend('lqr', 'esn');
title('Comparison between lqr and esn');
xlabel('t');
xlim([0 len.*esn.timestep]);
ylim([-0.5 0.5]);

figure();
len = length(u_esn);
% XX = [1:len; 1:len; 1:len; 1:len]';
XX = 1:len;
XX = XX.*esn.timestep;
plot(XX, r(1,:), 'k');
hold on;
plot(XX, x(1,:), 'r');
legend('r', 'x');
title('Comparison between r and x');
xlabel('t');
xlim([0 len.*esn.timestep]);
ylim([-0.5 0.5]);

%% lorenz control
[SinusoidBus, busin] = create_bus_input();

ini_x_c = 0;
ini_xdot_c = 0;
ini_theta_p = 0;
ini_thetadot_p = 0;

stoptime = 45;
t_switch = 45;

outlorenz = sim("esn_CPcontrol2.slx");

%% output of control

u_esn = squeeze(outlorenz.yout{3}.Values.u_esn.Data(:,1));
u_lqr = squeeze(outlorenz.yout{3}.Values.u_lqr.Data(1,1,:));
r = squeeze(outlorenz.yout{3}.Values.r.Data(:,1,:));
S_esn = squeeze(outlorenz.yout{2}.Values.S_esn.Data(:,1,:));
x = squeeze(outlorenz.yout{2}.Values.xplan.Data(1:4,1,:)).*esn.xnorm;
x_plan = squeeze(outlorenz.yout{2}.Values.xplan.Data(5:8,1,:)).*esn.xnorm;

figure();
len = length(u_esn);
% XX = [1:len; 1:len; 1:len; 1:len]';
XX = 1:len;
XX = XX.*esn.timestep;
plot(XX, u_lqr, 'k');
hold on;
plot(XX, u_esn, 'r');
legend('lqr', 'esn');
title('Comparison between lqr and esn');
xlabel('t');
xlim([0 len.*esn.timestep]);
ylim([-0.5 0.5]);

figure();
len = length(u_esn);
% XX = [1:len; 1:len; 1:len; 1:len]';
XX = 1:len;
XX = XX.*esn.timestep;
plot(XX, r(1,:), 'k');
hold on;
plot(XX, x(1,:), 'r');
legend('r', 'x');
title('Comparison between r and x');
xlabel('t');
xlim([0 len.*esn.timestep]);
ylim([-0.5 0.5]);

figure();
len = length(u_esn);
% XX = [1:len; 1:len; 1:len; 1:len]';
XX = 1:len;
XX = XX.*esn.timestep;
plot(r(1,:), r(2,:), 'k');
hold on;
plot(x(1,:), x(2,:), 'r');
legend('r', 'x');
title('Comparison between r and x');
xlabel('x');
ylabel('xdot');
% xlim([0 len.*esn.timestep]);
% ylim([-0.5 0.5]);

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
