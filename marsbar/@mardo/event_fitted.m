function [tc, dt] = event_fitted(D, event_spec, dur)
% method to compute fitted event time course
% FORMAT [tc dt]  = event_fitted(D, event_spec, dur)
% 
% D          - design
% event_spec - 2 by N array specifying events to combine
%                 with row 1 giving session number
%                 and row 2 giving event number in session
%                 This may in due course become an object type
% dur        - duration in seconds of event to estimate for
% 
% Returns
% tc         - fitted event time course, averaged over events
% dt         - time units (seconds per row in X)
%
% $Id$ 

if nargin < 2
  error('Need event specification');
end
if nargin < 3
  dur = 0;
end

if ~is_fmri(D) | isempty(event_spec)
  tc = [];
  return
end
if ~is_mars_estimated(D)
  error('Need a MarsBaR estimated design');
end

e_s_l = size(event_spec, 2);
SPM   = des_struct(D);
betas = SPM.betas;
tc    = zeros(1, size(betas, 2));
for e_i = 1:e_s_l
  es    = event_spec(:, e_i);
  ss    = es(1);
  [X dt]= event_regressor(D, es, dur);
  B     = betas(event_cols(D, es), :);
  Yh    = X*B;
  sz    = size(Yh, 1);
  szo   = size(tc, 1);
  if sz > szo
    tc(end+1:sz, :) = 0;
  end
  tc(1:sz,:) = tc(1:sz,:) + Yh;  
end
tc = tc / e_s_l;