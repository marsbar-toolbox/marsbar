% Run SPM 2-session model for MarsBaR ER sample data
%
% You might want to define the path to the example data here, as in
% subjroot = '/my/path/somewhere';
subjroot = get_subjroot();

sesses = {'sess1','sess2','sess3'};

spm_v = spm('ver');
sdirname = [spm_v '_ana'];
if ~strcmp(spm_v, 'SPM99'), spm_defaults; end

% Make sure SPM modality-specific defaults are set
spm('defaults', 'fmri');

% Run statistics, contrasts
model_file = configure_er_model(subjroot, sesses, sdirname);
estimate_er_model(model_file, [1 0]);
