function et = event_types_named(D)
% method returns event types structures for events with same names
% FORMAT et = event_types_named(D)
% 
% $Id$

[e_s enames] = event_specs(D);

ets = unique(enames);

for e = 1:length(ets)
  et(e).name = ets{e};
  in_evs = ismember(enames, ets{e});
  et(e).e_spec = e_s(:, in_evs);
end
