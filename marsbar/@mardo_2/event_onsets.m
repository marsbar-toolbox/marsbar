function [onsets, durations] = event_onsets(D, e_spec)
% method gets onsets and durations for event/session
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

s = e_spec(1);
e = e_spec(2);
SPM   = des_struct(D);

U = SPM.Sess(s).U(e);
onsets =    U.ons;
durations = U.dur;

if strcmp(SPM.xBF.UNITS, 'secs')
  TR = tr(D);
  onsets = onsets / TR;
  durations = durations / TR;
end

if prod(size(durations)) == 1
  durations = ones(size(onsets)) * durations;
end
