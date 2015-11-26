% Script to run tests
% Be careful, this will clear all your matlab variables
%
% Remember to run `git submodule update --init` to get the testing machinery
%
% See data_test.m for regression testing on data.
clear classes
addpath(fullfile(pwd, 'marsbar'))
addpath(fullfile(pwd, 'testing'))
marsbar on
run_tests tests
