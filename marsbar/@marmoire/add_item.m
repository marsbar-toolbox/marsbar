function o = add(o, data, filename)
% add item to armoire
% 
% $Id $
  
if nargin < 2
  error('Need data to add');
end
if nargin < 3
  filename = NaN;
end

data.name = item;
I = default_item(o);
def_fns = fieldnames(I);
new_fns = def_fns(~ismember(def_fns, fieldnames(data)));
for fn = new_fns'
  data = setfield(data, fn{1}, getfield(I, fn{1}));
end
o.items = setfield(o.items, I.name, I);
