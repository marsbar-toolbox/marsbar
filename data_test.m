% Runs tests that depend on example data
cwd = pwd;
addpath(fullfile(cwd, 'marsbar'));
addpath(fullfile(cwd, 'marsbar', 'release'));
addpath(fullfile(cwd, 'marsbar', 'examples', 'batch'));
% Activate marsbar for correct spm_get routine
marsbar('on');
% Get location of data from environment variable
subjroot = getenv('MARSBAR_EG_DATAPATH');
% Otherwise fetch via the GUI
if isempty(subjroot)
    subjroot = spm_get(-1, '', 'Root directory of example data');
    setenv('MARSBAR_EG_DATAPATH', subjroot);
end
% Run preprocesssing scripts, tutorial
run_preprocess;
run_s3_model;
run_tutorial;
% Collect designs for test_rig
spm_ver = spm('ver');
sdirname = [spm_ver '_ana'];
if strcmp(spm_ver, 'SPM99')
  conf_design_name = 'SPMcfg.mat';
else
  conf_design_name = 'SPM.mat';
end
designs{1} = fullfile(subjroot, sdirname, conf_design_name);
for sno = 1:3
    sess_name = sprintf('sess%d', sno);
    designs{end+1} = fullfile(subjroot, sess_name, sdirname, conf_design_name);
end
% Check they exist
for dno = 1:length(designs)
    if ~exist(designs{dno}, 'file')
        error(sprintf('Missing design at %s', designs{dno}))
    end
end
% Run them through the test_rig
res = test_rig(char(designs));
if ~all(res)
    error('Some designs did not pass');
end
