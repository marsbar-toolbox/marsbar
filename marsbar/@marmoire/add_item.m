function o = add_item(o, item_name, item_contents)
% add item to armoire
% FORMAT o = add_item(o, item, I)
% 
% o              - object
% item_name     - item name
% item_contents = item ... contents
%
% $Id $
  
if nargin < 2
  error('Need item name to add');
end
if nargin < 3
  item_contents = [];
end
I = default_item(o);
if isempty(item_contents)
  item_contents = I;
else
  def_fns = fieldnames(I);
  new_fns = def_fns(~ismember(def_fns, fieldnames(item_contents)));
  for fn = new_fns'
    item_contents = setfield(item_contents, fn{1}, getfield(I, fn{1}));
  end
end
o = set_item_struct(o, item_name, item_contents);
