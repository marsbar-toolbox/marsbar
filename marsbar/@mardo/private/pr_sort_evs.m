function evs = pr_sort_evs(evs, sort_type, downf)
% function to sort event according to sort type
% FORMAT evs = pr_sort_evs(evs, sort_type, downf)
%
% evs        - structure containing fields
%              'names': names of events
%              'e_spec': row1 = session row2 = event number
% sort_type  - one of 'session' 'event' 'name'
% downf      - 1 if descending sort, 0 otherwise (0 default)
% 
% Returns
% evs        - sorted event structure
% 
% $Id$
  
if nargin < 2
  error('Need event specs and sort type');
end
if nargin < 3
  downf = 0;
end

e_s = [evs.e_spec]';

switch lower(sort_type)
 case {'session no', 'session'}
  [tmp I] = sortrows(e_s);
 case {'event no', 'event'}
  [tmp I] = sortrows(e_s, [2 1]);
 case {'event name', 'name'}
  [tmp I] = sort(evs.names);
 otherwise
  error(['Crazy sorting too much with ' sort_type]);
end

if downf, I = flipud(I); end

evs.names = evs.names(I);
evs.e_spec = evs.e_spec(:, I);

return
