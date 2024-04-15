clear;clc;
close all;

% poolobj = parpool('LocalProfile1');

load('data\esn_Nr10SR17No3control.mat',"esn");

carrho = 1000;
penrho = 1000;
carlength = 0.05;
carwidth = 0.05;
cardepth = 0.05;
penlength = 0.2;
penwidth = 0.02;
pendepth = 0.02;

ini_x_c = 0;
ini_xdot_c = 0;
ini_theta_p = 0;
ini_thetadot_p = 0;

% % lorenz opt
% stoptime = 45;
% t_switch = 45;

% sinusoid opt
stoptime = 40;
t_lim = 40;
t_switch = 40;

% Rlist = [0.01 0.05 0.1 0.5 1:10];
% alphalist = 0:0.2:2;

Rlist = [1 9.9967 0.010014];
alphalist = [0 0.48836 1.9993];

% lorenzdata = [];
% 
% for i = 1:3
%     R = Rlist(i);
%     alpha = alphalist(i);
%     x = table(R, alpha);
%     error = lqr_optfun(x);
%     lorenzdata = [lorenzdata; R alpha error];
%     disp([R alpha error]);
% end

%% sinusoid
sinudata = [];

for i = 1:3
    R = Rlist(i);
    alpha = alphalist(i);
    x = table(R, alpha);
    error = lqr_optfun(x);
    sinudata = [sinudata; R alpha error];
    disp([R alpha error]);
end