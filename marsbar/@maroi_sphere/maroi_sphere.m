function [o, others] = maroi_sphere(params)
% maroi_sphere - class constructor
% inputs [defaults]
%  params  - a structure containing any fields for a maroi parent and
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
pparams = maroi('fillmerge', defstruct, params);

% umbrella object, parse out fields for (this object and children)
[uo, pparams] = maroi_shape(pparams);

% reparse parameters into those for this object, children
[pparams, others] = maroi('split', pparams, defstruct);

% check resulting input
if size(pparams.centre, 2) == 1
  pparams.centre = pparams.centre';
end

o = class(pparams, myclass, uo);
return