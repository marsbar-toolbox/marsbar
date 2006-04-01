function [K, str] = pr_get_filter(RT, row)
% gets filter using spm_fmri_spm_ui routines
% FORMAT [K, str]= pr_get_filter(RT, row)
% or
% FORMAT [K, str]= pr_get_filter(RT, Sess)
%
% $Id: pr_get_filter.m 77 2003-12-25 09:00:03Z matthewbrett $
  
if nargin < 2
  error('Need TR, row / Sess matrix');
end

% number of sessions
nsess = length(row);

% rows from Sess
if isfield(row(1), 'row')
  Sess = row;
  row = {};
  for s = 1:nsess
    row{s} = Sess(s).row;
  end
else
  Sess = [];
end

switch spm_input('High-pass filter?','+1','b','none|specify');
  
 case 'specify'  
  % default 128 seconds
  %-------------------------------------------------------
  HParam = 128*ones(1,nsess);
  p_str    = 'cutoff period (secs)';
  HParam = spm_input(p_str,'+1','e',HParam,[1 nsess]);
  str = sprintf('Cutoff: %d {s}', HParam);
  
 case 'none'     
  % Inf seconds (i.e. constant term only)
  %-------------------------------------------------------
  HParam = Inf*ones(1,nsess);
  str = 'none';
end

% create and set filter struct
%---------------------------------------------------------------
for  i = 1:nsess
  K(i) = struct(	'HParam',	HParam(i),...
			'row',		row{i},...
			'RT',		RT);
end
K = pr_spm_filter(K);
