function marsS = comput_contrast(marsDe, xCon, Ic)
% compute and return stats
% FORMAT marsS = mars_stat_struct(marsDe, xCon, Ic)
% 
% marsDe     - Mars design structure
% xCon       - contrast structure
% Ic         - indices into contrast structure
%
% Output
% marsS      - Mars statistic result structure
%
% $Id$
  
if nargin < 2
  error('Need results and contrasts');
end
if nargin < 3
  Ic = 1:length(xCon)
end

%- results

[marsS.con marsS.stat, marsS.P, marsS.Pc] = ...
    mars_stat_compute(xCon(Ic), marsDe.xX.xKXs, marsDe.xX.V, ...
		      marsDe.betas, marsDe.ResMS);
marsS.MVres = mars_stat_compute_mv(xCon(Ic), marsDe.xX.xKXs, marsDe.xX.V, ...
				   marsDe.betas, marsDe.ResMS, marsDe.marsY.Y);
for i = 1:length(marsDe.marsY.cols)
  marsS.columns{i} = marsDe.marsY.cols{i}.name;
end
for i = 1:length(Ic)
  marsS.rows{i}.name = xCon(Ic(i)).name;
  marsS.rows{i}.stat = xCon(Ic(i)).STAT;
end
  