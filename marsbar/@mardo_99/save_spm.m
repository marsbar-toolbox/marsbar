function tf = save_spm(D, fname);
% method to save design as SPM format design structure
% FORMAT tf = save_spm(D, fname);
% 
% Inputs
% D      - design object
% fname  - filename
% 
% Outputs
% tf     - flag ==1 if successful
% 
% $Id$
  
if nargin < 2
  if is_spm_estimated(D)
    fname = 'SPM.mat';
  elseif has_images(D)
    fname = 'SPMcfg.mat';
  elseif is_fmri(D)
    fname = 'SPM_fMRIDesMtx.mat';
  else
    error('Cannot work out design type for default filename');
  end
end
SPM = des_struct(D);
if ~mars_utils('isabspath', fname)
  swd = mars_struct('getifthere', SPM, 'swd');
  if isempty(swd)
    error('No path passed, and none in design');
  end
  fname = fullfile(swd, fname);
end

try 
  if verbose(D)
    fprintf('Saving design to file %s\n', fname);
  end
  savestruct(SPM, fname);
  tf = 1;
catch
  warning(lasterr);
  tf = 0;
end