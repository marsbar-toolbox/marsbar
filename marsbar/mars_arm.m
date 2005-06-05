function varargout = mars_arm(action, varargin)
% wrapper function for MarsBaR marmoire object
% FORMAT varargout = mars_arm(action, varargin)
% 
% This only to make the marsbar.m code prettier
% See the help for the marmoire object for details
% 
% $Id$

global MARS
if ~isfield(MARS, 'ARMOIRE')
  error('Global structure does not contain marmoire object');
end

if nargin < 1
  error('Need action');
end

o = MARS.ARMOIRE;

switch lower(action)
 case 'get'
  [varargout{1} o varargout{2}] = get_item_data(o, varargin{:});
 case 'set'
  [o varargout{1}] = set_item_data(o, varargin{:});
 case 'clear'
  [o varargout{1}] = clear_item_data(o, varargin{:});
 case 'set_ui'
  [o varargout{1}] = set_item_data_ui(o, varargin{:});  
 case 'update'
  [o varargout{1}] = update_item_data(o, varargin{:});
 case 'set_param'
  o = set_item_param(o, varargin{:});
 case 'get_param'
  varargout{1} = get_item_param(o, varargin{:});
 case 'save'
  [varargout{1} o] = save_item_data(o, varargin{:});
 case 'save_ui'
  [varargout{1} o] = save_item_data_ui(o, varargin{:});
 case 'isempty'
  varargout{1} = isempty_item_data(o, varargin{:});
 case 'item_exists'
  varargout{1} = item_exists(o, varargin{:});
 case 'show_summary'
  if nargin < 2, error('Need item name'); end
  item_name = varargin{1};
  if ~item_exists(o, item_name)
    error(['What is ' item_name '?']);
  end
  if mars_arm('isempty', item_name)
    S = {'[Empty]'};
  else
    S  = summary(get_item_data(o, item_name));
    fn = get_item_param(o, item_name, 'file_name');
    if isempty(fn), fn = '[Not set]'; end
    S  = [{['Filename: ' fn]} S];
  end  
  mars_utils('graphic_text', S, get_item_param(o, item_name, 'title'));
 otherwise
  error(['Weird: ' action]);
end

MARS.ARMOIRE = o;