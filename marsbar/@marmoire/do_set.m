function [o, errf] = do_set(o, item, flags, data, filename)
% private function to set data into item
% FORMAT [o, errf] = do_set(o, item, flags, data, filename)
%
% o           - object
% item        - name of item to set to
% flags       - containing fields:
%                 action: one of: 'set' 'set_ui' 'get' 'clear' 'update'
% data        - the data to set into this item
% filename    - (possibly) filename for these data
%
% Returns
% o           - returned object, probably modified
% errf        - flag set to 1 if error, meaning object was not modified
%
% The flags argument at the moment is a bit redundant, as it only
% contains one field, but allows for future expansion, and is more
% compatible with the do_save method.
%
% $Id$

if nargin < 2
  error('Need item');
end
if nargin < 3
  error('Need calling flags');
end
if nargin < 4
  data = NaN;
end
if nargin < 5
  filename = NaN;
end

% Errf for return
errf = 0;

% process flags
if ischar(flags)  % can be string, with action
  if ~isempty(flags)
    flags = struct('action', flags);
  end
end
if ~isstruct(flags), flags = []; end
if ~isfield(flags, 'action'), flags.action = 'set'; end
action = flags.action;

% get item to work on
item_struct = get_item_struct(o, item);

% get filename for data if set_ui
if strcmp(action, 'set_ui')
  [fn pn] = mars_uifile('get', ...
			item_struct.filter_spec, ...
			['Select ' item_struct.title '...']);
  if isequal(fn,0) | isequal(pn,0), errf = 1;, return, end
  filename = fullfile(pn, fn);
  data = [];
end

% Keep copy of passed filename for set_action call
passed_filename = filename;
  
% optionally, treat char data as filename
% but passed filename overrides char data
if item_struct.char_is_filename & ischar(data)
  if ~pr_is_nix(filename)
    warning(sprintf(...
	'Passed filename %s overrides data filename %s\n',...
	filename, data));
  else
    filename = data;
  end
  data = [];
end

if pr_is_nix(filename) % may need to save if no associated filename
  item_struct.has_changed = 1;
else % don't need to save, but may need to load from file
  item_struct.has_changed = 0;
  if isempty(data)
    data = load(filename, ['-' item_struct.file_type]);
  end
end
item_struct.data = data;

% If no filename passed:
% if new set, filename is empty
% if an update, filename stays
is_update = strcmp(action, 'update');
if pr_is_nan(filename)
  if ~is_update
    filename = '';
  end
end  
item_struct.file_name = filename;

% If this was a clear, don't flag for save
if pr_isempty(item_struct), item_struct.has_changed = 0; end

% Put processed stuff into object, and copy old object
% This so we can pass the candidate new object to the set_action routines
% for checking and/or changing, but still roll back if we need to.
old_o = o; 
o = set_item_struct(o, item, item_struct);

% and here is where we do the rules stuff
is_clear = strcmp(action, 'clear');
if ~isempty(item_struct.set_action) & ...
      (ismember(action, {'get','set','set_ui'}) | ...
       (is_update & item_struct.set_action_if_update) | ...
       (is_clear & item_struct.set_action_if_clear))  
  [tmp errf msg] = eval(item_struct.set_action);
  if errf
    o = old_o;
    warning(['Data not set: ' msg]);
    return
  end
  % work out what has been returned.  It can be:
  % object, item_struct, or data; we much prefer the object, to be
  % consistent
  if isa(tmp, 'marmoire')   % object
    o = tmp;
    item_struct = get_item_struct(o, item);
  elseif isstruct(tmp) & isfield(tmp, 'set_action') % item struct
    item_struct = tmp;
  else % it's just the data
    item_struct.data = tmp;
  end
end

% set has_changed, if update
if strcmp(action, 'update')
  item_struct.has_changed = 1;
end

% possibly remove data from structure 
if ~item_struct.has_changed & item_struct.leave_as_file
  item_struct.data = [];
end

% return object with data set
o = set_item_struct(o, item, item_struct);

return
