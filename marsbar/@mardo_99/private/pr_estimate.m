function spmD = pr_estimate(spmD, marsY)
% compute statistics for timecourses from design and data
% FORMAT spmD = pr_estimate(spmD, marsY)
% See spm_spm for details on the design specification, which are here
% passed as a structure spmD.  marsY contains the data to be analyzed
%
% Output 
% spmD    - design with estimated parameters, default contrasts
%
% Originally written by Jean-Baptiste Poline
% $Id$

%-Say hello
%-----------------------------------------------------------------------
Finter   = spm('FigName','Stats: estimation...'); spm('Pointer','Watch')
    
%-------------------------------------------------------------------------
%- set the methods

COV_estim = 'assumed';           % covariance is assumed to be imposed by filter K
GLM_resol = 'OLS';               % ordinary least square 
 

%-------------------------------------------------------------------------
%- get the design structure, the filter and the data
xX = spmD.xX;  
if ~isfield(spmD.xX,'X'), 
  error('Please load an SPMcfg containing an X')
end

% allow matrix or structure to be passed as input data
if isstruct(marsY)
  Y = marsY.Y;
else
  Y = marsY;
end
nROI = size(Y,2);  %- Y is a time by nROI matrix

%----------------------------------------------------------------------------------
%- Estimation of the covariance structure of the Ys
fprintf('\nEstimating covariance...');
switch COV_estim

	case {'AR(p)'}
		%- compute the temporal cov of Y (V) with AR(p)
		if ~isfield(xX,'xVi')
		   xX.xVi = struct(	'Vi', speye(size(xX.X,1)),...
					'Form',	'AR(p)'); 
		end
		% xX.xVi = estimate_cov(Y,xX);


	case {'assumed'}
		if ~isfield(xX,'xVi')
		   xX.xVi = struct(	'Vi', speye(size(xX.X,1)),...
					'Form',	'none'); 
		end
		%- else, the covariance structure is supposed to be
		%- stored in xX.xVi

	otherwise
		warning('COV_estim does not exist');
end
fprintf('Done\n');

switch GLM_resol

	case {'OLS'}
		fprintf('Using OLS\n');
		%- no filter already defined 
		if ~isfield(xX,'K')
		   xX.K  = speye(size(xX.X,1));
		end
		% else assume that the filter is xX.K
	
		KVi    = pr_spm_filter('apply', xX.K, xX.xVi.Vi); 
		V      = pr_spm_filter('apply', xX.K, KVi'); 
		Y      = pr_spm_filter('apply', xX.K, Y);
		fprintf('Setting filter...');
		KXs    = spm_sp('Set', pr_spm_filter('apply', xX.K, xX.X));
		fprintf('Done.\n');
		clear KVi;

	case {'MaxLik'} 
		'MaxLik' 
		%- compute the inverse filter -  put it in K ?
		%- filter data and design
		%- V = speye(size(xX.X,1));

	otherwise
		warning('GLM_resol does not exist');
end

%- compute GLM 
fprintf('Computing estimates...');
if ~spm_sp('isspc',KXs), Xs = spm_sp('set',KXs); else Xs = KXs;  end

[trRV trRVRV] = spm_SpUtil('trRV',Xs,V); 
spmD.betas    = spm_sp('x-', Xs, Y);                 %-Parameter estimates
res           = spm_sp('r', Xs, Y);                  %-Residuals
spmD.ResidualMS = sum(res.^2)./trRV;             %-Res variance estimation
xX.erdf      = trRV^2/trRVRV;

fprintf('Done.\n');

% fill up design related stuff
xX.V     = V; 	                                %-V matrix
xX.xKXs       = KXs;                            %-Filtered design matrix
xX.pKX        = spm_sp('x-',xX.xKXs);
xX.pKXV  = xX.pKX*xX.V;				%-for contrast variance weight
xX.Bcov  = xX.pKXV*xX.pKX';			%-Variance of est. param.
[xX.trRV,xX.trRVRV] ...				%-Variance expectations
         = spm_SpUtil('trRV',xX.xKXs,xX.V);
xX.nKX   = spm_DesMtx('sca',xX.xKXs.X,xX.Xnames);% scaled design matrix for display 

spmD.xX = xX;
spmD.marsY = marsY;

%-Default F-contrasts (in contrast structure) 
%=======================================================================
F_iX0 = [];
if isfield(spmD, 'F_iX0')
  F_iX0 = spmD.F_iX0;
end
if isempty(F_iX0)
  F_iX0 = struct(	'iX0',		[],...
			'name',		'all effects');
elseif ~isstruct(F_iX0)
  F_iX0 = struct(	'iX0',		F_iX0,...
			'name',		'effects of interest');
end

%-Create Contrast structure array
%-----------------------------------------------------------------------
xCon  = spm_FcUtil('Set',F_iX0(1).name,'F','iX0',F_iX0(1).iX0,xX.xKXs);
for i = 2:length(F_iX0)
	xcon = spm_FcUtil('Set',F_iX0(i).name,'F','iX0',F_iX0(i).iX0,xX.xKXs);
	xCon = [xCon xcon];
end
spmD.xCon = xCon;

%=======================================================================
%- E N D: Cleanup GUI
%=======================================================================
spm_progress_bar('Clear')
spm('FigName','Stats: done',Finter); spm('Pointer','Arrow')
fprintf('%-40s: %30s\n','Completed',spm('time'))                     %-#
fprintf('...use the results section for assessment\n\n')             %-#

return