function [o, others] = maroi_shape(params)
% maroi_shape - (virtual) shape roi class constructor
% inputs [defaults]
%  params  - a structure containing any fields for a maroi parent
% 
% Only used by inheriting objects
%
% $Id$

myclass = 'maroi_shape';
defstruct = struct('shape', []);

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
[uo, pparams] = maroi(pparams);

% reparse parameters into those for this object, children
[pparams, others] = maroi('split', pparams, defstruct);

o = class(pparams, myclass, uo);

return