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
xX    = SPM.xX;
dt    = xX.dt;
ss    = e_spec(1);
en    = e_spec(2);
bf    = full(Sess{ss}.bf{en});

if ~dur  
  % SPM99 uses one time bin for events with no duration
  sf = 1; 
else
  sf    = ones(round(dur/dt), 1);
end
X = [];

for b = 1:size(bf,2)
  X = [X conv(sf, bf(:,b))];
end

return

% In SPM99 spm_graph, we also apply the filter
K{1}  = struct('HChoice',	'none',...
	       'HParam',	[],...
	       'LChoice',	xX.K{ss}.LChoice,...
	       'LParam',	xX.K{ss}.LParam,...
	       'row',		1:size(X,1),...
	       'RT',		dt);
X    = pr_spm_filter('apply',K,X);
