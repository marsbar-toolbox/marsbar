function [K, LFstr, HFstr] = pr_get_filter(RT, row)
% gets filter using spm_fmri_spm_ui routines
% FORMAT [K, LFstr, HFstr]= pr_get_filter(RT, row)
% or
% FORMAT [K, LFstr, HFstr]= pr_get_filter(RT, Sess)
%
% $Id$
  
if nargin < 2
  error('Need TR, row / Sess matrix');
end

% number of sessions
nsess = length(row);

% rows from Sess
if isfield(row{1}, 'row')
  Sess = row;
  for s = 1:nsess
    row{s} = Sess{s}.row;
  end
else
  Sess = [];
end

% copied from spm_fmri_spm_ui
BM = 0;

% High-pass filtering
%-----------------------------------------------------------------------
if BM
	cLF = 'none';
else
	cLF = spm_input('High-pass filter?','+1','b','none|specify');
end
switch cLF

	case 'specify'

	if ~isempty(Sess)
	% default based on peristimulus time
	% param = cut-off period (max = 512, min = 32)
	%---------------------------------------------------------------
	HParam = 512*ones(1,nsess);
	for  i = 1:nsess
		for j = 1:length(Sess{i}.pst)
		   HParam(i) = min([HParam(i) 2*max(RT + Sess{i}.pst{j})]);
		end
	end
	HParam = ceil(HParam);
	HParam(HParam < 32) = 32;
	else % don't have SPM to work from
	  HParam = 120 * ones(1,nsess);
	end
	str    = 'session cutoff period (secs)';
	HParam = spm_input(str,'+1','e',HParam,[1 nsess]);

	% LF description
	%---------------------------------------------------------------
	LFstr = sprintf('[min] Cutoff period %d seconds',min(HParam));

	case 'none'
	%---------------------------------------------------------------
	HParam = cell(1,nsess);
	LFstr  = cLF;

end


% Low-pass filtering
%-----------------------------------------------------------------------
if BM
	cHF = 'none';
else
	cHF = spm_input('Low-pass filter?','+1','none|Gaussian|hrf');


end
switch cHF

	case 'Gaussian'
	%---------------------------------------------------------------
	LParam  = spm_input('Gaussian FWHM (secs)','+1','r',4);
	HFstr   = sprintf('Gaussian FWHM %0.1f seconds',LParam);
	LParam  = LParam/sqrt(8*log(2));

	case {'hrf', 'none'}
	%---------------------------------------------------------------
	LParam  = [];
	HFstr   = cHF;

end

% create filter struct and band-pass specification
%-----------------------------------------------------------------------
for i = 1:nsess
	K{i} = struct(	'HChoice',	cLF,...
			'HParam',	HParam(i),...
			'LChoice',	cHF,...
			'LParam',	LParam,...
			'row',		row{i},...
			'RT',		RT);
end

% Construct K struct
%=======================================================================
K       = pr_spm_filter('set',K);
        
