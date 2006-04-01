function SPM = pr_estimate(SPM, marsY)
% Estimation of a General Linear Model
% FORMAT SPM = pr_estimate(SPM, marsY)
% Inputs 
% SPM      - SPM design structure
% marsY    - marsY data object, or 2D data (Y) matrix
%
% Outputs
% SPM      - modified estimated design structure, with data contained as
%            field marsY
%
% Based on spm_spm from spm2:
% @(#)spm_spm.m	2.66 Andrew Holmes, Jean-Baptiste Poline, Karl Friston 03/03/27
%
% There are some changes in this version
% 1) The specified Vi field, can contain either
% a cell array, in which case it is standard SPM covariance components,
% or a struct array, in which case it can specify other methods of
% estimating the covariance, in particular, real AR(n) estimation
% 
% 2) The design will specify if the covariance should be calculated from
% the summarized time course(s), or from the component voxels, then
% averaged.  Voxel time courses are used by default, and if
% SPM.xVi.cov_calc is set to 'vox', but summary time
% courses can be used by setting SPM.xVi.cov_calc to 'summary'. 
% 
% 3) Normally, if the W matrix is present, the V matrix should also be
% present.  Because it is boring to calculate the V matrix and then WVW,
% if we know WVW is I, V can be present, but empty, in which case WVW is
% assumed to be I.  It just saves time.
% 
% $Id: pr_estimate.m 543 2004-12-14 08:58:05Z matthewbrett $

%-Say hello
%-----------------------------------------------------------------------
Finter   = spm('FigName','Stats: estimation...'); spm('Pointer','Watch')

%=======================================================================
% - A N A L Y S I S   P R E L I M I N A R I E S
%=======================================================================

%-Initialise
%=======================================================================
fprintf('%-40s: %30s','Initialising parameters','...computing')    %-#
xX            = SPM.xX;
[nScan nBeta] = size(xX.X);

%-Check confounds (xX.K) and non-sphericity (xVi)
%-----------------------------------------------------------------------
if ~isfield(xX,'K')
  xX.K  = 1;
end
try
  %-If covariance components are specified use them
  %---------------------------------------------------------------
  xVi   = SPM.xVi;
catch
  
  %-otherwise assume i.i.d.
  %---------------------------------------------------------------
  xVi   = struct(	'form',  'i.i.d.',...
			'V',	 speye(nScan,nScan));

end

% Work out what we are going to do
have_W     = isfield(xX, 'W');
have_V     = isfield(xVi, 'V');

% Work out type of covariance modelling. We get Vi, cov_type (as a string):
% one of 'SPM' or 'fmristat' and cov_vox, which is a flag set to 1 if all
% the voxel time courses should be used to calculate the resdiduals and
% covariance.
if ~have_V
  if ~isfield(xVi, 'Vi')
    error('No covariance specified, and no priors to calculate it');
  end
  Vi = xVi.Vi;
  if iscell(Vi)
    cov_type = 'SPM';
  elseif ~isstruct(Vi)
    error('Vi field should be cell or struct type')
  elseif ~isfield(Vi, 'type')
    error('Vi should have field specifying type');
  else
    cov_type = Vi.type;
  end
  
  % Covariance calculated on summary or voxel time courses
  cov_vox = 1;
  if isfield(xVi, 'cov_calc')
    cov_vox = strcmpi(xVi.cov_calc, 'vox');
  end
else cov_vox = 0; end

%-Get non-sphericity V
%=======================================================================
if have_V
  %-If xVi.V is specified proceed directly to parameter estimation
  %---------------------------------------------------------------
  V     = xVi.V;
  str   = 'parameter estimation';
else
  % otherwise invoke ReML selecting voxels under i.i.d assumptions
  %---------------------------------------------------------------
  V     = speye(nScan,nScan);
  str   = '[hyper]parameter estimation';
end

%-Get whitening/Weighting matrix: If xX.W exists we will save WLS
% estimates. Get WVW also, which can be assumed if W is a whitening
% matrix
%-----------------------------------------------------------------------
if have_W
  %-If W is specified, use it
  %-------------------------------------------------------
  W     = xX.W;
  if isempty(V)  % V is only inv(W*W')
    WVW = eye(nScan);
  else
    WVW = W*V*W';
  end
else
  if have_V
    % otherwise make W a whitening filter W*W' = inv(V)
    %-------------------------------------------------------
    [u s] = pr_spm_svd(xVi.V);
    s     = spdiags(1./sqrt(diag(s)),0,nScan,nScan);
    W     = u*s*u';
    W     = W.*(abs(W) > 1e-6);
    xX.W  = W;
    WVW   = eye(nScan);
  else
    % unless xVi.V has not been estimated - requiring 2 passes
    %-------------------------------------------------------
    W     = eye(nScan);
    str   = 'hyperparameter estimation (1st pass)';
  end
end

%-Design space and projector matrix [pseudoinverse] for WLS
%=======================================================================
xX.xKXs = spm_sp('Set',pr_spm_filter(xX.K,W*xX.X));		% KWX
xX.pKX  = spm_sp('x-',xX.xKXs);				% projector

%-If xVi.V is not defined compute Hsqr 
%-----------------------------------------------------------------------
if ~isfield(xVi,'V')
  Fcname = 'effects of interest';
  iX0    = [SPM.xX.iB SPM.xX.iG];
  xCon   = spm_FcUtil('Set',Fcname,'F','iX0',iX0,xX.xKXs);
  X1o    = spm_FcUtil('X1o', xCon(1),xX.xKXs);
  Hsqr   = spm_FcUtil('Hsqr',xCon(1),xX.xKXs);
  trRV   = spm_SpUtil('trRV',xX.xKXs);
  trMV   = spm_SpUtil('trMV',X1o);
end

fprintf('%s%30s\n',repmat(sprintf('\b'),1,30),'...done')               %-#

%=======================================================================
% - F I T   M O D E L   &   W R I T E   P A R A M E T E R    I M A G E S
%=======================================================================

% Select whether to work with all voxel data in ROIs, or summary data
% Using all data only makes sense for intial estimation of whitening
if ~have_W & cov_vox
  str = 'voxelwise';
  Y = region_data(marsY);
  Y = [Y{:}];
else
  str = 'pooled';
  Y = summary_data(marsY);
end

% Eliminate columns with zero variance
in_cols = any(diff(Y));
if ~any(in_cols), error('No variance to estimate model'); end
Y = Y(:, in_cols);

fprintf('%-40s: %30s\n','Covariance estimate',['...' str])               %-#
fprintf('%-40s: %30s','Model','...start')    %-#

n_roi = n_regions(marsY);

%-Intialise variables used in the loop 
%=======================================================================
[n S] = size(Y);                                    % no of time courses
Cy    = 0;					    % <Y*Y'> spatially whitened
CY    = 0;					    % <Y*Y'> for ReML
EY    = 0;					    % <Y>    for ReML
%-Whiten/Weight data and remove filter confounds
%-------------------------------------------------------
fprintf('%s%30s',repmat(sprintf('\b'),1,30),'filtering')	%-#

KWY   = pr_spm_filter(xX.K,W*Y);

%-General linear model: Weighted least squares estimation
%------------------------------------------------------
fprintf('%s%30s',repmat(sprintf('\b'),1,30),'estimation') %-#

beta  = xX.pKX*KWY;			%-Parameter estimates
res   = spm_sp('r',xX.xKXs,KWY);	%-Residuals
ResSS = sum(res.^2);			%-Residual SSQ
clear KWY				%-Clear to save memory


%-If ReML hyperparameters are needed for xVi.V
%-------------------------------------------------------
if ~have_V
  if n_roi > 1
    wstr = {'Pooling covariance estimate across ROIs',...
	    'This is unlikely to be valid; A better approach',...
	    'is to run estimation separately for each ROI'};
    fprintf('\n');
    warning(sprintf('%s\n', wstr{:}));
  end
  % Cy is whitened covariance matrix; only needed for SPM REML method
  if strcmp(cov_type, 'SPM')
    q  = diag(sqrt(trRV./ResSS'),0); % spatial whitening
    Y  = Y * q;
    Cy = Y*Y';
  end
end % have_V
		
%-if we are saving the WLS parameters
%-------------------------------------------------------
if have_W

  %-sample covariance and mean of Y (all voxels)
  %-----------------------------------------------
  CY         = Y*Y';
  EY         = sum(Y,2);
    
end % have_W
clear Y				%-Clear to save memory

fprintf('\n')                                                        %-#
spm_progress_bar('Clear')

%=======================================================================
% - P O S T   E S T I M A T I O N   C L E A N U P
%=======================================================================
if S == 0, warning('No time courses - empty analysis!'), end

%-average sample covariance and mean of Y (over voxels)
%-----------------------------------------------------------------------
CY          = CY/S;
EY          = EY/S;
CY          = CY - EY*EY';

%-If not defined, compute non-sphericity V using ReML Hyperparameters
%=======================================================================
if ~have_V

  %-Estimate of residual correlations through hyperparameters
  %---------------------------------------------------------------
  str    = 'Temporal non-sphericity (over voxels)';
  fprintf('%-40s: %30s\n',str,'...estimation') %-#
  Cy            = Cy/S;
  
  % Estimate for separable designs and covariance components
  %---------------------------------------------------------------
  if isstruct(xX.K)
    
    switch cov_type
     case 'SPM'
      % Store hyperparameters
      m     = length(Vi);
      h     = zeros(m,1);
     case 'fmristat'
      % Store AR coefficients
      h     = zeros(length(xX.K), Vi.order);
     otherwise 
      error(['Did not recognize covariance type: ' cov_type]);
    end
    
    V     = sparse(nScan,nScan); 
    for i = 1:length(xX.K)
      
      % extract blocks from bases
      %-----------------------------------------------
      q     = xX.K(i).row;
      
      % design space for estimation (with confounds in filter)	
      %-----------------------------------------------
      Xp         = xX.X(q,:);
      try
	Xp = [Xp xX.K(i).X0];
      end
      
      switch cov_type
       case 'SPM'
	% REML: extract blocks from bases
	%-----------------------------------------------
	p     = [];
	Qp    = {};
	for j = 1:m
	  if nnz(xVi.Vi{j}(q,q))
	    Qp{end + 1} = xVi.Vi{j}(q,q);
	    p           = [p j];
	  end
	end

	% ReML itself
	%-----------------------------------------------
	fprintf('%-30s- %i\n','  ReML Block',i);
	[Vp,hp]  = pr_spm_reml(Cy(q,q),Xp,Qp);
	V(q,q)   = V(q,q) + Vp;
	h(p)     = hp;
       
       case 'fmristat'
	% AR estimation
	[h(i,:) W(q,q)]  = pr_fmristat_ar(res(q,:),Xp,Vi.order);

      end
    end
  else
    [V,h] = pr_spm_reml(Cy,xX.X,xVi.Vi);
  end
  
  switch cov_type
   case 'SPM'
    % normalize non-sphericity and save hyperparameters
    %---------------------------------------------------------------
    V           = V*nScan/trace(V);
   case 'fmristat'
    % Set covariance matrix to empty, we have already calculated W
    %---------------------------------------------------------------
    V           = [];
    SPM.xX.W    = W;
  end
  
  xVi.h       = h;
  xVi.V       = V;			% Save non-sphericity xVi.V
  xVi.Cy      = Cy;			%-spatially whitened <Y*Y'>
  SPM.xVi     = xVi;			% non-sphericity structure
  
  % If xX.W is not specified use W*W' = inv(V) to give ML estimators
  %---------------------------------------------------------------
  if ~have_W
    % clear everything except SPM, marsY;
    vnames = who;
    vnames = vnames(~ismember(vnames, {'SPM','marsY'}));
    clear(vnames{:});
    SPM = pr_estimate(SPM,marsY);
    return
  end
end


%-Use non-sphericity xVi.V to compute [effective] degrees of freedom
%=======================================================================
xX.V            = pr_spm_filter(xX.K,pr_spm_filter(xX.K,WVW)');	% KWVW'K'
[trRV trRVRV]   = spm_SpUtil('trRV',xX.xKXs,xX.V);		% trRV (for X)
xX.trRV         = trRV;						% <R'*y'*y*R>
xX.trRVRV       = trRVRV;					%-Satterthwaite
xX.erdf         = trRV^2/trRVRV;				% approximation
xX.Bcov         = xX.pKX*xX.V*xX.pKX';				% Cov(beta)


%-scale ResSS by 1/trRV 
%-----------------------------------------------------------------------
ResMS           = ResSS/xX.trRV;

%-Create 1st contrast for 'effects of interest' (all if not specified)
%=======================================================================
Fcname          = 'effects of interest';
try
  iX0     = [xX.iB xX.iG];
catch
  iX0     = [];
end
xCon            = spm_FcUtil('Set',Fcname,'F','iX0',iX0,xX.xKXs);

%-Compute scaled design matrix for display purposes
%-----------------------------------------------------------------------
xX.nKX        = spm_DesMtx('sca',xX.xKXs.X,xX.name);

%-place fields in SPM
%-----------------------------------------------------------------------
SPM.betas                = ones(nBeta, n_roi) + NaN;
SPM.betas(:, in_cols)    = beta;	
SPM.ResidualMS           = ones(1, n_roi) + NaN;
SPM.ResidualMS(in_cols)  = ResMS;	

SPM.xVi        = xVi;				% non-sphericity structure
SPM.xVi.CY     = CY;				%-<(Y - <Y>)*(Y - <Y>)'> 

SPM.xX         = xX;				%-design structure

SPM.xCon       = xCon;				%-contrast structure

%=======================================================================
%- E N D: Cleanup GUI
%=======================================================================
fprintf('%s%30s\n',repmat(sprintf('\b'),1,30),'...done')               %-#
spm('FigName','Stats: done',Finter); spm('Pointer','Arrow')
fprintf('%-40s: %30s\n','Completed',spm('time'))                     %-#
fprintf('...use the results section for assessment\n\n')             %-#
