function varargout = ui_mevent_cb(et, action, varargin)
% method to handle callbacks from ui_mevent UI
% FORMAT varargout = ui_mevent_cb(et, action, varargin)
%
% $Id$

if nargin < 2
  error('Need action');
end

F = gcbf;

switch lower(action)
 case 'ok'
  set(findobj(F,'Tag','Done'),'UserData',1)
 case 'cancel'
  set(findobj(F,'Tag','Done'),'UserData',0)
 case 'new'
  et.event_types(end+1) = struct('name', 'New event', ...
				 'e_spec', []);
  [et ic] = ui_mevent_edit(et, length(et.event_types));
  if ~isempty(ic) % not cancelled
    pr_refresh_et(et, ic, F);
  end
 case 'edit'
  hList = findobj(F,'Tag','eList');
  ic = get(hList, 'Value');
  if isempty(ic)
    msgbox('Please select an event type to edit');
  elseif length(ic) > 1
    msgbox('Please select a single event type to edit');
  else
    [et ic] = ui_mevent_edit(et, ic);
    if ~isempty(ic) % not cancelled
      pr_refresh_et(et, ic, F, hList);
    end
  end
 case 'delete'
  hList = findobj(F,'Tag','eList');
  ic = get(hList, 'Value');
  if isempty(ic)
    msgbox('Please select event type(s) to delete');
  else
    et.event_types(ic) = [];
    pr_refresh_et(et, 1, F, hList);
  end  
 otherwise
  error([ action ' is deviant' ]);
end

return


  
  