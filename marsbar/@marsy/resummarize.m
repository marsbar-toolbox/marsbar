function o = resummarize(o)
% recalculate summary data if possible
% 
% $Id$
  
if ~isempty(sumfunc(o))
  [t1 t2 o] = summary_data(o);
end