function o = maroi_box(params)
% maroi_box - class constructor
% inputs [defaults]
%  params  - a structure containing any fields for a maroi parent and
%            .centre - a 1x3 coordinate in mm 
%            .widths - 1x3 widths in X Y Z in mm
%
% $Id$

myclass = 'maroi_box';
defstruct = struct('centre', [0 0 0], 'widths', [0 0 0]);

if nargin < 1
  params = [];
end
if isa(params, myclass)
  o = params;
  return
end

% fill with defaults
pparams = mars_struct('ffillmerge', defstruct, params);

% umbrella object, parse out fields for (this object and children)
[uo, pparams] = maroi_shape(pparams);

% reparse parameters into those for this object, children
[pparams, others] = mars_struct('split', pparams, defstruct);

% check resulting input
if size(pparams.centre, 2) == 1
  pparams.centre = pparams.centre';
end
if size(pparams.widths, 2) == 1
  pparams.widths = pparams.widths';
end
if size(pparams.widths, 2) == 1
  pparams.widths = ones(1,3) * pparams.widths;
end

o = class(pparams, myclass, uo);
return