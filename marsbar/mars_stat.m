function mars_stat(spmD, marsY)
% compute and save statistics for timecourses
% FORMAT mars_stat(spmD, marsY)
% See spm_spm for details on the design specification, which are here
% passed as a structure spmD.  marsY contains the data to be analyzed
%
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
	
		KVi    = spm_filter('apply', xX.K, xX.xVi.Vi); 
		V      = spm_filter('apply', xX.K, KVi'); 
		Y      = spm_filter('apply', xX.K, Y);
		fprintf('Setting filter...');
		KXs    = spm_sp('Set', spm_filter('apply', xX.K, xX.X));
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
[spmD.betas spmD.ResMS xX.erdf] = mars_glm_estim(KXs, Y, V); 
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

%- save to results file
savestruct('mars_estimated', spmD);

%-Default F-contrasts (in contrast structure) 
%=======================================================================
F_iX0 = spmD.F_iX0;
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
save('mars_xCon.mat','xCon')

% set as default results
marsbar('set_results', 'mars_estimated.mat');
fprintf('Results loaded into MarsBar default results\n');

%=======================================================================
%- E N D: Cleanup GUI
%=======================================================================
spm_progress_bar('Clear')
spm('FigName','Stats: done',Finter); spm('Pointer','Arrow')
fprintf('%-40s: %30s\n','Completed',spm('time'))                     %-#
fprintf('...use the results section for assessment\n\n')             %-#

return