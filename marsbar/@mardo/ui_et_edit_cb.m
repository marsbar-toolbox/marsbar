function varargout = ui_et_edit_cb(D, action, varargin)
% method to handle callbacks from ui_et_edit 
% FORMAT varargout = ui_et_edit_cb(D, action, varargin)
%
% $Id$

if nargin < 2
  error('Need action');
end

F  = gcbf;
action = lower(action);
switch action
 case 'ok'
  % Deblank name, and check name is not empty
  hName = findobj(F, 'Tag', 'ui_et_name');
  new_name = get(hName, 'String');
  old_name = get(hName, 'UserData');
  new_name = deblank(fliplr(deblank(fliplr(new_name))));
  if isempty(new_name) | strcmp(new_name, 'New event')
    msgbox('Need a name for this event type'); return
  end
  % Check if name has been changed
  if ~strcmp(new_name, old_name)
    % Check name has not been used 
    ets = event_types(D);
    if ~isempty(ets)
      if ismember(new_name, {ets(:).name})
	msgbox(['Event type ' new_name ' already exists']); return
      end    
    end
  end
  % Check events not empty
  if isempty(get(findobj(F, 'Tag', 'ui_et_IN'), 'String'))
    msgbox('Need events for this event type'); return
  end
  % Put (deblanked) string back, and set Done flag
  set(hName, 'String', new_name);
  set(findobj(F,'Tag','ui_et_done'),'UserData',1);
 case 'cancel'
  set(findobj(F,'Tag','ui_et_done'),'UserData',0);
 case {'add', 'remove'}
  switch action
   case 'add'
    hListTO   = findobj(F, 'Tag', 'ui_et_IN');
    hListFROM = findobj(F, 'Tag', 'ui_et_OUT');
   case 'remove'
    hListFROM   = findobj(F, 'Tag', 'ui_et_IN');
    hListTO     = findobj(F, 'Tag', 'ui_et_OUT');
  end
  TO_evs  = get(hListTO,  'UserData');
  FROM_evs = get(hListFROM, 'UserData');
  if isempty(FROM_evs), msgbox(['No events to ' action]); end
  es_to_add = get(hListFROM, 'Value');
  if isempty(es_to_add)
    msgbox(['Please select events to ' action]); return
  end
  TO_evs.names   = [TO_evs.names; FROM_evs.names(es_to_add)];
  FROM_evs.names(es_to_add) = [];
  TO_evs.e_spec = [TO_evs.e_spec FROM_evs.e_spec(:, es_to_add)];
  FROM_evs.e_spec(:, es_to_add) = [];
  set(hListTO, 'UserData', TO_evs);
  set(hListFROM, 'UserData', FROM_evs);
  set(hListFROM, 'Value', []);
  ui_et_edit_cb(D, 'sort');
 case 'sort'
  sort_obj  = findobj(F, 'Tag', 'ui_et_sort');
  sort_strs = cellstr(get(sort_obj, 'String'));
  sort_type = sort_strs{get(sort_obj, 'Value')};
  for H = [findobj(F, 'Tag', 'ui_et_IN') findobj(F, 'Tag', 'ui_et_OUT')]
    evs = pr_sort_evs(get(H, 'UserData'), sort_type);
    set(H, 'String', evs.names);
    set(H, 'UserData', evs);
  end
 otherwise
  error([ action ' is deviant' ]);
end

return


  
  