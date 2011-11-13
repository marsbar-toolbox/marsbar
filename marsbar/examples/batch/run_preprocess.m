% Run smoothing and SPM analysis for MarsBaR ER sample data
%
% $Id: run_preprocess.m,v 1.2 2004/08/15 01:19:43 matthewbrett Exp $ 

% Start marsbar to make sure spm_get works
marsbar('on')

% You might want to define the path to the example data here, as in
% subjroot = '/my/path/somewhere';
subjroot = get_subjroot();

sesses = {'sess1','sess2','sess3'};

spm_v = spm('ver');
sdirname = [spm_v '_ana'];
if ~strcmp(spm_v, 'SPM99'), spm_defaults; end

% Make sure SPM modality-specific defaults are set
spm('defaults', 'fmri');

% do smoothing
er_smooth(subjroot, sesses, 'nu*.img', 8);

% Run statistics, contrasts
for ss = 1:length(sesses)
  model_file = configure_er_model(subjroot, sesses{ss}, sdirname);
  estimate_er_model(model_file, [1 0]);
end
