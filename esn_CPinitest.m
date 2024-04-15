clear;clc;
close all;

% warning('off');

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
R = 1;
K = lqr(A,B,Q,R);

%% esn create
filenames = ["esn_Nr10SR17No39" "esn_Nr20SR11No8" "esn_Nr50SR11No2" "esn_Nr500SR11No98"];
ini_data_saved = cell(4,1);

for ki = 1
filename = filenames(ki);
load("esnseed\" + filename + ".mat", 'esn', 'Wcontrol');
esn.Wout{1} = Wcontrol;

%% esn test
stoptime = 100;
washout = 1000;
wf = 2;

t_lim = stoptime;
w1 = 1*wf;
w2 = 0.7*wf;
w3 = 1.7*wf;
A1 = 0.2;
A2 = 0.1;
A3 = 0.15;
% K = [5, 0, 0, 0];

esn.traintest("esn_CPtest.slx");

ini_data = zeros(1,3);
ini_trylist = zeros(1,2);

while 1
%% esn control test
ini_x_c = 0;
ini_xdot_c = 0;
ini_theta_p = ini_trylist(1,1); % lqr 1.2, esn 0.8
ini_thetadot_p = ini_trylist(1,2); % lqr 25, esn 8
% error<100

% ini_theta_p = 0.5; % lqr 1.2, esn 0.8
% ini_thetadot_p = 0; % lqr 25, esn 8

try

stoptime = 10;

t_lim = 5;
t_switch = 10; % lqr
% t_switch = 0; % esn

wf = 1;
w1 = 1*wf;
w2 = 0.7*wf;
w3 = 1.7*wf;
A1 = 0.2;
A2 = 0.1;
A3 = 0.15;

t = timer('StartDelay', 15);
t.TimerFcn = @(x,y)set_param("esn_CPcontrol", 'SimulationCommand', 'stop');
start(t);

out = sim("esn_CPcontrol.slx");

stop(t);
delete(t);
if out.tout(end) ~= stoptime
    error('timeout');
end

r = squeeze(out.yout{3}.Values.r.Data(:,1,:));
x = squeeze(out.yout{2}.Values.xplan.Data(1:4,1,:)).*esn.xnorm;

error = dtw(x(1,:), r(1,:));
% error = immse(x(1,:), r(1,:)) + immse(x(2,:), r(2,:)) + immse(x(3,:), r(3,:)) + immse(x(4,:), r(4,:));

for i = round([ini_theta_p-0.1 ini_theta_p ini_theta_p+0.1],4)
    for j = round([ini_thetadot_p-1 ini_thetadot_p ini_thetadot_p+1],4)
        if ~ismember([i j],ini_data(:,1:2),"rows") && ~ismember([i j],ini_trylist,"rows") && error<300
            if i>-3 && i<3 && j>-23 && j<23
                ini_trylist = [ini_trylist; i j];   
            end
        end
    end
end

catch
error = NaN;
end

ini_data = [ini_data; ini_theta_p ini_thetadot_p error];
disp(['theta:' num2str(ini_theta_p) ' thetadot:' num2str(ini_thetadot_p) ' error:' num2str(error)]);

[m,n] = size(ini_trylist);
if m > 1
    ini_trylist = ini_trylist(2:end,:);
else
    break
end

end
ini_data = ini_data(2:end,:);

ini_data_saved{ki} = ini_data;
end

% save("data\" + filename + "control.mat", 'ini_data', '-append');
% save("data\lqrcontrol.mat", 'ini_data');
