function SPM = pr_estimate(SPM, marsY)
% [Re]ML Estimation of a General Linear Model
% Based on spm_spm from spm2:
% @(#)spm_spm.m	2.66 Andrew Holmes, Jean-Baptiste Poline, Karl Friston 03/03/27
%
% $Id$

% hard coded (for now) flag to use voxel data for whitening filter
use_all_data = 1;

%-Say hello
%-----------------------------------------------------------------------
SPMid    = marsbar('get_cvs_version', mfilename('fullpath'));
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


%-Get non-sphericity V
%=======================================================================
try
  %-If xVi.V is specified proceed directly to parameter estimation
  %---------------------------------------------------------------
  V     = xVi.V;
  str   = 'parameter estimation';
  
  
catch
  % otherwise invoke ReML selecting voxels under i.i.d assumptions
  %---------------------------------------------------------------
  V     = speye(nScan,nScan);
  str   = '[hyper]parameter estimation';
end

%-Get whitening/Weighting matrix: If xX.W exists we will save WLS estimates
%-----------------------------------------------------------------------
try
  %-If W is specified, use it
  %-------------------------------------------------------
  W     = xX.W;
catch
  if isfield(xVi,'V')
    
    % otherwise make W a whitening filter W*W' = inv(V)
    %-------------------------------------------------------
    [u s] = pr_spm_svd(xVi.V);
    s     = spdiags(1./sqrt(diag(s)),0,nScan,nScan);
    W     = u*s*u';
    W     = W.*(abs(W) > 1e-6);
    xX.W  = sparse(W);
  else
    % unless xVi.V has not been estimated - requiring 2 passes
    %-------------------------------------------------------
    W     = speye(nScan,nScan);
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

fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')               %-#

%=======================================================================
% - F I T   M O D E L   &   W R I T E   P A R A M E T E R    I M A G E S
%=======================================================================

% Select whether to work with all voxel data in ROIs, or summary data
% Using all data only makes sense for intial estimation of whitening
if ~isfield(xX, 'W') & ...
      isfield(marsY, 'cols') & ...
      use_all_data
  Y = [marsY.cols{:}];
  Y = [Y(:).y];
else
  Y = marsY.Y;
end
n_roi = size(marsY.Y, 2);

%-Intialise variables used in the loop 
%=======================================================================
[n S] = size(Y);                                    % no of time courses
Cy    = 0;					    % <Y*Y'> spatially whitened
CY    = 0;					    % <Y*Y'> for ReML
EY    = 0;					    % <Y>    for ReML
%-Whiten/Weight data and remove filter confounds
%-------------------------------------------------------
fprintf('%s%30s',sprintf('\b')*ones(1,30),'filtering')	%-#

KWY   = pr_spm_filter(xX.K,W*Y);

%-General linear model: Weighted least squares estimation
%------------------------------------------------------
fprintf('%s%30s',sprintf('\b')*ones(1,30),' estimation') %-#

beta  = xX.pKX*KWY;			%-Parameter estimates
res   = spm_sp('r',xX.xKXs,KWY);	%-Residuals
ResSS = sum(res.^2);			%-Residual SSQ
clear KWY				%-Clear to save memory


%-If ReML hyperparameters are needed for xVi.V
%-------------------------------------------------------
if ~isfield(xVi,'V')
  if n_roi > 1
    wstr = {'Pooling covariance estimate across ROIs',...
	    'This is unlikely to be valid; A better approach',...
	    'is to run estimation separatly for each ROI'};
    fprintf('\n\n');
    warning(sprintf('%s\n', wstr{:}));
  end
  q  = diag(sqrt(trRV./ResSS'),0);
  Y  = Y * q;
  Cy = Y*Y';
end % (xVi,'V')
		
%-if we are saving the WLS parameters
%-------------------------------------------------------
if isfield(xX,'W')

  %-sample covariance and mean of Y (all voxels)
  %-----------------------------------------------
  CY         = Y*Y';
  EY         = sum(Y,2);
    
end % (xX,'W')
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
if ~isfield(xVi,'V')

  %-REML estimate of residual correlations through hyperparameters (h)
  %---------------------------------------------------------------
  str    = 'Temporal non-sphericity (over voxels)';
  fprintf('%-40s: %30s\n',str,'...REML estimation') %-#
  Cy            = Cy/S;
  
  % ReML for separable designs and covariance components
  %---------------------------------------------------------------
  if isstruct(xX.K)
    m     = length(xVi.Vi);
    h     = zeros(m,1);
    V     = sparse(nScan,nScan); 
    for i = 1:length(xX.K)
      
      % extract blocks from bases
      %-----------------------------------------------
      q     = xX.K(i).row;
      p     = [];
      Qp    = {};
      for j = 1:m
	if nnz(xVi.Vi{j}(q,q))
	  Qp{end + 1} = xVi.Vi{j}(q,q);
	  p           = [p j];
	end
      end
      
      % design space for ReML (with confounds in filter)	
      %-----------------------------------------------
      Xp         = xX.X(q,:);
      try
	Xp = [Xp xX.K(i).X0];
      end
      
      % ReML
      %-----------------------------------------------
      fprintf('%-30s- %i\n','  ReML Block',i);
      [Vp,hp]  = pr_spm_reml(Cy(q,q),Xp,Qp);
      V(q,q)   = V(q,q) + Vp;
      h(p)     = hp;
    end
  else
    [V,h] = pr_spm_reml(Cy,xX.X,xVi.Vi);
  end
  
  % normalize non-sphericity and save hyperparameters
  %---------------------------------------------------------------
  V           = V*nScan/trace(V);
  xVi.h       = h;
  xVi.V       = V;			% Save non-sphericity xVi.V
  xVi.Cy      = Cy;			%-spatially whitened <Y*Y'>
  SPM.xVi     = xVi;			% non-sphericity structure
  
  % If xX.W is not specified use W*W' = inv(V) to give ML estimators
  %---------------------------------------------------------------
  if ~isfield(xX,'W')
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
xX.V            = pr_spm_filter(xX.K,pr_spm_filter(xX.K,W*V*W')');	% KWVW'K'
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

%-Append contrasts for fMRI - specified by SPM.Sess(s).Fc(i)
%-----------------------------------------------------------------------
if isfield(SPM,'Sess')
  for s = 1:length(SPM.Sess)
    for i = 1:length(SPM.Sess(s).Fc)
      iX0           = 1:nBeta;
      iX            = SPM.Sess(s).col(SPM.Sess(s).Fc(i).i);
      iX0(iX)       = [];
      Fcname        = sprintf('Sess(%d):%s',s,SPM.Sess(s).Fc(i).name);
%     xCon(end + 1) = spm_FcUtil('Set',Fcname,'F','iX0',iX0,xX.xKXs);
    end
  end
end

%-Compute scaled design matrix for display purposes
%-----------------------------------------------------------------------
xX.nKX        = spm_DesMtx('sca',xX.xKXs.X,xX.name);

fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')               %-#

%-Save remaining results files and analysis parameters
%=======================================================================
fprintf('%-40s: %30s','Saving results','...writing')                 %-#

%-place fields in SPM
%-----------------------------------------------------------------------

SPM.betas      = beta;	
SPM.ResidualMS = ResMS;	

SPM.xVi        = xVi;				% non-sphericity structure
SPM.xVi.CY     = CY;				%-<(Y - <Y>)*(Y - <Y>)'> 

SPM.xX         = xX;				%-design structure

SPM.xCon       = xCon;				%-contrast structure

SPM.SPMid      = SPMid;

%=======================================================================
%- E N D: Cleanup GUI
%=======================================================================
fprintf('%s%30s\n',sprintf('\b')*ones(1,30),'...done')               %-#
spm('FigName','Stats: done',Finter); spm('Pointer','Arrow')
fprintf('%-40s: %30s\n','Completed',spm('time'))                     %-#
fprintf('...use the results section for assessment\n\n')             %-#
