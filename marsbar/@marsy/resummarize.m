function o = resummarize(o)
% recalculate summary data if possible
% 
% $Id$

s_f = sumfunc(o);  
if ~isempty(s_f) & ~strcmp(s_f, 'unknown')
  [t1 t2 o] = summary_data(o, s_f);
end