clear;clc;
close all;

filenames = ["esn_Nr10SR17No3" "esn_Nr20SR11No1" "esn_Nr50SR11No4" "esn_Nr500SR11No1"];
esnlorenzerrorlist = zeros(3,1);
esnsin3errorlist = zeros(3,1);

for i = 1

    filename = filenames(i+1);
    load("data\" + filename + "control.mat", 'esn');

    ini_x_c = 0;
    ini_xdot_c = 0;
    ini_theta_p = 0;
    ini_thetadot_p = 0;
    
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
    R = 1; % 0.01~1
    alpha = 0; % 0~2
    
    K = lqr(A+alpha*eye(4),B,Q,R);

    %% step control
    
    stoptime = 40;
    t_lim = 15;
    t_switch = 40;
    t = 0:0.01:40;
    
    wf = 3;
    assignin('base', 'wf', wf);
    w1 = 0;
    assignin('base', 'w1', w1);
    w2 = 0;
    assignin('base', 'w2', w2);
    w3 = 0;
    assignin('base', 'w3', w3);
    A1 = 0;
    assignin('base', 'A1', A1);
    A2 = 0;
    assignin('base', 'A2', A2);
    A3 = 0;
    assignin('base', 'A3', A3);

    out = sim("esn_CPcontrol.slx");
    %% output of control
    load('data\esn_Nr10SR17No3control.mat',"esn");
    r_step = squeeze(out.yout{3}.Values.r.Data(:,1,:));
    x_step = squeeze(out.yout{2}.Values.xplan.Data(1:4,1,:)).*esn.xnorm;

    figure();
    plot(t, r_step(1,:));
    hold on;
    plot(t, x_step);
    
    
    %% sinusoid control
    
    stoptime = 100;
    t_lim = stoptime;
    t_switch = stoptime;
    t = 0:0.01:stoptime;

    w1 = 1.86304523267102;
    w2 = 1.44360739576384;
    w3 = 3.54011133985333;
    A1 = -0.0490045122748814;
    A2 = -0.0895899692005687;
    A3 = 0.150760235583392;
    
    assignin('base', 'w1', w1);
    assignin('base', 'w2', w2);
    assignin('base', 'w3', w3);
    assignin('base', 'A1', A1);
    assignin('base', 'A2', A2);
    assignin('base', 'A3', A3);

    out = sim("esn_CPcontrol.slx");
    %% output of control
    load('data\esn_Nr10SR17No3control.mat',"esn");
    r_sin = squeeze(out.yout{3}.Values.r.Data(:,1,:));
    x_sin = squeeze(out.yout{2}.Values.xplan.Data(1:4,1,:)).*esn.xnorm;

    figure();
    plot(t, r_sin(1,:));
    hold on;
    plot(t, x_sin);
    

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
