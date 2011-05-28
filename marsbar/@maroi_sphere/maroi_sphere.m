function [o, others] = maroi_sphere(params)
% maroi_sphere - class constructor
% FORMAT [o, others] = maroi_sphere(params)
% Inputs [defaults]
% params  - a structure containing any fields for a maroi parent and
%            .centre - a 1x3 coordinate in mm 
%            .radius - a 1x1 radius in mm
%
%
% $Id$

myclass = 'maroi_sphere';
defstruct = struct('centre', [0 0 0],'radius', 0);

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
% enforce radius as double for vox->mm conversions
pparams.radius = double(pparams.radius)

o = class(pparams, myclass, uo);
return
