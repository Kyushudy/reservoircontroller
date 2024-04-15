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
alpha = 0;

K = lqr(A+alpha*eye(4),B,Q,R);

load("esnseed\esn_Nr10SR17No39.mat", 'esn', 'Wcontrol');
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
%% esn run

wlist = 0.1*[1	1.27427498570313	1.62377673918872	2.06913808111479	2.63665089873036	3.35981828628378	4.28133239871939	5.45559478116852	6.95192796177561	8.85866790410083	11.2883789168469	14.3844988828766	18.3298071083244	23.3572146909012	29.7635144163132	37.9269019073225	48.3293023857175	61.5848211066026	78.4759970351461	100];

filenames = ["esn_Nr10SR17No39" "esn_Nr20SR11No8" "esn_Nr50SR11No2" "esn_Nr500SR11No98"];
esnsinerrorlist = zeros(4,20);

for i = 1:4
    filename = filenames(i);
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
    %% esn control test
    ini_x_c = 0;
    ini_xdot_c = 0;
    ini_theta_p = 0;
    ini_thetadot_p = 0;
    
    stoptime = 100;
    
    t_lim = 100;
    t_switch = 0;

    for j = 1:20
        wf = wlist(j);
        w1 = wf;
        w2 = 0;
        w3 = 0;
        A1 = 0.1;
        A2 = 0;
        A3 = 0;

        t = timer('StartDelay', 240);
        t.TimerFcn = @(x,y)set_param("esn_CPcontrol", 'SimulationCommand', 'stop');
        start(t);
        
        out = sim("esn_CPcontrol.slx");

        stop(t);
        delete(t);
        if out.tout(end) ~= stoptime
            error = nan;
        else
            % output of control
            r = squeeze(out.yout{3}.Values.r.Data(:,1,:));
            x = squeeze(out.yout{2}.Values.xplan.Data(1:4,1,:)).*esn.xnorm;
        
            error = dtw(x(1,1000:end), r(1,1000:end));
            disp(error);
        end
        
        esnsinerrorlist(i,j) = error;
    
    end
end

save("data\sinusoiderrordata.mat", "esnsinerrorlist", "wlist");