function varargout = mars_armoire(action, item, data, filename)
% multifunction function to get/set various stores of stuff
% (armoire is the French for cupboard).
% FORMAT varargout = mars_armoire(action, item, data, filename)
%  
% This cupboard is to put items which I will want to fish out 
% from time to time.
% 
% The items may well be associated with a filename
% If they are associated with a filename when set, they 
% are assumed to have been saved already.
% If not, they are flagged as awaiting a save
%
% If the data changes, you can indicate this with the 
% update method, which changes the data, and flags for a save
% 
% In terms of the program structure, the function acts an object container,
% but where the objects are only half implemented, in this case as fields in
% a global variable MARMOIRE. 
%
% The permissable actions are:
%
% add            - add an item to the armoire
% exist          - ask if there an exists an item of given name
% add_if_absent  - adds item if it does not yet exist
% set            - sets data for item 
% get            - gets data from item
% set_ui         - sets data, getting via UI
% save           - save data for item, if required
% save_ui        - saves, using GUI to ask for filename
%                  For save and save_ui, the 'data' argument
%                  can contain a structure with flags.  
%                  Fields in flag structure can be
%                  'force' - force save even if not flagged as needed
%                  'warn_empty' - GUI warn if no data to save
%                  'ync' - start save with save y/n/cancel dialog
%                  'prompt' - prompt for save; 
%                  'prompt_suffix - suffix for prompt
%                  'prompt_prefix - prefix for prompt
%                  'ui' - use UI prompts for save - forced if save_ui
%                  'no_no_save' - if 'no' is chosen in the save dialog,
%                     contents are flagged as not needing a save in
%                     the future (has_changed flag set to 0)  
% save 'all'     - saves data for all items, if required
% update         - updates data, sets flag to show change
% clear          - clears data for item
% isempty        - returns 1 if no data for item
% need_save      - returns 1 if this item needs a save
%
% And for use in debugging:
% dump           - returns contents of the underling variable
%   
% for any other action string, mars_armoire will look to see if the action
% matches any of the field names in the structures and get/set this
% fieldname value (set if data is not empty, get otherwise)
%                 
% Each item is stored in a field in the global variable
%
% The name of the field is the 'item' argument to this function
% Each item field requires the following fields
%                 
% data            - the data 
%                   (or a filename which loads as the data - see the
%                   char_is_filename field)
% has_changed     - flag, if set, means data has changed since first set
% save_if_changed - flag, if set, will try to save changed data when a
%                   save is requested.  Saves can also be forced.
% leave_as_file   - flag, if set, will attempt to leave the data, defined
%                   by the filename, on the disk, not in memory, and only
%                   load the data for a 'get'.  
%                   Otherwise, if a set occurs, and the data field is
%                   empty, will load data into the global variable when
%                   'set'ing field and leave it there.
%                   If the data changes, and requires a save, this field
%                   has no function, until the next save.
% file_name       - file name of .mat file containing data
%                   If data is empty, and file_name is not, 
%                   an attempt to 'get' data will load contents of
%                   file_name
% default_file_name - default filename offered for save 
% file_type       - type of file to load ('mat' or 'ascii')
% char_is_filename - flag, if set, char data is assumed to be a filename
% filter_spec     - filter spec for uigetfile (see help uigetfile)
% prompt          - prompt for uigetfile
% verbose         - flag, if set, displays more information during
%                   processing
% set_action      - actions to perform when item is set
%                   in form of callback string.  This is executed
%                   in the 'i_set' subfunction, and can use all
%                   variables functions defined therein.  See programmers
%                   notes in the function for callback format
% set_action_if_update - flag, if set, applied set_action for 'update' as
%                   well as 'set'
% set_action_if_clear - flag, if set, applied set_action for 'clear' as
%                   well as 'set'
% 
% $Id$
  
% Programmers' notes
% ------------------
% set_action callbacks
% callbacks should be one of the following two formats;
%
% [data errf msg] = my_function(args)  or
% [item_field errf msg] = my_function(args) 
%
% The first form just returns the data desired to be set, 
% the second returns the whole item field, where the data
% is contained in the field 'data'.
% if 'errf' is set, the routine warns, and abort the set with 
% the 'msg'.
%
% The available args are:
% I      - proposed whole item field contents
% data   - proposed data to be inserted 
% passed_filename - filename passed to function
% 
% and anything else...
  
% NaN for an argument signals it has not been passed
% empty means that it was passed, but was empty
if nargin < 1 % no action
  error('Need action!');
  return
end
if ~ismember(action, {'dump'})
  if nargin < 2  % no item
    error('Need item!');
    return
  end
end
if nargin < 3
  data = NaN;
end
if nargin < 4
  filename = NaN;
end

% certain actions do not require valid item names
if ~ismember(action, ...
	     {'add', 'add_if_absent', 'exist', 'dump', 'save_all'})
  % the rest do
  flist = i_item_list;
  switch item
   case 'all'
    % If item is 'all', do this action for all items
    % Watch for save_ui, as we need to look out for cancel
    s_u_f = strcmp(lower(action), 'save_ui');
    a = {};
    for fn = flist'
      a{end+1} = mars_armoire(action, fn{1}, data, filename);
      if s_u_f & (a{end} == -1), varargout = {-1}; return, end
    end
    varargout = a;
    return
   otherwise
    % item must be a field name in structure
    % fetch and set name field
    if ~ismember(item, flist)
      error([item ' is an unaccountable item']);
    end
    i_contents = i_up_dump(item);
    i_contents.name = item;
    i_contents.last_action = action;
  end
end

% run actions
switch lower(action)
 case 'add'
  data.name = item;
  I = i_def;
  def_fns = fieldnames(I);
  new_fns = def_fns(~ismember(def_fns, fieldnames(data)));
  for fn = new_fns'
    data = setfield(data, fn{1}, getfield(I, fn{1}));
  end
  i_down_dump(data);
 case 'add_if_absent'
  if ~mars_armoire('exist', item)
    mars_armoire('add', item, data); 
  end
 case 'exist'
  varargout = {ismember(item, i_item_list)};
 case 'default_item'
  varargout = {i_def};
 case 'set'
  if is_nan(data) & is_nan(filename)
    varargout = {i_set_ui(i_contents)};
  else
    varargout = {i_set(i_contents, data, filename)};
  end
 case 'get'
  if i_isempty(i_contents)
    varargout = {i_set_ui(i_contents)};
  else
    varargout = {i_get(i_contents)};
  end
 case 'set_ui'
  varargout = {i_set_ui(i_contents)};
 case 'update'
  varargout = {i_set(i_contents, data, filename)};
  i_contents = i_up_dump(item);
  i_contents.has_changed = 1;
  i_down_dump(i_contents);
 case 'clear'
  varargout = {i_set(i_contents, [], '')}; 
 case 'save'
  if is_nix(filename) & ...
	isempty(i_contents.file_name)
    varargout = {i_save_ui(i_contents, data, filename)};
  else
    varargout = {i_save(i_contents, data, filename)};
  end
 case 'save_ui'
  % data is used as flags for save call
  if ~isstruct(data), data = []; end
  data.ui = 1;
  varargout = {i_save_ui(i_contents, data, filename)};
 case 'need_save'
  varargout = {i_need_save(i_contents)};
 case 'isempty'
  varargout = {i_isempty(i_contents)};
 case 'dump'
  varargout = {i_dump};
 otherwise
  % look in fieldnames
  if ismember(action, fieldnames(i_contents))
    if ~is_nan(data) % it's a set
      i_contents = setfield(i_contents, action, data);
      i_down_dump(i_contents);
    end
    varargout = {getfield(i_contents, action)};
  else % really, this must be a mistake
    error(['The suggested action, ' action ', is disturbing']);
  end
end
return % end of main function

function I = i_def
% returns default item
I = struct('data', [],...
	   'file_name', '',...
	   'default_file_name','',...
	   'has_changed', 0,...
	   'leave_as_file', 0,...
	   'save_if_changed', 1,...
	   'file_type', 'mat',...
	   'char_is_filename',1,...
	   'set_action_if_update', 0 ,...
	   'set_action_if_clear', 0 ,...
	   'verbose', 1,...
	   'title', 'file',...
	   'filter_spec', '',...
	   'set_action', '');
return

function res = i_isempty(I)
res = isempty(I.data) & isempty(I.file_name);
return

function res = i_set_ui(I)
[fn pn] = mars_uifile('get', I.filter_spec, ['Select ' I.title '...']);
if isequal(fn,0) | isequal(pn,0), res = []; return, end
res = i_set(I, [], fullfile(pn, fn));
return


function res = i_set(I, data, filename)

% Keep copy of passed filename for set_action call
passed_filename = filename;
  
% optionally, treat char data as filename
% but passed filename overrides char data
if I.char_is_filename & ischar(data)
  if ~is_nix(filename)
    warning(sprintf(...
	'Passed filename %s overrides data filename %s\n',...
	filename, data));
  else
    filename = data;
  end
  data = [];
end

if is_nix(filename) % may need to save if no associated filename
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
is_update = strcmp(I.last_action, 'update');
if is_nan(filename)
  if ~is_update
    filename = '';
  end
end  
I.file_name = filename;

% If this was a clear, don't flag for save
if i_isempty(I), I.has_changed = 0; end

% and here is where we do the rules stuff
is_clear = strcmp(I.last_action, 'clear');
if ~isempty(I.set_action) & ...
      (ismember(I.last_action, {'get','set','set_ui'}) | ...
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

% do the actual save into global structure
i_down_dump(I);

return

function res = i_get(I)
res = I.data;
if isempty(res) & ~isempty(I.file_name)
  res = load(I.file_name, ['-' I.file_type]);
end
return

function res = i_save_ui(I, flags, filename)
if ~isstruct(flags), flags = []; end
if i_isempty(I) & isfield(flags, 'warn') 							
  msgbox('Nothing to save', [I.title ' is not set'], 'warn');
  res = 0;
  return
end
flags.ui = 1;
res = i_save(I, flags, filename);
return

function res = i_save(I, flags, filename)
% data field is treated as flags
if is_nix(flags) flags == []; end
if is_nix(filename), filename = I.file_name; end
if is_nix(filename), filename = I.default_file_name; end
if i_need_save(I) | isfield(flags, 'force') % force flag
  % prompt for filename if UI
  if isfield(flags, 'ui')
    % Work out prompt
    if isfield(flags, 'prompt')
      prompt = flags.prompt;
    else 
      prompt = I.title;
    end
    if isfield(flags, 'prompt_prefix')
      prompt = [flags.prompt_prefix prompt];
    end
    if isfield(flags, 'prompt_suffix')
      prompt = [prompt flags.prompt_suffix];
    end
    if isfield(flags, 'ync')
      save_yn = questdlg(['Save ' prompt '?'],...
			 'Save', 'Yes', 'No', 'Cancel', 'Yes');
      if strcmp(save_yn, 'Cancel'), res = -1; return, end      
      if strcmp(save_yn, 'No')
	if isfield(flags, 'no_no_save')
	  I.has_changed = 0; 
	  i_down_dump(I);
	end
	res = 0; 
	return
      end
    end
    pr = ['Filename to save ' prompt]; 
    [f p] = mars_uifile('put', I.filter_spec, pr, filename);
    if all(f==0), res = -1, return, end
    filename = fullfile(p, f);
  end
  savestruct(I.data, filename);
  if I.verbose
    fprintf('%s saved to %s\n', I.title, filename);
  end
  I.file_name = filename;
  I.has_changed = 0;
  if I.leave_as_file
    % maintain only on file, as it has beed saved
    I.data = [];
  end
  res = 1;
  i_down_dump(I);
else
  res = 0;
end
return

function res = i_need_save(I)
res = ~i_isempty(I) & I.has_changed & I.save_if_changed;
return

function res = is_nix(v)
res = isempty(v) | is_nan(v);
return

function res = is_nan(v)
res = 0;
if isnumeric(v) & ~isempty(v)
  res = isnan(v);
end
return

function items = i_item_list
items = g_fieldnames;
return

function I = i_up_dump(i_name)
I = g_getfield(i_name);
return

% Routines below explicity manipulate global variable

function I = i_dump
global MARMOIRE
I = MARMOIRE;
return

function I = i_down_dump(I)
global MARMOIRE
MARMOIRE = setfield(MARMOIRE, I.name, I); 
return

function fns = g_fieldnames
global MARMOIRE
if isempty(MARMOIRE) | ~isstruct(MARMOIRE)
  fns = {};
else
  fns = fieldnames(MARMOIRE);
end
return

function r = g_getfield(fn)
global MARMOIRE
r = getfield(MARMOIRE, fn);
return
