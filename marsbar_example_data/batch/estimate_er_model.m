function SPM = estimate_er_model(model_file, ev_con)
% SPM estimate of ER model, and add contrast to ER model
% 
% model_file      - path to directory containing model
%
% Single or multisesson analyses.
%
% $Id$

if nargin < 1
  error('Need model filename');
end
if nargin < 2
  error('Need event contrast');
end

% Check for model
if ~exist(model_file, 'file')
  error(['Cannot find ' model_file]);
end
SPM = load(model_file);
if isfield(SPM, 'SPM'), SPM=SPM.SPM; end

% Work out contrast, taking into account no of sessions
nblocks = length(SPM.xX.iB);  % number of sessions in this model
con = [repmat(ev_con, 1, nblocks) zeros(1, nblocks)]';

% new path, store path, move to model path
swd = fileparts(model_file);
pwd_orig = pwd;

switch spm('ver')
 case 'SPM99'
  % Estimate parameters
  cd(swd);
  Sess=SPM.Sess; xsDes=SPM.xsDes;       % because spm_spm uses inputname
  spm_spm(SPM.VY,SPM.xX,SPM.xM,SPM.F_iX0,Sess,xsDes);
  
  % add contrasts, estimate all contrasts
  cd(pwd_orig);
  global SPM_BCH_VARS
  con_struct = struct('names', {{'stim_hrf'}},...
		      'types', {{'T'}}, ...
		      'values', {{con'}}); 
  SPM_BCH_VARS = struct(...
      'work_dir', swd, ...
      'ana_type', 2, ...          % contrasts
      'm_file', fullfile(pwd_orig, 'er_contrast_spm99'),...
      'contrasts', con_struct);
  spm_bch('do_bch_wrapper');
  
 case 'SPM2'
  % load SPM defaults
  if ~exist('defaults', 'var')
    global defaults;
    spm_defaults; 
  end

  % Estimate parameters
  cd(swd);
  spm_unlink(fullfile('.', 'mask.img')); % avoid overwrite dialog
  SPM = spm_spm(SPM);
  
  % add contrast, estimate all contrasts
  SPM.xCon(end + 1)   = spm_FcUtil('Set','stim_hrf',...
				   'T','c',con,SPM.xX.xKXs);
  SPM = spm_contrasts(SPM);

  % Back to where we started
  cd(pwd_orig);
end

