function [o, others] = mardo_99(params, others)
% mardo_2 - class constructor for SPM99 MarsBaR design object
% inputs [defaults]
% params  - structure,containing fields, or SPM/MarsBaR design
% others  - structure, containing other fields to define
%
% This object is called from the mardo object contructor
% with a mardo object as input.  mardo_99 checks to see
% if the contained design is an SPM99 design, returns
% the object unchanged if not.  If it is an SPM99
% design, it claims ownership of the passed object.
%
% $Id$
  
myclass = 'mardo_99';
defstruct = struct([]);

if nargin < 1
  params = [];
end
if nargin < 2
  others = struct([]);
end

if isa(params, myclass)
  o = params;
  return
end

% normal call is via mardo constructor
if isa(params, 'mardo')
  % Check to see if this is a suitable design, return if not
  des = des_struct(params);
  if ~my_design(des), o = params; return, end
  uo = params;
  params = struct([]);
else
  uo = [];
end

% fill with other parameters, defaults
params = mars_struct('ffillmerge', params, others);
params = mars_struct('ffillmerge', defstruct, params);

if ~isa(uo, 'mardo') % mardo object not passed
  % umbrella object, parse out fields for (this object and children)
  % second argument of 0 prevents recursive call back to here
  [uo, params] = mardo(params, 0);
end

% reparse parameters into those for this object, children
[params, others] = mars_struct('split', params, defstruct);

% set the mardo object
o  = class(params, myclass, uo);

return