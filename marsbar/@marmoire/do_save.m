function [res, o] = do_save(o, item, flags, filename)
% method  to save data for item
% FORMAT [res, o] = do_save(o, item, flags, filename)
% 
% o        - object
% item     - item name
% flags    - flags for save (see save_item_data.m for details)
% filename - (maybe) filename for save
% 
% Returns
% saved_f  - flag set to 1 if save done, 0 not done, -1 if cancel
% o        - possibly modified object 
%
% The function is written like this so that, in the future, we can use
% callbacks in this code to manipulate all the objects in the armoire
% 
% $Id$
  
if nargin < 2
  error('Need item');
end
if nargin < 3
  flags = NaN;
end
if nargin < 4
  filename = NaN;
end

% Get item
item_struct = get_item_struct(o, item);

% process flags
if ~isstruct(flags), flags = []; end
if pr_is_nix(filename), filename = item_struct.file_name; end
if pr_is_nix(filename), filename = item_struct.default_file_name; end

if pr_needs_save(item_struct) || isfield(flags, 'force') % force flag
  % prompt for filename if UI
  if isfield(flags, 'ui')
    % warn if empty, and warn_empty flag (we must be forcing to get here)
    if pr_isempty(item_struct)
      if isfield(flags, 'warn_empty')
	msgbox('Nothing to save', ...
	       [item_struct.title ' is not set'], 'warn');
      end
      res = 0;
      return
    end
    % Work out prompt
    if isfield(flags, 'prompt')
      prompt = flags.prompt;
    else 
      prompt = item_struct.title;
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
	  o  = set_item_param(o, item, 'has_changed', 0);
	end
	res = 0; 
	return
      end
    end
    pr = ['Filename to save ' prompt]; 
    [f p] = mars_uifile('put', item_struct.filter_spec, pr, filename);
    if all(f==0), res = -1; return, end
    filename = fullfile(p, f);
  end
  savestruct(item_struct.data, filename);
  if item_struct.verbose
    fprintf('%s saved to %s\n', item_struct.title, filename);
  end
  item_struct.file_name = filename;
  item_struct.has_changed = 0;
  if item_struct.leave_as_file
    % maintain only on file, as it has beed saved
    item_struct.data = [];
  end
  o  = set_item_struct(o, item, item_struct);
  res = 1;
else
  res = 0;
end
return
