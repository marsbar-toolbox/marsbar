function [SPM] = pr_fmri_design(SPM)
% MarsBaR version of spm_fMRI design - asssembles a design for fMRI studies
% FORMAT [SPM] = pr_fmri_design(SPM)
%
% This file is a hardly edited version of:
% @(#)spm_fMRI_design.m	2.27   Karl Friston 99/09/29
% See that (SPM99) version for comments etc
%
% $Id$ 
  
%-GUI setup
%-----------------------------------------------------------------------
SPMid    = spm('SFnBanner',mfilename,marsbar('ver'));
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);
spm_help('!ContextHelp',mfilename)

% construct Design matrix {X} - cycle over sessions
%=======================================================================

% Initialize variables
%-----------------------------------------------------------------------
STOC   = 0;

% global parameters
%-----------------------------------------------------------------------
global fMRI_T; 
global fMRI_T0; 
if isempty(fMRI_T),  fMRI_T  = 16; end;
if isempty(fMRI_T0), fMRI_T0 = 1;  end;

% get nscan and RT 
%-----------------------------------------------------------------------
spm_input('Basic parameters...',1,'d',mfilename)
RT = spm_input('Interscan interval {secs}','+1','r',[],1);
nscan = spm_input(['scans per session e.g. 64 64 64'],'+1');
STOC   = 1;
nsess  = length(nscan);
dt     = RT/fMRI_T;					% time bin {secs}

% separate specifications for non-relicated sessions
%-----------------------------------------------------------------------
rep = 0;
tim = 0;
if nsess > 1
	str = 'are conditions replicated';
	rep = spm_input(str,'+1','yes|no',[1 0])
	if rep & ~any(nscan - nscan(1))
		str = ['are timing/parameters the same'];
		tim = spm_input(str,'+1','yes|no',[1 0]);
	end
end
Xx    = [];
Xb    = [];
Xname = {};
Bname = {};
Sess  = {};
for s = 1:nsess

	% set prompt string
	%---------------------------------------------------------------
	if tim
		Fstr = 'All sessions';
	else
		Fstr = sprintf('Session %d/%d',s,nsess);
	end

	% Event/epoch related responses			
	%===============================================================
	k     = nscan(s);

	% specify event/epoch onsets {SF} for this session
	%---------------------------------------------------------------
	if (s == 1) | ~rep

		[SF,Cname,Pv,Pname,DSstr] = ...
			pr_spm_get_ons(k,fMRI_T,dt,STOC,Fstr,[],[],s);
		ntrial = size(SF,2);

	elseif ~tim

		[SF,Cname,Pv,Pname,DSstr] = ...
			pr_spm_get_ons(k,fMRI_T,dt,STOC,Fstr,ntrial,Cname,s);
	end

	% get basis functions for this session
	%---------------------------------------------------------------
        if (s == 1) | ~rep

		% get basis functions for responses
		%-------------------------------------------------------
		[BF BFstr] = pr_spm_get_bf(Cname,fMRI_T,dt,Fstr,s);
	end




	% complete design matrix partition for this session
	%---------------------------------------------------------------
        if (s == 1) | ~tim


		%-Reset ContextHelp
		%-------------------------------------------------------
		spm_help('!ContextHelp',mfilename)
		spm_input('Design matrix options...',1,'d',mfilename)

		if ~ntrial

			% declare variables
			%-----------------------------------------------
			ONS     = {};		% onset times
			PST     = {};		% Peri-stimulus times
			X       = [];		% design matrix
			Xn      = {};		% regressor names
			IND     = {};		% design matrix indices
			name    = {};		% condition names

		else

			% peri-stimulus {PST} and onset {ONS} (seconds)
			%-----------------------------------------------
			for   i = 1:ntrial
				on     = find(SF{i}(:,1))*dt;
				pst    = [1:k]*RT - on(1);			
				for  j = 1:length(on)
					u      = [1:k]*RT - on(j);
					v      = find(u >= -1);
					pst(v) = u(v);
				end
				ONS{i} = on;
				PST{i} = pst;
			end


			% convolve with basis functions
			%-----------------------------------------------
			str   = 'interactions among trials (Volterra)';
			if spm_input(str,'+1','y/n',[1 0])
  
			    [X Xn IND BF name] = pr_spm_volterra(SF,BF,Cname,2);

			else
			    [X Xn IND BF name] = pr_spm_volterra(SF,BF,Cname,1);
			end


			% Resample design matrix {X} at acquisition times
			%-----------------------------------------------
			X     = X([0:k-1]*fMRI_T + fMRI_T0,:);
		end


		% get user specified regressors
		%=======================================================
		spm_input('Other regressors',1,'d',Fstr)
		D     = [];
		c     = spm_input('user specified regressors','+1','w1',0);
                while size(D,2) < c
		      str   = sprintf('regressor %i',size(D,2) + 1);
		      D = [D spm_input(str,2,'e',[],[k Inf])];
		end
		if      c & length(DSstr)
			DSstr = [DSstr '& user specified covariates '];
		elseif  c
			DSstr = 'User specified covariates ';
		end

		% append regressors and names
		%-------------------------------------------------------
		for i = 1:size(D,2)
			X           = [X D(:,i)];
			str         = sprintf('regressor: %i',i);
			Xn{end + 1} = spm_input(['name of ' str],'+0','s',str);
		end



		% Confounds: Session effects 
		%=======================================================
		B      = ones(k,1);
		Bn{1}  = sprintf('constant');

	end

	% Session structure
	%---------------------------------------------------------------
	Sess{s}.BFstr = BFstr;
	Sess{s}.DSstr = DSstr;
	Sess{s}.rep   = tim;
	Sess{s}.row   = size(Xx,1) + [1:k];
	Sess{s}.col   = size(Xx,2) + [1:size(X,2)];
	Sess{s}.name  = name;
	Sess{s}.ind   = IND;
	Sess{s}.bf    = BF;
	Sess{s}.sf    = SF;
	Sess{s}.pst   = PST;
	Sess{s}.ons   = ONS;
	Sess{s}.Pv    = Pv;
	Sess{s}.Pname = Pname;

	% Append names
	%---------------------------------------------------------------
	q     = length(Xname);
	for i = 1:length(Xn) 
		Xname{q + i}  = [sprintf('Sn(%i) ',s) Xn{i}];
	end
	q     = length(Bname);
	for i = 1:length(Bn) 
		Bname{q + i}  = [sprintf('Sn(%i) ',s) Bn{i}];
	end

	% append into Xx and Xb
	%===============================================================
	[x y]   = size(Xx);
	[i j]   = size(X);
	Xx(([1:i] + x),([1:j] + y)) = spm_detrend(X);
	[x y]   = size(Xb);
	[i j]   = size(B);
	Xb(([1:i] + x),([1:j] + y)) = B;

end %- for s = 1:nsess

% finished
%-----------------------------------------------------------------------
xX     = struct(	'X',		[Xx Xb],...
			'dt',		dt,...
			'RT',		RT,...
			'iH',		[],...
			'iC',		[1:size(Xx,2)],...
			'iB',		[1:size(Xb,2)] + size(Xx,2),...
			'iG',		[],...
			'Xnames',	{[Xname Bname]});


%-End
%-----------------------------------------------------------------------
fprintf('\t%-32s: ','Saving fMRI design')                            %-#
SPM = struct('SPMid', SPMid, ...
	     'xX', xX,...
	     'Sess', {Sess});
fprintf('%30s\n\n','...saved')                    %-#
spm_input('!DeleteInputObj')

