function varargout = ui_event_types_cb(D, action, varargin)
% method to handle callbacks from ui_event_types
% FORMAT varargout = ui_event_types_cb(D, action, varargin)
%
% $Id$

if nargin < 2
  error('Need action');
end

et = event_types(D);
F  = gcbf;

switch lower(action)
 case 'ok'
  set(findobj(F,'Tag','Done'),'UserData',1)
 case 'cancel'
  set(findobj(F,'Tag','Done'),'UserData',0)
 case 'new'
  e = struct('name', 'New event', 'e_spec', []);
  if isempty(et), et = e; else et = [et e]; end
  D = event_types(D, et);
  [D ic] = ui_et_edit(D, length(et));
  if ~isempty(ic) % not cancelled
    pr_refresh_et(D, ic, F);
  end
 case 'edit'
  hList = findobj(F,'Tag','eList');
  ic = get(hList, 'Value');
  if isempty(ic)
    msgbox('Please select an event type to edit');
  elseif length(ic) > 1
    msgbox('Please select a single event type to edit');
  else
    et = event_types(D);
    [D ic] = ui_et_edit(D, ic);
    if ~isempty(ic) % not cancelled
      pr_refresh_et(D, ic, F, hList);
    end
  end
 case 'delete'
  hList = findobj(F,'Tag','eList');
  ic = get(hList, 'Value');
  if isempty(ic)
    msgbox('Please select event type(s) to delete');
  else
    et(ic) = [];
    D = event_types(D, et);
    pr_refresh_et(D, 1, F, hList);
  end  
 otherwise
  error([ action ' is deviant' ]);
end

return


  
  