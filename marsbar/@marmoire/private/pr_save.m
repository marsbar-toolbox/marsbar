function [res, I] = pr_save(I, flags, filename)
% private function to save data for item
% FORMAT [res, I] = pr_save(I, flags, filename)
% 
% I        - whole item (including parameters)
% flags    - flags for save (see save_item_data.m for details)
% filename - (maybe) filename for save
% 
% Returns
% saved_f  - flag is 1 if item was in fact saved
% I        - possibly modified item 
%
% $Id$
  
if nargin < 1
  error('Need item');
end
if nargin < 2
  flags = NaN;
end
if nargin < 3
  filename = NaN;
end
  
% process flags
if ~isstruct(flags), flags = []; end
if pr_is_nix(filename), filename = I.file_name; end
if pr_is_nix(filename), filename = I.default_file_name; end

% if UI, and warn and no data, warn and return
if pr_isempty(I) & isfield(flags, 'ui') & 
  isfield(flags, 'force') & isfield(flags, 'warn_empty')
  msgbox('Nothing to save', [I.title ' is not set'], 'warn');
  res = 0;
  return
end

if pr_needs_save(I) | isfield(flags, 'force') % force flag
  % prompt for filename if UI
  if isfield(flags, 'ui')
    % warn if empty, and warn_empty flag (we must be forcing to get here)
    if pr_isempty(I) & isfield(flags, 'warn_empty')
      msgbox('Nothing to save', [I.title ' is not set'], 'warn');
      res = 0;
      return
    end
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
else
  res = 0;
end
return
