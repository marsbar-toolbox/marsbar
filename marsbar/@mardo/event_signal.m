function s = event_signal(D, e_spec, dur, diff_func, varargin)
% method to compute % signal change from fMRI events
% FORMAT s = event_signal(D, e_spec, dur, diff_func, varargin)
% 
% D          - design
% e_spec     - 2 by N array specifying events to combine
%                 with row 1 giving session number
%                 and row 2 giving event number in session
%                 This may in due course become an object type
% dur        - duration in seconds of event to estimate for
% diff_func  - function to calculate signal change from canonical event
%              one of 'max', 'max-min', 'abs max', 'abs max-min', 'window'
% varargin   - any needed arguments for diff_func
%              No arguments are needed for 
%              'max', 'max-min', 'abs max','abs max-min'
%              For 'window', you need a 1x2 vector with the time in
%              seconds over which to take the mean, and the length in
%              seconds of a time bin for the basis functions (returned
%              for example by bf_dt(my_design)
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
  diff_func = 'abs max';
end

if ~is_fmri(D) | isempty(e_spec)
  s = [];
  return
end
if ~is_mars_estimated(D)
  error('Need a MarsBaR estimated design');
end
if size(e_spec, 1) == 1, e_spec = e_spec'; end

e_s_l = size(e_spec, 2);
s     = 0;
s_mus = block_means(D);
SPM   = des_struct(D);
for e_i = 1:e_s_l
  es    = e_spec(:, e_i);
  ss    = es(1);
  Yh    = event_fitted(D, es, dur);
  d     = pr_ev_diff(Yh, diff_func, varargin{:});
  s     = s + d ./ s_mus(ss,:);
end
s = s / e_s_l * 100;