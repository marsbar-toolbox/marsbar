function d = pr_ev_diff(ev_tc, diff_func, varargin)
% method to calculate event height for % signal change
% FORMAT d = pr_ev_diff(ev_tc, diff_func, varargin)
% 
% Inputs
% ev_tc     - event time course
% diff_func - difference function; one of
%             'max'     - the maximum of the time course
%             'max-min' - the max minus the min
%             'abs max' - if abs(max) > abs(min) => max otherwise => min
%             'abs max-min' -  if abs(max) > abs(min) => (max - min) 
%                              otherwise => (min - max) 
%  
% $Id$

if nargin < 2
  diff_func = '';
end
if isempty(diff_func)
  diff_func = 'max';
end

[m n] = size(ev_tc);
d = zeros(1, n);
switch lower(diff_func)
 case 'max'
  d = max(ev_tc, [], 1);
 case 'max-min'
  d = max(ev_tc, [], 1) - min(ev_tc, [], 1);
 case 'abs max'
  [d i] = max(abs(ev_tc), [], 1);
  for s = 1:n, d(s) = ev_tc(i(s), s); end
 case 'abs max-min'
  mx = max(ev_tc, [], 1);
  mn = min(ev_tc, [], 1);
  i  = abs(mx) > abs(mn);
  d(i)  = mx(i)-mn(i);
  d(~i) = mn(~i)-mx(~i);
 case 'window'
  if nargin < 4, error('Need window and dt'); end
  w = round(varargin{1} / varargin{2}) + 1;
  d = mean(ev_tc(w(1):w(2), :), 1);
 otherwise
  error(sprintf('What is this difference function: %s?', diff_func));
end
