function r = block_rows(Y, rows)
% gets/sets cell array of rows for each (subject/session) block
%
% $Id$

ys = y_struct(Y);
n  = n_time_points(Y);
if nargin < 2  % get
  if ~isfield(ys, 'block_rows')
    r = {[1:n]'};
  else
    r = ys.block_rows;
  end
else           % set
  if ~iscell(rows)
    error('Need cell array of matrices for blocks');
  end
  for i = 1:prod(size(rows))
    rows{i} = rows{i}(:);
    if any(rows{i} < 1 | rows{i} > n)
      error(sprintf('Row %d: values out of range', i));
    end
  end
  ys.block_rows = rows;
  r = y_struct(Y, ys);
end