function [onsets, durations] = event_onsets(D, e_spec)
% method gets (estimated) onsets and durations for event/session
% FORMAT [onsets durations] = event_onsets(D, e_spec)
%
% D          - design object
% e_spec     - event specification (see event_fitted for details)
% 
% Returns
% onsets     - onset times in TRs
% durations  - duration of events in TRs
%
% $Id$
  
if nargin < 2
  error('Need design and event spec');
end
if ~is_fmri(D)
  error('Needs FMRI design');
end
if prod(size(e_spec)) > 2
  error('Can only deal with one event at a time'); 
end
dt = bf_dt(D);
TR = tr(D);

s={'SPM99 design: attempting dodgy reconstruction of onsets/durations', ...
   'Reconstruction assumes that:',...
   'Events of this trial type never overlap in time (before convolution)', ...
   '(if they do, your SPM99 model will be badly messed up in any case)',...
   'and:', ...
   'The gap between the end of one event and beginning of the next ', ...
   sprintf('is always more than %3.2f seconds', dt)};
if verbose(D), warning(sprintf('%s\n', s{:})); end

s = e_spec(1);
e = e_spec(2);
SPM   = des_struct(D);
sf    = SPM.Sess{s}.sf{e}(:,1);

sfi    = find(sf);
dsfi   = [1; diff(sfi) > 1];
onsets = sfi(logical(dsfi));
durations = zeros(size(onsets));

for oi = 1:length(onsets)
  pos  = onsets(oi);
  durations(oi) = 0;
  while(sf(pos))
    durations(oi) = durations(oi) + 1;
    pos = pos + 1;
    if pos > length(sf), break, end
  end
end

sc = dt / TR;
onsets    = (onsets - 1) * sc;
durations = (durations - 1) * sc;
       
% In fact, the above is durations, as entered by the users.  The durations
% as expressed in the design matrix are given by (durations) * sc
