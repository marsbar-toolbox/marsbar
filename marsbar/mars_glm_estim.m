function [Betas, RMS, erdf] = mars_glm_estim(X, Y, V)
% does General Linear Model given data, design, covariance
% FORMAT [Betas, RMS, erdf] = mars_glm_estim(X, Y, V)
%
% X     - design matrix
% Y     - data natrix
% V     - covariance matrix
% 
% Output 
% Betas - parameter estimates
% RMS   - root mean square of residuals
% erdf  - error degrees of freedom
%
% $Id$
  
if ~spm_sp('isspc',X), Xs = spm_sp('set',X); else Xs = X; clear X, end 
[nScan nBeta] = spm_sp('size',Xs);
[nScan nVar]  = size(Y);

[trRV trRVRV] = spm_SpUtil('trRV',Xs,V);

Betas     = spm_sp('x-', Xs, Y);                 %-Parameter estimates
res       = spm_sp('r', Xs, Y);                  %-Residuals
RMS       = sqrt(sum(res.^2)./trRV);             %-Res variance estimation

erdf      = trRV^2/trRVRV;