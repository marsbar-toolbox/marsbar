function [marsS] = compute_contrasts(marsDe, Ic)
% compute and return results of contrast statistics
% FORMAT marsS = compute_contrasts(marsDe, Ic)
% 
% marsDe     - design object
% Ic         - indices into contrast structure
%
% Output
% marsS      - statistic result structure
%
% For the 'con', 'stat' 'P' 'Pc' fields below, the results are matrices
% with one row per contrast, one column per ROI estimated
%
% The statistics results structure has fields
% 'con'      - contrast value (numerator of t statistic, or ESS for F)
% 'stat'     - t or F statistic value
% 'P'        - uncorrected P value
% 'Pc'       - P values corrected for number of ROIs
% 'MVres'    - multivariate results structure with fields
%              'y_pre'    - predicted temporal response
%              'y_obs'    - observerd temporal response
%              'Pf'       - probabability for last (rank of subspace)
%                           eigenvalues  
%              'u'        - principle components
%              'ds'       - component weights (diag(S))
%              'df'       - degrees of freedom for Pf              
% 'columns'  - names of regions
% 'rows'     - cell array of structs, one per contrast calculated,
%              with fields:
%              'name'  - contrast name
%              'stat'  - statistic type (T|F)
%
% $Id$

SPM = des_struct(marsDe);
xCon = SPM.xCon;
  
if nargin < 2
  Ic = 1:length(xCon);
end

%- results
[marsS.con marsS.stat, marsS.P, marsS.Pc] = ...
    pr_stat_compute(SPM, Ic);
marsS.MVres = pr_stat_compute_mv(SPM, Ic);

marsS.columns = region_name(SPM.marsY);
for i = 1:length(Ic)
  marsS.rows{i}.name = xCon(Ic(i)).name;
  marsS.rows{i}.stat = xCon(Ic(i)).STAT;
end
  