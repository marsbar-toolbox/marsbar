function [marsD] = estimate(marsD, marsY)
% estimate method - estimates GLM for SPM2 model
%
% $Id$
  
% get SPM design structure
SPM = des_struct(marsD);
  
% do estimation
SPM = pr_estimate(SPM, marsY);

% return modified structure
marsD = des_struct(marsD, SPM);

