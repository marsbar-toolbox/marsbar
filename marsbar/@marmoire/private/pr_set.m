function item_struct = pr_set(item_struct, action, data, filename)
% private function to set data into item
% FORMAT item_struct = pr_set(item_struct, action, data, filename)
%
% item_struct - whole item, including parameters
% action      - one of: set set_ui get clear update
% data        - the data to set into this item
% filename    - (possibly) filename for these data
%
% Returns
% item_struct - item structure with data set as specified
%
% $Id$

if nargin < 1
  error('Need item');
end
if nargin < 2
  error('Need calling action');
end
if nargin < 3
  data = NaN;
end
if nargin < 4
  filename = NaN;
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

% and here is where we do the rules stuff
is_clear = strcmp(action, 'clear');
if ~isempty(item_struct.set_action) & ...
      (ismember(action, {'get','set','set_ui'}) | ...
       (is_update & item_struct.set_action_if_update) | ...
       (is_clear & item_struct.set_action_if_clear))  
  [tmp errf msg] = eval(item_struct.set_action);
  if errf
      res = [];
    warning(['Data not set: ' msg]);
    return
  end
  % work out if whole thing as been returned, or only data
  if isfield(tmp, 'set_action') % whole thing
    item_struct = tmp;
  else % it's just the data
    item_struct.data = tmp;
  end
end

% return set data
res = item_struct.data;

% possibly remove data from structure 
if ~item_struct.has_changed & item_struct.leave_as_file
  item_struct.data = [];
end

return
