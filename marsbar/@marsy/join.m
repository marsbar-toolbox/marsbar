function o = join(varargin)
% joins marsy objects into one object
% 
% $Id$

% assemble all input object into a cell array
% (deals with arrays of objects)
o_c_a = {};
ctr = 0;
for v = 1:nargin
  o_arr = varargin{v};
  for i = 1:prod(size(o_arr))
    ctr = ctr + 1;
    o_c_a{ctr} = o_arr(i);
  end
end

o = o_c_a{1};
st_o = y_struct(o);
sum_f = is_summarized(o);
for i = 2:ctr
  o_a = o_c_a{i};
  st = y_struct(o_a);
  if sum_f
    [Y Yvar] = summary_data(o_a);
    st_o.Y = [st_o.Y Y];
    st_o.Yvar = [st_o.Yvar Yvar];
  end
  
end