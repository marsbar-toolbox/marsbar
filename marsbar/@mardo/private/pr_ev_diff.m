function d = pr_ev_diff(ev_tc, diff_func, varargin)
% method to calculate event height for % signal change
%
% $Id$

if nargin < 2
  diff_func = '';
end
if isempty(diff_func)
  diff_func = 'max';
end

switch lower(diff_func)
 case 'max'
  d = max(ev_tc);
 case 'max-min'
  d = max(ev_tc) - min(ev_tc);
 otherwise
  error('What is this difference function?');
end
