function tf = eq(Y1, Y2)
% method overrides == operator
% 
% $Id$
  
tf = 0;
if ~isa(Y1, 'marsy') | ~isa(Y2, 'marsy'), return, end
if ~all(summary_size(Y1) == summary_size(Y2)), return, end
if is_summarized(Y1) ~= is_summarized(Y2), return, end
if is_summarized(Y1)
  y1 = summary_data(Y1);
  y2 = summary_data(Y2);
else
  y1 = region_data(Y1);
  y1 = [y1{:}];
  y2 = region_data(Y2);
  y2 = [y2{:}];
end
tf = all(all(y1 == y2));

  