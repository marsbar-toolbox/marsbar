function tf = can_summarize(o)
% returns 1 if object contains enough information to be summarized
% or is already summarized
% 
% $Id$
  
tf = 1;
if is_summarized(o), return, end 
for i = 1:n_regions(o);
  r_samp = region_size(o, i, 2);
  if r_samp > 1 % at least one region needs summarizing
    % check for summary function
    s = sumfunc(o);
    tf = ~isempty(s) & ~strcmp(s, 'unknown');
    break
  end
end
