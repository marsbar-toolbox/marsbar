function o = my_loadroi(fname)
% my_loadroi function - loads ROI from file, sets source field
%
% $Id$

if isa(fname, 'maroi')  % already loaded
  o = fname;
  return
end

o = [];
if iscell(fname), fname = char(fname); end
if size(fname, 1) > 1, error('Can only load one ROI at a time'); end
if isempty(fname), warning('Empty filename'), return, end
fname = deblank(fname);
F = load(fname);
if isfield(F, 'roi') & isa(F.roi, 'maroi')
  o = F.roi;
  o = source(o, fname);
else
  warning(['Loading file ' fname ' did not return an ROI'])'
end
