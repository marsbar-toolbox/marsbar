function [saved_f o] = save_item_data_ui(o, item, flags, filename)
% save data for item to file using GUI
% FORMAT [saved_f o] = save_item_data_ui(o, item, flags, filename)
%
% o        - object
% item     - name of item
% flags    - flags for save; see save_item_data.m for details
% filename - filename for save
% 
% Returns
% saved_f  - flag set to 1 if save done
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

if strcmp(item, 'all')
  item_list = fieldnames(o.items);
else 
  item_list = {item};
end

n_items = length(item_list);
saved_f = zeros(n_items, 1);
for i_no = 1:n_items
  item = item_list{i_no};
  I = get_item_struct(o, item);
  [saved_f(i_no) I] = pr_save_ui(I, flags, filename);
  if saved_f(i_no) == -1 % cancel in GUI save
    break
  else
    o.items = setfield(o.items, item, I);  
  end
end