function F = pr_refresh_et(D, ic, F, hList, hEdit)
% Refreshes data and display of event type window after edit
% FORMAT F = pr_refresh_et(D, ic, F, hList)
% 
% D              - design object
% ic             - indices to events to select
% F              - (optional) figure handle
% hList          - (optional) handle to list uicontrol
% hEdit          - (optional) handle to Edit uicontrol
% 
% Returns
% F              - figure handle (in case you didn't have it)
%
% $Id$
  
if nargin < 1
  error('Need object');
end
if nargin < 2
  ic = [];
end
if nargin < 3
  F = findobj(get(0, 'Children'), 'Flat', 'Tag', 'ui_event_types');
end
if nargin < 4
  hList = findobj(F, 'Tag','eList');
end
if nargin < 5
  hEdit = findobj(F, 'Tag','eEdit');
end

if ~ishandle(F)
  error('Could not find ui_event_types window');
end

et = event_types(D);

% Event type list to put
if isfield(et, 'name')
  eNames = {et(:).name};
else
  eNames = {};
end

set(hList, 'String', eNames);
set(hList, 'Value', ic);
set(F, 'Userdata', D);
set(hEdit, 'UserData', 1);