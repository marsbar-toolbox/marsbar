% Run smoothing and SPM analysis for MarsBaR ER sample data
% 
% $Id$ 

switch spm('ver')
 case 'SPM99'
  sdirname = 'SPM99_ana';
 case 'SPM2'
  % load SPM defaults
  spm_defaults;
  sdirname = 'SPM2_ana';
end

% do smoothing
er_smooth;

% quit MarsBaR, otherwise SPM will get confused
% (in fact this is only true for old versions of MarsBaR)
if ~isempty(which('marsbar'))
  marsbar('quit'); 
end

% Run statistics, contrasts
subjroot = spm_get('CPath', '..'); % from batch directory
sesses = {'sess1','sess2','sess3'};
for ss = 1:length(sesses)
  model_file = configure_er_model(subjroot, sesses{ss}, sdirname);
  estimate_er_model(model_file, [1 0]);
end
