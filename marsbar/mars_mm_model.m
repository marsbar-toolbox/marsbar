function varargout = mars_mm_model(varargin);
% set sub-space of interest and the related matrix of normalisation. 
%- Format varargout = mars_mm_model(varargin);
%
%- See subfunction for details.
% based on mm_model by Ferath Kherif and Jean-Baptiste Poline
%====================================================================
%
% $Id$

[NF,nu,h,d,M12,XG,sXG] = sf_model_mlm(varargin{2:nargin});
varargout 	= {NF,nu,h,d,M12,XG,sXG};
		


	
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
up	= spm_sp('uk',sX1o); ; %- PG=up*up'
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