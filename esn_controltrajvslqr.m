clear; clc;
close all;

load("data\lqresnperform.mat");

filenames = ["esn_Nr10SR17No39" "esn_Nr20SR11No8" "esn_Nr50SR11No2" "esn_Nr500SR11No98"];

filename = filenames(1);
load("esnseed\" + filename + ".mat", 'outsin', 'outlorenz');
esn10xsin = outsin.yout{1}.Values.x_c.Data';
esn10xdotsin = outsin.yout{1}.Values.xdot_c.Data';
esn10xlorenz = outlorenz.yout{1}.Values.x_c.Data';
esn10xdotlorenz = outlorenz.yout{1}.Values.xdot_c.Data';

filename = filenames(2);
load("esnseed\" + filename + ".mat", 'outsin', 'outlorenz');
esn20xsin = outsin.yout{1}.Values.x_c.Data';
esn20xdotsin = outsin.yout{1}.Values.xdot_c.Data';
esn20xlorenz = outlorenz.yout{1}.Values.x_c.Data';
esn20xdotlorenz = outlorenz.yout{1}.Values.xdot_c.Data';

filename = filenames(3);
load("esnseed\" + filename + ".mat", 'outsin', 'outlorenz');
esn50xsin = outsin.yout{1}.Values.x_c.Data';
esn50xdotsin = outsin.yout{1}.Values.xdot_c.Data';
esn50xlorenz = outlorenz.yout{1}.Values.x_c.Data';
esn50xdotlorenz = outlorenz.yout{1}.Values.xdot_c.Data';

filename = filenames(4);
load("esnseed\" + filename + ".mat", 'outsin', 'outlorenz');
esn500xsin = outsin.yout{1}.Values.x_c.Data';
esn500xdotsin = outsin.yout{1}.Values.xdot_c.Data';
esn500xlorenz = outlorenz.yout{1}.Values.x_c.Data';
esn500xdotlorenz = outlorenz.yout{1}.Values.xdot_c.Data';

lqr1xdotsin = [0 lqr1xdotsin];
lqr2xdotsin = [0 lqr2xdotsin];
lqr3xdotsin = [0 lqr3xdotsin];
