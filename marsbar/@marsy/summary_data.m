function [Y Yvar o] = summary_data(o, sumfunc)
% method to get summary data, maybe set sumfunc
% 
% $Id$
  
if nargin > 1
  o = sumfunc(o, sumfunc);
end

st = o.y_struct;
if ~isfield(st, 'Y')
  Ys = region_data(o);
  if isempty(Ys)
    error('No region data to summarize');
  end
  Y = 
  [st.Y st.Yvar] = pr_sum_func(