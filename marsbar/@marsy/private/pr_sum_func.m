function [sumY, varY] = pr_sum_func(y, sumfunc, wt)
% creates summary stats for region data
% FORMAT [sumY, varY] = pr_sum_func(y, sumfunc, wt)
% 
% $Id$
  
if nargin < 2
  error('Need data matrix and summary function');
end
[m n]   = size(y);
if any([m n] == 0)
  error('Data vector is empty');
end
if nargin < 3
  wt = [];
end
if isempty(wt)
  wt = ones(n,1);
end
if size(wt,1)==1
  wt = wt';
end
if n == 1 % only 1 sample in ROI
  sumY = y; varY = y*Inf;
  return
end

varY = ones(m,1) * Inf;
switch sumfunc
 case 'mean'
  sumY = mean(y, 2);
  ssy  = sum(y.^2, 2);
  varY = (ssy - n*sumY.^2)/(n-1);
 case 'wtmean'
  % Formulae from GNU scientific library
  % $\hat\mu = (\sum w_i x_i) / (\sum w_i)$
  % \hat\sigma^2 = ((\sum w_i)/((\sum w_i)^2 - \sum (w_i^2))) 
  %                \sum w_i (x_i - \hat\mu)^2$
  swt = sum(wt);
  sumY = y*wt/swt;
  varY = (swt/(swt.^2 - wt'*wt)) * ((y - (sumY * ones(1,n))).^2 * wt);

  % original formula
  %nwt = sum(wt ~= 0);
  %varY = (y - (sumY * ones(1,n))).^2 * wt / ((nwt-1) * swt / nwt);
 case 'median'
  sumY = median(y, 2);
 case 'eigen1'    
  % code taken from spm_regions.m l 230-247, with thanks
  % @(#)spm_regions.m	2.7 Karl Friston 00/10/04
  
% compute regional response in terms of first eigenvariate
%-----------------------------------------------------------------------
if m > n
	[v s v] = svd(spm_atranspa(y));
	s       = diag(s);
	v       = v(:,1);
	u       = y*v/sqrt(s(1));
else
	[u s u] = svd(spm_atranspa(y'));
	s       = diag(s);
	u       = u(:,1);
	v       = y'*u/sqrt(s(1));
end
d       = sign(sum(v));
u       = u*d;
v       = v*d;
sumY       = u*sqrt(s(1)/n);

% end of paste from spm_regions
      
 otherwise
  error(['Do not recognize summary function ' sumfunc]);
end