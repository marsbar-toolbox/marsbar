function [saved_f, o] = save_item_data(o, item, flags, filename)
% save data for item to file
% FORMAT [saved_f o] = save_item_data(o, item, flags, filename)
%
% o        - object
% item     - name of item
% flags    - flags for save; fields in flag structure can be
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
% filename - filename for save
% 
% Returns
% saved_f  - flag set to 1 if save done, 0 not done, -1 if cancel
%            Note that, if saving with more than one item, then the value
%            is from the last value saved/not saved.  Cancel aborts the
%            attempt to save.
% o        - possibly modified object (changed filename, maybe data is
%            left as a file, and data field made empty) 
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

if ~isstruct(flags), flags = []; end

if strcmp(item, 'all')
  item_list = fieldnames(o.items);
  if ~pr_is_nix(filename)
    warning('Ignoring passed filename for multiple save');
    filename = NaN;
  end
else 
  item_list = {item};
end

n_items = length(item_list);
saved_f = 0;
for i_no = 1:n_items
  item = item_list{i_no};
  I = get_item_struct(o, item);
  tmp_flags = flags;
  
  % If there is no valid filename, do UI save
  if pr_is_nix(filename) && ...
	isempty(I.file_name)
    tmp_flags.ui = 1;
  end
  
  % Try save
  [saved_f o] = do_save(o, item, tmp_flags, filename);
  
  % Stop if cancel
  if saved_f == -1, return, end
end
