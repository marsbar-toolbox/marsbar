function [marsD] = compute_contrast(marsDe, xCon, Ic)
% compute and return stats
% FORMAT marsS = compute_contrast(marsDe, Ic)
% 
% marsDe     - Mars design structure
% Ic         - indices into contrast structure
%
% Output
% marsS      - Mars statistic result structure
%
% $Id$

SPM = des_struct(marsDe);
xCon = SPM.xCon;
  
if nargin < 2
  error('Need results and contrasts');
end
if nargin < 3
  Ic = 1:length(xCon)
end

%- results

[marsS.con marsS.stat, marsS.P, marsS.Pc] = ...
    pr_stat_compute(xCon(Ic), SPM.xX.xKXs, SPM.xX.V, ...
		      SPM.betas, SPM.ResMS);
marsS.MVres = pr_stat_compute_mv(xCon(Ic), SPM.xX.xKXs, SPM.xX.V, ...
				 SPM.betas, SPM.ResMS, SPM.marsY.Y);
for i = 1:length(SPM.marsY.cols)
  marsS.columns{i} = SPM.marsY.cols{i}.name;
end
for i = 1:length(Ic)
  marsS.rows{i}.name = xCon(Ic(i)).name;
  marsS.rows{i}.stat = xCon(Ic(i)).STAT;
end
  