function [con,stat,Ps,Pc] = pr_stat_compute(SPM,Ic)
% private function to compute statistics for SPM2 design
% FORMAT [con stat Ps Pc] = pr_stat_compute(SPM,Ic)
% 
% Input
% SPM       - SPM design structure
% Ic        - indices into contrast structure (xCon in SPM)
%
% Output
% con       - contrast value (ess for F test)
% stat      - statistic value
% Ps        - uncorrected p value
% Pc        - P value Bonferroni corrected for number of columns analyzed
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
if any(Ic > length(xCon))
  error('Indices too large for contrast structure');
end

% OLS estimators and error variance estimate
%----------------------------------------------------------------
betas = SPM.betas;
Hp    = SPM.ResidualMS;

%-Compute contrast and statistic parameters
%=======================================================================
df = [NaN SPM.xX.erdf];
for i = 1:length(Ic)

  %-Canonicalise contrast structure with required fields
  %-------------------------------------------------------------------
  ic  = Ic(i);
  X1o           = spm_FcUtil('X1o',xCon(ic),SPM.xX.xKXs);
  [trMV,trMVMV] = spm_SpUtil('trMV',X1o,SPM.xX.V);
  df(1)         = trMV^2/trMVMV; % eidf
  
  switch(xCon(ic).STAT)
    
   case {'T'} %-Implement contrast as sum of betas
    
    con(i,:)   = xCon(ic).c'*betas;
    VcB        = xCon(ic).c'*SPM.xX.Bcov*xCon(ic).c; 
    stat(i,:)  = con(i,:)./sqrt(Hp*VcB);
    Ps(i,:)    = 1 - spm_Tcdf(stat(i,:),df(2));

   case 'F'  %-Implement ESS 
    
    %-Residual (in parameter space) forming mtx
    %-----------------------------------------------------------
    h          = spm_FcUtil('Hsqr',xCon(ic),SPM.xX.xKXs);
    con(i,:)   = sum((h * betas).^2, 1);
    stat(i,:)  = con(i,:) ./ Hp / trMV;
    Ps(i,:)    = (1 - spm_Fcdf(stat(i,:),df));

   otherwise
    %---------------------------------------------------------------
    error(['unknown STAT "',xCon(ic).STAT,'"'])
    
  end % (switch(xCon...)
end

% Compute corrected Bonferroni (corrected for number of regions)
n  = size(betas, 2);
Pc = 1-(1-Ps).^n;

