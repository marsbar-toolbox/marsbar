function F = pr_refresh_et(et, ic, F, hList)
% Refreshes data and display of event type window after edit
% FORMAT F = pr_refresh_et(et, ic, F, hList)
% 
% et             - event type object
% ic             - indices to events to select
% F              - (optional) figure handle
% hList          - (optional) handle to list uicontrol
% 
% Returns
% F              - figure handle (in case you didn't have it
%
% $Id$
  
if nargin < 1
  error('Need object');
end
if nargin < 2
  ic = [];
end
if nargin < 3
  F = findobj(get(0, 'Children'), 'Flat', 'Tag', 'ui_mevent');
end
if nargin < 4
  hList = findobj(F, 'Tag','eList');
end

if ~ishandle(F)
  error('Could not find ui_mevent window');
end

% Event type list to put
if isfield(et.event_types, 'name')
  eNames = {et.event_types(:).name};
else
  eNames = {};
end

set(hList, 'String', eNames);
set(hList, 'Value', ic);
set(F, 'Userdata', et);
