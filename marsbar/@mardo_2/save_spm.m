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
  fname = 'SPM.mat';
end

% Convert vols to native format
D = convert_vols(D, native_vol_ver(D));

SPM = des_struct(D);
if ~mars_utils('isabspath', fname)
  Swd = mars_struct('getifthere', SPM, 'swd');
  if isempty(Swd)
    error('No path passed, and none in design');
  end
  fname = fullfile(Swd, fname);
else
  SPM.swd = fileparts(fname);
end


try 
  if verbose(D)
    fprintf('Saving design to file %s\n', fname);
  end
  save(fname, 'SPM');
  tf = 1;
catch
  warning(lasterr);
  tf = 0;
end