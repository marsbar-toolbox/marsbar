function [SPM con stat P Pc] = pr_stat_compute(SPM,Ic)
% private function to compute statistics for SPM2 design
% 
% Based on:
% @(#)spm_contrasts.m	2.3 Andrew Holmes, Karl Friston & Jean-Baptiste Poline 02/12/30
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

% OLS estimators and error variance estimate
%----------------------------------------------------------------
beta = SPM.betas;
Hp   = SPM.ResMS;

%-Compute & store contrast parameters, contrast/ESS images, & SPM images
%=======================================================================
spm('Pointer','Watch')

for i = 1:length(Ic)

  %-Canonicalise contrast structure with required fields
  %-------------------------------------------------------------------
  ic  = Ic(i);
  if isempty(xCon(ic).eidf)
    X1o           = spm_FcUtil('X1o',xCon(ic),SPM.xX.xKXs);
    [trMV,trMVMV] = spm_SpUtil('trMV',X1o,SPM.xX.V);
    xCon(ic).eidf = trMV^2/trMVMV;
  end
  
  switch(xCon(ic).STAT)
    
   case {'T','P'} %-Implement contrast as sum of betas
    
    con(i,:)   = xCon(ii).c'*betas;
    VcB        = xCon(ic).c'*SPM.xX.Bcov*xCon(ic).c; 
    stat(i,:)  = cB./sqrt(ResMS*VcB);
    P(i,:)     = 1 - spm_Tcdf(stat(ii,:), erdf);

   case 'F'  %-Implement ESS 
    
    %-Residual (in parameter space) forming mtx
    %-----------------------------------------------------------
    h          = spm_FcUtil('Hsqr',xCon(ic),SPM.xX.xKXs);
    con(i,:)   = sum((h * beta).^2);
    MVM   = spm_get_data(xCon(ic).Vcon,XYZ)/trMV;
    RVR   = spm_get_data(VHp,XYZ);
    stat(i,:)  = con./ResMS/trMV;;
    P(ii,:) = 1 - spm_Fcdf(stat(i,:), [dfnum(end) erdf]);

   otherwise
    %---------------------------------------------------------------
    error(['unknown STAT "',xCon(ic).STAT,'"'])
    
  end % (switch(xCon...)
end

% place xCon back in SPM
%-----------------------------------------------------------------------
SPM.xCon = xCon;
