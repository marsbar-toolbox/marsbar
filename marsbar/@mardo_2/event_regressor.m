function [X, dt] = event_regressor(D, e_spec, dur)
% method gets estimated regressor for single event 
% FORMAT [X dt] = event_regressor(D, e_spec, dur)
%
% D          - design object
% e_spec     - event specification (see event_fitted for details)
% dur        - event duration in seconds (default = 0)
% 
% Returns
% X          - event regressor for single event 
%              (one column per basis function used to model event)
% dt         - time units (seconds per row in X)
%
% $Id$
  
if nargin < 2
  error('Need design and event spec');
end
if nargin < 3
  dur = 0;
end
if ~is_fmri(D)
  error('Needs FMRI design');
end

if size(e_spec, 1) == 1, e_spec = e_spec'; end

SPM   = des_struct(D);
Sess  = SPM.Sess;
dt    = SPM.xBF.dt;
bf    = SPM.xBF.bf;
ss    = e_spec(1);
en    = e_spec(2);

if ~dur  
  % SPM2 does a second's worth of spike for events without durations
  sf = 1/dt; 
else
  sf    = ones(round(dur/dt), 1);
end
X = [];
for b = 1:size(bf,2)
  X = [X conv(sf, bf(:,b))];
end
