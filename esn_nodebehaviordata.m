clear;clc;
close all;

addpath('./esn/');

%% load reservoir
Nrlist = [10 20 50 500];
SRlist = [1.7 1.1 1.1 1.1];

for k = 1 % 1:4
Nr = Nrlist(k);
SR = SRlist(k);

nodevar_stepminlist = [];
nodevar_stepmidlist = [];
nodevar_stepmaxlist = [];
nodevar_sinminlist = [];
nodevar_sinmidlist = [];
nodevar_sinmaxlist = [];

for No = 1:100 % 1:100, ESN10 best 39 4 58 42 35, worst 24 75 54 5 22

clear("nodebehavior_t", "nodebehavior_inputstep", "nodebehavior_normstep", ...
        "nodebehavior_inputsin", "nodebehavior_normsin");

filename = ['esnseed\esn_Nr' num2str(Nr) 'SR' num2str(SR*10) 'No' num2str(No) '.mat'];
load(filename, "nodebehavior_t", "nodebehavior_inputstep", "nodebehavior_normstep", ...
        "nodebehavior_inputsin", "nodebehavior_normsin");

% if exist("nodebehavior_normsin", 'var') ~= 1
%     disp([filename ' fail in generation']);
%     save(filename, "", '-append');
%     continue;
% end

nodevar_stepmin = var(nodebehavior_normstep(40,:), 1);
nodevar_stepmid = var(nodebehavior_normstep(45,:), 1);
nodevar_stepmax = var(nodebehavior_normstep(50,:), 1);
nodevar_sinmin = var(nodebehavior_normsin(48,:), 1);
nodevar_sinmid = var(nodebehavior_normsin(64,:), 1);
nodevar_sinmax = var(nodebehavior_normsin(80,:), 1);

nodevar_stepminlist = [nodevar_stepminlist nodevar_stepmin];
nodevar_stepmidlist = [nodevar_stepmidlist nodevar_stepmid];
nodevar_stepmaxlist = [nodevar_stepmaxlist nodevar_stepmax];
nodevar_sinminlist = [nodevar_sinminlist nodevar_sinmin];
nodevar_sinmidlist = [nodevar_sinmidlist nodevar_sinmid];
nodevar_sinmaxlist = [nodevar_sinmaxlist nodevar_sinmax];

end
end