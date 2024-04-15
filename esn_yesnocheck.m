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
K = lqr(A,B,Q,R);

%% esn create

w1list = [1.86304523267102	2.18823711270425	2.18286677929718	1.99415025948914	2.12011218755552	1.85675453545089	1.96870451305051	2.16629421007563	2.11688293182382	2.18379697055716];
w2list = [1.44360739576384	1.26999927000077	1.49775620564326	1.52151810937211	1.45004584336018	1.47216723656193	1.46807709107498	1.36982356546957	1.44353380924972	1.30793227258724];
w3list = [3.54011133985333	3.08164633553665	3.24830762977341	3.09139654562918	3.12604961124038	3.61995132326256	3.53248346362356	3.27562764644139	3.70615099321008	3.08342333474198];
A1list = [-0.0490045122748814	-0.0947532343255933	0.212413430519202	0.236159920909651	-0.250501916356497	-0.00818848336941516	-0.0435310394312804	0.117050408089012	0.167491864686458	0.203749345585889];
A2list = [-0.0895899692005687	0.0718810707414699	0.0620392015895363	-0.134955305922148	-0.152400927376649	-0.000654379207142819	0.183897583406432	-0.0638457093335467	0.0341071003919109	-0.110475224203545];
A3list = [0.150760235583392	-0.146942930724439	0.00357423099908543	0.119446033594012	0.234541951521479	0.275574855123267	0.0283293179782818	-0.216825334302793	-0.210423596664566	-0.145495047525758];

Nr = 20;
TCrange = [0.1 10];
SRrange = [0.5 2];
ISrange = [0.1 2];
COrange = [2/Nr 20/Nr];
BIrange = [0.01 1];

for No = 201:400

filename = ['esnseed2\esn_No' num2str(No) '.mat'];

normmethod = 1;
ifxnorm = 1;

sizeinput = 8;
sizeoutput = 1;

TC = TCrange(1) + rand(1)*(TCrange(2) - TCrange(1));
SR = SRrange(1) + rand(1)*(SRrange(2) - SRrange(1));
IS = ISrange(1) + rand(1)*(ISrange(2) - ISrange(1));
CO = COrange(1) + rand(1)*(COrange(2) - COrange(1));
BI = BIrange(1) + rand(1)*(BIrange(2) - BIrange(1));

esn = ESN_trainbysim(Nr, 'sizeinput', sizeinput, 'nodenuminput', max(floor(Nr/2/sizeinput), 1), 'sizeoutput', sizeoutput, ...
    'timeConst', TC, 'spectralRadius', SR, 'inputScaling', IS, 'connectivity', CO, 'biasScaling', BI, ...
    'regularization', 1e-8, 'delaylen', 1, 'timestep', 0.01, 'normmethod', normmethod, 'ifxnorm', ifxnorm);

save(filename, 'esn');

try

% normmethod 1 for unnormed, 2 for only control meannormed, 3 for meannormed, 4 for meannormed+
normmethod = 1;

% whether normalize x
ifxnorm = 1;

sizeinput = 8;
sizeoutput = 1;

dt = 0.01;

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

esn.traintest("esn_CPtest.slx");

%% esn train
K = lqr(A,B,Q,R);
esn.traindatacollect("esn_CPtrain.slx", washout);
for i = 1:10
    wf = 2;
    w1 = w1list(i);
    w2 = w2list(i);
    w3 = w3list(i);
    A1 = A1list(i);
    A2 = A2list(i);
    A3 = A3list(i);
    esn.traindatacollect("esn_CPtrain.slx", washout);
end

[trainout, trY] = esn.train();

Wcontrol = esn.Woutmat;
save(filename, 'Wcontrol', '-append');

%% esn predict
K = lqr(A,B,Q,R);
w1 = 1.7*wf;
w2 = 1.3*wf;
w3 = 0.3*wf;
A1 = 0.2;
A2 = 0.1;
A3 = 0.15;

[predictout, prY] = esn.predict("esn_CPtrain.slx");

%% esn sin track
ini_x_c = 0;
ini_xdot_c = 0;
ini_theta_p = 0;
ini_thetadot_p = 0;

stoptime = 40;

t_lim = 40;
t_switch = 0;

wf = 3;
w1 = wf;
w2 = 0;
w3 = 0;
A1 = 0.1;
A2 = 0;
A3 = 0;

t = timer('StartDelay', 60);
t.TimerFcn = @(x,y)set_param("esn_CPcontrol", 'SimulationCommand', 'stop');
start(t);

outsin = sim("esn_CPcontrol.slx");

stop(t);
delete(t);
if outsin.tout(end) ~= stoptime
    error('timeout');
end

save(filename, 'outsin', '-append');

%% lorenz control
[SinusoidBus, busin] = create_bus_input();

ini_x_c = 0;
ini_xdot_c = 0;
ini_theta_p = 0;
ini_thetadot_p = 0;

stoptime = 45;
t_switch = 0;

t = timer('StartDelay', 60);
t.TimerFcn = @(x,y)set_param("esn_CPcontrol2", 'SimulationCommand', 'stop');
start(t);

outlorenz = sim("esn_CPcontrol2.slx");

stop(t);
delete(t);
if outlorenz.tout(end) ~= stoptime
    error('timeout');
end

save(filename, 'outlorenz', '-append');
disp([filename ' succeed']);

r = squeeze(outsin.yout{3}.Values.r.Data(1,1,:));
x = squeeze(outsin.yout{1}.Values.x_c.Data);
edtwsin = dtw(x, r);
disp(['edtwsin = ' num2str(edtwsin)]);

r = squeeze(outlorenz.yout{3}.Values.r.Data(1,1,:));
x = squeeze(outlorenz.yout{1}.Values.x_c.Data);
edtwlorenz = dtw(x, r);
disp(['edtwlorenz = ' num2str(edtwlorenz)]);

save(filename, "edtwsin", "edtwlorenz", '-append');

catch
    disp([filename ' runtimeout']);
end

end

%% function
function [SinusoidBus, busin] = create_bus_input()
    seqDim = 4;

    [X, Y, Z, T] = lorenz(28, 10, 8/3, [0, 0.5, 0.5], 0:0.01:25, 0.000001);

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
