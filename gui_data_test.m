% Run GUI tests that depend on estimations from data_test.m script
% Please run data_test before this script
cwd = pwd;
addpath(fullfile(cwd, 'marsbar'));
% Activate marsbar for correct spm_get routine
marsbar('on');
% Get location of data from environment variable
subjroot = getenv('MARSBAR_EG_DATAPATH');
% Otherwise fetch via the GUI
if isempty(subjroot)
    subjroot = spm_get(-1, '', 'Root directory of example data');
    setenv('MARSBAR_EG_DATAPATH', subjroot);
end
% Collect designs for test_rig
spm_ver = spm('ver');
sdirname = [spm_ver '_ana'];
if strcmp(spm_ver, 'SPM99')
  conf_design_name = 'SPMcfg.mat';
else
  conf_design_name = 'SPM.mat';
end
design = fullfile(subjroot, 'sess1', sdirname, conf_design_name);
if ~exist(design, 'file')
    error(sprintf('Missing design at %s', design))
end
% Check that fill works
D = mardo(design);
D2 = fill(D, {'images'})
