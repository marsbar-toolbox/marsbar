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
 otherwise
  error([ action ' is deviant' ]);
end