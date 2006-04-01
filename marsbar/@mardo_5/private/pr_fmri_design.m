function [SPM] = pr_fmri_design(SPM)
% MarsBaR version of spm_fMRI design - asssembles a design for fMRI studies
% FORMAT [SPM] = pr_fmri_design(SPM)
%
% This file is a hardly edited version of:
% @(#)spm_fMRI_design.m	2.34 Karl Friston 03/01/30
% See that (SPM2) version for comments etc
%
% $Id: pr_fmri_design.m 607 2006-03-30 20:54:55Z matthewbrett $
  
%-GUI setup
%-----------------------------------------------------------------------
SPMid    = spm('SFnBanner',mfilename,marsbar('ver'));
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);
spm_help('!ContextHelp',mfilename)

% construct Design matrix {X} - cycle over sessions
%=======================================================================

% global parameters
%-----------------------------------------------------------------------
try
	fMRI_T     = SPM.xBF.T;
	fMRI_T0    = SPM.xBF.T0;
catch
	global defaults
	d_fmri = mars_struct('getifthere', defaults, 'stats', 'fmri');
	if mars_struct('isthere', d_fmri, 't')
	  fMRI_T  = d_fmri.t;
	  fMRI_T0 = d_fmri.t0;
	else,
	  fMRI_T  = 16;
	  fMRI_T0 = 1;
	end;
	SPM.xBF.T  = fMRI_T;
	SPM.xBF.T0 = fMRI_T0;
end


% get nscan and RT if not in SPM
%-----------------------------------------------------------------------
try
	SPM.xY.RT;
catch
	spm_input('Basic parameters...',1,'d',mfilename)
	SPM.xY.RT = spm_input('Interscan interval {secs}','+1','r',[],1);
end
try
	SPM.nscan;
catch
        SPM.nscan = spm_input(['scans per session e.g. 64 64 64'],'+1');
end

% time units, dt = time bin {secs}
%-----------------------------------------------------------------------
SPM.xBF.dt = SPM.xY.RT/SPM.xBF.T;
try
	SPM.xBF.UNITS;
catch	
	str           = 'specify design in';
	SPM.xBF.UNITS = spm_input(str,'+1','scans|secs');
end

% separate specifications for non-relicated sessions
%-----------------------------------------------------------------------
rep     = 0;
if length(SPM.nscan) > 1 & ~any(diff(SPM.nscan)) & ~isfield(SPM,'Sess')
	str = 'are sessions replications';
	rep = spm_input(str,'+1','yes|no',[1 0]);
end

% Get basis functions
%-----------------------------------------------------------------------
try
	bf      = SPM.xBF.bf;
catch
	SPM.xBF = pr_spm_get_bf(SPM.xBF);
	bf      = SPM.xBF.bf;
end

% 1st or 2nd order Volterra expansion?
%-----------------------------------------------------------------------
try
	V   = SPM.xBF.Volterra;
catch
	str = 'model interactions (Volterra)';
	V   = spm_input(str,'+1','y/n',[2 1]);
	SPM.xBF.Volterra  = V;
end


% get session specific design parameters
%=======================================================================
Xx    = [];
Xb    = [];
Xname = {};
Bname = {};
for s = 1:length(SPM.nscan)

	% number of scans for this session
	%---------------------------------------------------------------
	k   = SPM.nscan(s);

	if (s == 1) | ~rep

		% create convolved stimulus functions or inputs
		%=======================================================

		% Get inputs, neuronal causes or stimulus functions U
		%-------------------------------------------------------
			U = pr_spm_get_ons(SPM,s);

		% Convolve stimulus functions with basis functions
		%-------------------------------------------------------
		[X,Xn,Fc] = pr_spm_volterra(U,bf,V);

		% Resample regressors at acquisition times (32 bin offset)
		%-------------------------------------------------------
		try
			X = X([0:(k - 1)]*fMRI_T + fMRI_T0 + 32,:);
		end

		% and orthonalise (within trial type)
		%-------------------------------------------------------
		for i = 1:length(Fc)
		  X(:,Fc(i).i) = pr_spm_orth(X(:,Fc(i).i));
		end

		% get user specified regressors
		%=======================================================
		try 
			C     = SPM.Sess(s).C.C;
			Cname = SPM.Sess(s).C.name;
		catch

			% covariates - C
			%-----------------------------------------------
			str   = sprintf('Session %d',s);
			spm_input('Other regressors',1,'d',str)
			C     = [];
			c     = spm_input('user specified','+1','w1',0);
      			while size(C,2) < c
		     		str = sprintf('regressor %i',size(C,2) + 1);
		    	 	 C  = [C spm_input(str,2,'e',[],[k Inf])];
			end

			% and their names - Cnames
			%-----------------------------------------------
			Cname = {};
			for i = 1:size(C,2)
				str      = sprintf('regressor %i',i);
				Cname{i} = spm_input('name of','+0','s',str);
			end
		end

		% append mean-corrected regressors and names
		%-------------------------------------------------------
		X      = [X spm_detrend(C)];
		Xn     = {Xn{:}   Cname{:}};

		% Confounds: Session effects 
		%=======================================================
		B      = ones(k,1);
		Bn{1}  = sprintf('constant');

	end

	% Session structure array
	%---------------------------------------------------------------
	SPM.Sess(s).U      = U;
	SPM.Sess(s).C.C    = C;
	SPM.Sess(s).C.name = Cname;
	SPM.Sess(s).row    = size(Xx,1) + [1:k];
	SPM.Sess(s).col    = size(Xx,2) + [1:size(X,2)];
	SPM.Sess(s).Fc     = Fc;

	% Append names
	%---------------------------------------------------------------
	for i = 1:length(Xn) 
		Xname{end + 1} = [sprintf('Sn(%i) ',s) Xn{i}];
	end
	for i = 1:length(Bn) 
		Bname{end + 1} = [sprintf('Sn(%i) ',s) Bn{i}];
	end

	% append into Xx and Xb
	%===============================================================
	Xx    = blkdiag(Xx,X);
	Xb    = blkdiag(Xb,B);

end %- for s


% finished
%-----------------------------------------------------------------------
SPM.xX.X      = [Xx Xb];
SPM.xX.iH     = [];
SPM.xX.iC     = [1:size(Xx,2)];
SPM.xX.iB     = [1:size(Xb,2)] + size(Xx,2);
SPM.xX.iG     = [];
SPM.xX.name   = {Xname{:} Bname{:}};


%-End
%-----------------------------------------------------------------------
spm_input('!DeleteInputObj')

