function o = my_loadroi(fname)
% my_loadroi function - loads ROI(s) from file, sets source field
%
% $Id$

if isa(fname, 'maroi')  % already loaded
  o = fname;
  return
end
if isempty(fname)
  o = [];
  return
end

if ischar(fname), fname = cellstr(fname);end
for f = 1:length(fname)
  F = load(fname{f});
  if isfield(F, 'roi') & isa(F.roi, 'maroi')
    o(f) = F.roi;
    o(f).source = fname{f};
  end
end