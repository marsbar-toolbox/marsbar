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
% a global variable MARS.ARMOIRE. 
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
% save 'all'     - saves data for all items, if required
% update         - updates data, sets flag to show change
% clear          - clears data for item
% isempty        - returns 1 if no data for item
% need_save      - returns 1 if this item needs a save
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
% can_change      - flag, if set, this data can change
% has_changed     - flag, if set, means data has changed
% save_if_changed - flag, if set, will try to save changed data
% load_on_set     - flag, if set, and data field is empty, loads data when
%                   'set'ing field; otherwise, if data field is empty, loads
%                   data again for each 'get'
% file_name       - file name of .mat file containing data
%                   If data is empty, and file_name is not, 
%                   an attempt to 'get' data will load contents of
%                   file_name
% char_is_filename - flag, if set, char data is assumed to be a filename
% filter          - filter for GUI to suggest new file_name
% prompt          - prompt for spm_get GUI
% verbose         - flag, if set, displays more information during
%                   processing
% set_action      - actions to perform when item is set
%                   in form of callback string.  This is executed
%                   in the 'i_set' subfunction, and can use all
%                   variables functions defined therein
% set_action_if_update - flag, if set, applied set_action for 'update' as
%                   well as 'set'
% $Id$
  
% persistent variable containing items
global MARS

if isempty(MARS) | ~isfield(MARS, 'ARMOIRE') 
  MARS.ARMOIRE = [];
end

if nargin < 1 % no action
  error('Need action!');
  return
end
if nargin < 2  % no item
  error('Need item!');
  return
end
if nargin < 3
  data = [];
end
if nargin < 4
  filename = '';
end

% certain actions do not require valid item names
if ~ismember(action, {'add', 'add_if_absent', 'exist'})
  % the rest do
  flist = fieldnames(MARS.ARMOIRE);
  switch item
   case 'all'
    % If item is 'all', do this action for all items
    a = {};
    for fn = flist'
      a{end+1} = mars_armoire(action, fn{1}, data);
    end
    varargout = a;
    return
   otherwise
    % item must be a field name in structure
    % fetch and set name field
    if ~isstruct(MARS.ARMOIRE)
      error(['Armoire is not ready for ' action]); 
    end
    flist = fieldnames(MARS.ARMOIRE);
    if ~ismember(item, flist)
      error([item ' is an unaccountable item']);
    end
    i_contents = getfield(MARS.ARMOIRE, item);
    i_contents.name = item;
    i_contents.last_action = action;
  end
end

% run actions
switch lower(action)
 case 'add'
  data.name = item;
  data = fillafromb(data, i_def);
  i_dump(data);
 case 'add_if_absent'
  if ~mars_armoire('exist', item)
    mars_armoire('add', item, data); 
  end
 case 'exist'
  varargout = {isfield(MARS.ARMOIRE, item)};
 case 'default_item'
  varargout = {i_def};
 case 'set'
  if isempty(data) & isempty(filename)
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
  i_contents.has_changed = 1;
  i_dump(i_contents);
 case 'clear'
  varargout = {i_set(i_contents, [], '')}; 
 case 'save'
  if isempty(filename) & isempty(i_contents.file_name)
    varargout = {i_save_ui(i_contents, data, filename)};
  else
    varargout = {i_save(i_contents, data, filename)};
  end
 case 'save_ui'
  % data is used as flags for save call
  if ~ischar(data), data = ''; end
  varargout = {i_save_ui(i_contents, [data 'u'], filename)};
 case 'need_save'
  varargout = {i_need_save(i_contents)};
 case 'isempty'
  varargout = {i_isempty(i_contents)};
 otherwise
  % look in fieldnames
  if ismember(action, fieldnames(i_contents))
    if ~isempty(data) % it's a set
      i_contents = setfield(i_contents, action, data);
      i_dump(i_contents);
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
	   'can_change', 0, ...
	   'has_changed',0,...
	   'load_on_set', 1,...
	   'save_if_changed', 0,...
	   'char_is_filename',1,...
	   'set_action_if_update', 0 ,...
	   'verbose', 1,...
	   'title', 'file',...
	   'filter', '',...
	   'set_action', '');
return

function res = i_isempty(I)
res = isempty(I.data) & isempty(I.file_name);
return

function res = i_set_ui(I)
prompt = ['Select ' I.title '...'];
filename = spm_get([0 1], I.filter, prompt);
if isempty(filename), res = [];, return, end
res = i_set(I, [], filename);
return


function res = i_set(I, data, filename)
  
% optionally, treat char data as filename
% but passed filename overrides char data
if I.char_is_filename & ischar(data)
  if ~isempty(filename)
    warning(sprintf(...
	'Passed filename %s overrides data filename %s\n',...
	filename, data));
  else
    filename = data;
  end
  data = [];
end

if isempty(filename) % may need to save if no associated filename
  I.has_changed = 1;
else % don't need to save, but may need to load from file
  I.has_changed = 0;
  if I.load_on_set & isempty(data)
    data = load(filename);
  end
end
I.data = data;
I.file_name = filename;

% If this was a clear, don't flag for save
if i_isempty(I), I.has_changed = 0; end

% and here is where we do the rules stuff
if ~isempty(I.set_action) & ...
	      ~(strcmp(I.last_action, 'update') & ...
		     ~I.set_action_if_update)
  eval(I.set_action)
end

% do the actual save into global structure
i_dump(I);

% The data may be empty if we haven't loaded it
res = data;
return

function res = i_get(I)
res = I.data;
if isempty(res) & ~isempty(I.file_name)
  res = load(I.file_name);
end
return

function res = i_save_ui(I, flags, filename)
if ~ischar(flags), flags = ''; end
res = i_save(I, [flags 'u'], filename);
return

function res = i_save(I, flags, filename)
% data field is treated as flags
if isempty(flags) | ischar(flags), flags == ' '; end
res = 0;
if isempty(filename), filename = I.file_name; end
if i_need_save(I) | any(flags == 'f') % force flag
  % prompt for filename if UI
  if any(flags == 'u')
    prompt = ['Filename to save ' I.title]; 
    [f p] = uiputfile(filename, prompt);
    if all(f==0), return, end
    filename = fullfile(p, f);
  end
  savestruct(filename, I.data);
  if I.verbose
    fprintf('%s saved to %s\n', I.title, filename);
  end
  I.has_changed = 0;
  res = 1;
end
i_dump(I);
return

function res = i_need_save(I)
res = ~i_isempty(I) & I.has_changed & I.can_change & I.save_if_changed;
return

function value = i_dump(I)
global MARS
MARS.ARMOIRE = setfield(MARS.ARMOIRE, I.name, I); 
return

  