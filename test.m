% Script to run tests
% Be careful, this will clear all your matlab variables
clear classes
addpath(fullfile(pwd, 'marsbar'))
addpath(fullfile(pwd, 'testing'))
marsbar on
run_tests tests
