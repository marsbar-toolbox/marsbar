function [marsS] = compute_contrasts(marsDe, Ic)
% compute and return stats
% FORMAT marsS = compute_contrasts(marsDe, Ic)
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
  Ic = 1:length(xCon);
end

%- results

[marsS.con marsS.stat, marsS.P, marsS.Pc] = ...
    pr_stat_compute(xCon(Ic), SPM.xX.xKXs, SPM.xX.V, ...
		      SPM.betas, SPM.ResidualMS);
marsS.MVres = pr_stat_compute_mv(xCon(Ic), SPM.xX.xKXs, SPM.xX.V, ...
				 SPM.betas, SPM.ResidualMS, ...
				 summary_data(SPM.marsY));

marsS.columns = region_name(SPM.marsY);
for i = 1:length(Ic)
  marsS.rows{i}.name = xCon(Ic(i)).name;
  marsS.rows{i}.stat = xCon(Ic(i)).STAT;
end
  