function I = pr_set(I, action, data, filename)
% private function to set data into item
% FORMAT I = pr_set(I, action, data, filename)
%
% I        - whole item, including parameters
% action   - one of: set set_ui get clear update
% data     - the data to set into this item
% filename - (possibly) filename for these data
%
% Returns
% I        - item with data set as specified
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
if I.char_is_filename & ischar(data)
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
  I.has_changed = 1;
else % don't need to save, but may need to load from file
  I.has_changed = 0;
  if isempty(data)
    data = load(filename, ['-' I.file_type]);
  end
end
I.data = data;

% If no filename passed:
% if new set, filename is empty
% if an update, filename stays
is_update = strcmp(action, 'update');
if pr_is_nan(filename)
  if ~is_update
    filename = '';
  end
end  
I.file_name = filename;

% If this was a clear, don't flag for save
if i_isempty(I), I.has_changed = 0; end

% and here is where we do the rules stuff
is_clear = strcmp(action, 'clear');
if ~isempty(I.set_action) & ...
      (ismember(action, {'get','set','set_ui'}) | ...
       (is_update & I.set_action_if_update) | ...
       (is_clear & I.set_action_if_clear))  
  [tmp errf msg] = eval(I.set_action);
  if errf
      res = [];
    warning(['Data not set: ' msg]);
    return
  end
  % work out if whole thing as been returned, or only data
  if isfield(tmp, 'set_action') % whole thing
    I = tmp;
  else % it's just the data
    I.data = tmp;
  end
end

% return set data
res = I.data;

% possibly remove data from structure 
if ~I.has_changed & I.leave_as_file
  I.data = [];
end

return
