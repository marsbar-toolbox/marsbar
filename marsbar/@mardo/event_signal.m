function s = event_signal(D, event_spec, dur, diff_func, varargin)
% method to compute % signal change from fMRI events
% FORMAT s = event_signal(D, event_spec, dur, diff_func, varargin)
% 
% D          - design
% event_spec - 2 by N array specifying events to combine
%                 with row 1 giving session number
%                 and row 2 giving event number in session
%                 This may in due course become an object type
% dur        - duration in seconds of event to estimate for
% diff_func  - function to calculate signal change from canonical event
%              one of 'max', 'max-min'
% varargin   - any needed arguments for diff_func
% 
% Returns
% s          - average % signal change over the events
%              1 by n_regions vector
%
% $Id$ 

if nargin < 2
  error('Need event specification');
end
if nargin < 3
  dur = 0;
end
if nargin < 4
  diff_func = '';
end
if isempty(diff_func)
  diff_func = 'max';
end

if ~is_fmri(D) | isempty(event_spec)
  s = [];
  return
end
if ~is_mars_estimated(D)
  error('Need a MarsBaR estimated design');
end
if size(event_spec, 1) == 1, event_spec = event_spec'; end

e_s_l = size(event_spec, 2);
s     = 0;
s_mus = block_means(D);
SPM   = des_struct(D);
for e_i = 1:e_s_l
  es    = event_spec(:, e_i);
  ss    = es(1);
  Yh    = event_fitted(D, es, dur);
  d     = pr_ev_diff(Yh, diff_func, varargin{:});
  s     = s + d/s_mus(ss);
end
s = s / e_s_l * 100;