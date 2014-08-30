function res = pr_is_nan(v)
res = 0;
if isnumeric(v) && ~isempty(v)
  res = isnan(v);
end
return
