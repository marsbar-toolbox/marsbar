function model_file = configure_spm99_model(sess_dir, sesses, sdirname)
% batch script wrapper to configure model for MarsBaR ER data
% 
% sess_dir        - directory containing session directories
% sesses          - string or cell array of session directory names
% sdirname        - subdirectory name to put model in
%
% Returns
% model_file      - full path to SPM model file
%
% This wrapper does single or multisesson analyses.
%
% If only one session directory is passed, and sdirname is not an absolute
% path, then the function assumes sdirname is a subdirectory of the session
% directory
% 
% $Id$
  
if nargin < 1
  error('Need directory containing session subdirectories');
end
if nargin < 2
  error('Need directory names for sessions');
end
if ischar(sesses), sesses = cellstr(sesses); end
if nargin < 3
  error('Need subdirectory name for results');
end

% store path
pwd_orig = pwd;

% make absolute path
sess_dir = spm_get('CPath', sess_dir);

% If only one session directory is passed, and sdirname is not an
% absolute path, then assume sdirname is a subdirectory of the session
% directory
if ~sf_isabspath(sdirname) & length(sesses) == 1
  sdir_parent = fullfile(sess_dir, sesses{1});
else
  sdir_parent = sess_dir;
end

% results directory
ana_dir = fullfile(sdir_parent, sdirname);
if ~exist(ana_dir, 'dir')
  mkdir(sdir_parent, sdirname);
end

switch spm('ver')
 case 'SPM99'
  % Batch directory in session directory
  batch_dir = spm_get('CPath', fullfile(sess_dir, 'batch'));

  % Fill batch thing and send
  global SPM_BCH_VARS
  SPM_BCH_VARS = struct(...
      'work_dir', ana_dir, ...
      'sess_dir', sess_dir, ...
      'sesses', {sesses}, ...
      'ana_type', 1, ...          % model
      'm_file', fullfile(batch_dir, 'er_model_spm99'));
  spm_bch('do_bch_wrapper');
  model_file = fullfile(ana_dir, 'SPMcfg.mat');
  
 case 'SPM2'
  er_model_spm2(sess_dir, sesses, ana_dir);
  model_file = fullfile(ana_dir, 'SPM.mat');
  
end

return

function absf = sf_isabspath(path)
%=======================================================================
%-Returns true if path is absolute, false if relative (or empty)
switch (spm_platform('filesys'))
case 'unx'
	if (~isempty(path) & path(1)=='/'), absf=1; else, absf=0; end
case 'win'
	if (length(path)>1 & path(2)==':'), absf=1; else, absf=0; end
otherwise
	error('isabspath not coded for this filesystem');
end
return
