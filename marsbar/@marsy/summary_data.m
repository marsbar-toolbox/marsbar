function [Y Yvar o] = summary_data(o, sumfunc)
% method to get summary data, maybe set sumfunc
% 
% $Id$
  
if nargin > 1
  o = sumfunc(o, sumfunc);
end
if isempty(sumfunc(o))
  error('No summary function specified');
end

% refresh summary data if necessary
% (if sumfunc passed, if data is available)
st = o.y_struct;
if ~isfield(st, 'Y')
  Ys = region_data(o);
  if isempty(Ys)
    error('No region data to summarize');
  end
  
  [st.Y st.Yvar] = pr_sum_func(Ys{i}, o.sumfunc);
end