function [MVres] = pr_stat_compute_mv(SPM,Ic)
% private function to compute mutlivariate statistics across ROIs
% FORMAT [MVres] = pr_stat_compute_mv(SPM,Ic)
% 
% Input
% SPM       - SPM design structure
% Ic        - indices into contrast structure (xCon in SPM)
%  
% Output
% MVres     - mulitvariate result structure
%
% $Id$
  
%-Get contrast definitions (if available)
%-----------------------------------------------------------------------
try
  xCon  = SPM.xCon;
catch
  xCon  = [];
end

%-set all contrasts by default
%-----------------------------------------------------------------------
if nargin < 2
  Ic    = 1:length(xCon);
end
if any(Ic > length(xCon))
  error('Indices too large for contrast structure');
end


% Get relevant fields from design
xCon = xCon(Ic);
Xs = SPM.xX.xKXs;
V = SPM.xX.V;
betas = SPM.betas;
ResidualMS = SPM.ResidualMS;  
Y = summary_data(SPM.marsY);

% setup calculation
[nBetas nROI]   = size(betas);
nCon          = length(xCon);
[trRV trRVRV] = spm_SpUtil('trRV',Xs,V);
erdf = trRV^2/trRVRV;
RMS = sqrt(ResidualMS);

%--------------------------------------------------------------------	   
%- Multivariate analysis
%--------------------------------------------------------------------	   

MVres = struct('y_pre',[], 'y_obs', [], 'Pf', [], 'u', [], 'ds', [] );

if nCon == 1, return, end

YpY     = Y'*Y;

for ii = 1:nCon

	 xC  = xCon(ii); 

	 %--------------------------------------------------------------------
	 [NF, nu, h, d, M12, XG, sXG] = sf_model_mlm(Xs, V, nROI, xC, erdf);

	 %--------------------------------------------------------------------
	 %- Compute svd 
	 %--------------------------------------------------------------------
	 %- fprintf('%-40s\n','Computing Principal Components') 

	 Z	= ((NF*betas)./(ones(size(NF,1),1)*RMS));
	 S	= Z*Z';
	 S	= S/sum(nROI);
	 [u s u] = svd(S,0);
	 ds	= diag(s);
	 clear  s;


	 %--------------------------------------------------------------------
	 %- STATISTICS if any ...
	 %--------------------------------------------------------------------
	 %- Fq : F values for the last q eigein values.
	 %- P  : P values.for the last q eigein values.

	 Fq = zeros(1,h);
	 for q = 0:h-1;
     		 nu1	= d*(h-q);
    		 nu2	= d*nu - (d-1)*(4*(h-q)+2*nu)/(h-q+2);
    		 Fq(q+1)	= ((nu-2)/nu) * nu2/(nu2-2)*sum(ds(q+1:h))/(h-q);
	 end
	 Pf	= 1 - spm_Fcdf(Fq,nu1,nu2);


	 %- fprintf('%-40s\n','Computing predicted and observed temporal reponse') 
%keyboard

	 y_pre	= (pinv(XG)'* M12 * u)*diag(sqrt(ds)); % predicted temporal reponse
	 
	 gV = (diag(1./sqrt(ds))*Z)'*u;
	 y_obs	= (Y./(ones(size(Y,1),1)*RMS)/nROI)*gV;
	 
	%- save results for this constrast
	MVres(ii).y_pre  = y_pre;
	MVres(ii).y_obs  = y_obs;
	MVres(ii).Pf     = Pf;
	MVres(ii).u      = u;
	MVres(ii).ds     = ds;
	MVres(ii).df     = [nu1 nu2];	
	
end






%===================================================================
function [NF,nu,h,d,M12,XG,sXG] = sf_model_mlm(Xs, V, nROI, xC, erdf);
% Set sub-space of interest and the related matrix of normalisation. 
% FORMAT [NF,nu,h,d,M12,XG] = mm_model();
%- nu, h, d : degrees of freedom
%- NF : matrix of normalisation
%===================================================================


%--------------------------------------------------------------------
%- SET, COMPUTE,NORMALIZE SPACES OF INTEREST
%--------------------------------------------------------------------
%- set X10 and XG
%- XG= X -PG(X), PG projection operator on XG (cf. eq 1, 2)
%--------------------------------------------------------------------
sX1o	= spm_sp('set',spm_FcUtil('X1o',xC,Xs));
sXG	= spm_sp('set',spm_FcUtil('X0',xC,Xs));
X1o 	= spm_sp('oP',sX1o,Xs.X);
XG  	= spm_sp('r',sXG,Xs.X);

%- Compute Normalized effexts : M1/2=X'G*V*XG (cf eq 3)
%--------------------------------------------------------------------
% warning off;
up	= spm_sp('ox',sX1o); ; %- PG=up*up'
qi	= up'*Xs.X;
sigma	= up'*V*up;
M12	= (chol(sigma)*qi)';
M_12	= pinv(M12);

%- Compute NF : normalise factor (cf eq 4)
%--------------------------------------------------------------------
NF	= M_12*spm_sp('X',Xs)'*spm_sp('r',sXG,spm_sp('X',Xs));

%- degrees of freedom
%- nROI : number of ROI (corresponds to the number of Resels) 
%--------------------------------------------------------------------
d	= nROI*(4*log(2)/pi)^(3/2);
h	= sX1o.rk; %-rank of the sub-space of interest.
nu	= erdf;