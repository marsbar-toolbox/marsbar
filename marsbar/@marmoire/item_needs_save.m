function tf = item_needs_save(o, item)
% return 1 if item requires a save
% FORMAT tf = item_needs_save(o, item)
% 
% $Id$ 
  
if nargin < 2
  error('Need item')
end
tf = pr_needs_save(get_item_struct(o, item));