function [Y,Yvar,o] = summary_data(o, sumfunc_str)
% method to get summary data, maybe set sumfunc
% 
% Inputs
% o              - marsy data object
% sumfunc_str    - [optional] summary function string; one of
%                  'mean', 'median', 'eig1', 'wtmean'
%                  If not specified, defaults to previous summary
%                  function for this object
%
% Output
% Y              - (re)calculated summary time course
% Yvar           - [optional] variance time course
% o              - possibly changed marsy data object
%
% e.g. 
% Y = summary_data(o);
% [Y Yvar o] = summary_data(o, 'median');
% 
% $Id$
  
if nargin > 1
  o = sumfunc(o, sumfunc_str);
end
s_f = sumfunc(o);
if isempty(s_f)
  error('No summary function specified');
end

% Get a copy of object structure 
st = y_struct(o);

% refresh summary data if necessary 
% (if sumfunc passed, OR if data is not yet available)
if nargin > 1 | ...              % sumfunc passed
      ~isfield(st, 'Y') | ...    % Y not yet calculated
      (nargout > 2 & ~isfield(st, 'Yvar')) % Yvar needed
  
  % If we only have one (or zero) columns per ROI, job is simple
  Ys      = region_data(o);
  sz      = summary_size(o);
  if isempty(Ys)
    error('No region data to summarize');
  elseif region_size(o, 'all', 2) == sz(2) % One column per ROI
    Y = [Ys{:}];
    Yvar = ones(sz) * Inf;
  else % More than one column per ROI
    if strcmp(s_f, 'unknown')
      error('Cannot recalculate from unknown sumfunc');
    end
    Ws = region_weights(o);
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
      fprintf('Summarizing data with summary function: %s\n', s_f);
    end
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


