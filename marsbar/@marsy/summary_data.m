function [Y,Yvar,o] = summary_data(o, sumfunc_str)
% method to get summary data, maybe set sumfunc
% 
% $Id$
  
if nargin > 1
  o = sumfunc(o, sumfunc_str);
end
s_f = sumfunc(o);
if isempty(s_f)
  error('No summary function specified');
end

% refresh summary data if necessary
% (if sumfunc passed, if data is available)
st = y_struct(o);

if nargin > 1 | ...              % sumfunc passed
      ~isfield(st, 'Y') | ...    % Y not yet calculated
      (nargout > 2 & ~isfield(st, 'Yvar')) % Yvar needed
  if strcmp(s_f, 'unknown')
    error('Cannot recalculate from unknown sumfunc');
  end
  Ys = region_data(o);
  if isempty(Ys)
    error('No region data to summarize');
  end
  Ws = region_weights(o);
  sz = summary_size(o);
  Y = zeros(sz);
  Yvar = zeros(sz);
  for i = 1:sz(2);
    if isempty(Ys{i}) % set to NaN if no data to summarize
      Y(:,i) = NaN;
      Yvar(:,i) = NaN;
    else      
      [Y(:,i) Yvar(:,i)] = pr_sum_func(Ys{i}, s_f, Ws{i});
    end
  end
  if verbose(o)
    fprintf(['Summarizing data with summary function: %s\n', s_f);
  end
  if nargout > 2
    st.Y = Y;
    st.Yvar = Yvar;
    o = y_struct(o, st);
  end
else % not recalculated
  Y = st.Y;
  if nargout > 1
    Yvar = st.Yvar;
  end
end


