function Yf = apply_filter(D, Y)
% applies filter in design to data
% FORMAT Yf = ap(D, Y)
%
% D      - design, which includes a filter
% Y      - data to filter (2D matrix)
%
% Returns
% Yf     - filtered data
%
% $Id$
  
if nargin < 2
  error('Need data to filter');
end
if is_fmri(D) & ~has_filter(D)
  error('This FMRI design does not contain a filter');
end

SPM = des_struct(D);
Yf = pr_spm_filter('apply', SPM.xX.K, Y);
