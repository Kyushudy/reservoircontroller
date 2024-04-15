clear; clc;
close all;

% elist = zeros(400,1);
% CRlist = zeros(400,1);
% 
% for No = 1:400
% 
% clear('edtwlorenz', 'CR');
% 
% filename = ['esnseed2\esn_No' num2str(No) '.mat'];
% load(filename, 'edtwlorenz', 'CR');
% 
% if exist("edtwlorenz", 'var') ~= 1
%     disp([filename ' fail in control']);
%     edtwlorenz = nan;
% end
% 
% elist(No) = edtwlorenz;
% CRlist(No) = CR;
% 
% end

% null: large CRlim ends in small elim
% test true (kyes): CR big
% actual true (ksuccess): elim small

load("data\fig2_hypothesis.mat");

CRlimlist = 0.9:-0.005:0.1;
tplist = zeros(size(CRlimlist,2),1);
fplist = zeros(size(CRlimlist,2),1);

% for i = 1:size(CRlimlist,2)
for i = 1
% CRlim = CRlimlist(i); % 0.1~0.9
CRlim = 0.4;
elim = 500;

kyes = CRlist>CRlim;
ksuccess = elist<elim;

truepos = kyes == 1 & ksuccess == 1;
disp(sum(truepos));
type1e = kyes == 1 & ksuccess == 0;
disp(sum(type1e));
type2e = kyes == 0 & ksuccess == 1;
disp(sum(type2e));
trueneg = kyes == 0 & ksuccess == 0;
disp(sum(trueneg));
alpha = sum(type1e)/(sum(trueneg) + sum(type1e));
beta = sum(type2e)/(sum(truepos) + sum(type2e));
disp(['alpha=' num2str(alpha) ' beta=' num2str(beta)]);

tprate = 1 - beta;
fprate = alpha;
disp(['tprate=' num2str(tprate) ' fprate=' num2str(fprate)]);

tplist(i) = tprate;
fplist(i) = fprate;

end

% plot(fplist, tplist);
% AUC = trapz(fplist, tplist);