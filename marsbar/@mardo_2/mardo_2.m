function [o, others] = mardo_2(params, others)
% class constructor for SPM2 MarsBaR design object
% FORMAT [o, others] = mardo_2(params, others)
% Inputs
% params  - structure,containing fields, or SPM/MarsBaR design
% others  - structure, containing other fields to define
%
% Outputs
% o       - mardo_2 object (unless disowned)
% others  - any unrecognized fields from params, for processing by
%           children
%
% This object is called from the mardo object contructor
% with a mardo object as input.  mardo_2 checks to see
% if the contained design is an SPM2 design, returns
% the object unchanged if not.  If it is an SPM2
% design, it claims ownership of the passed object.
%
% $Id$
  
myclass = 'mardo_2';
defstruct = [];

if nargin < 1
  params = [];
end
if nargin < 2
  others = [];
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
  % own
  if isfield(des, 'SPM')
    des = des.SPM;
  end
  uo = des_struct(params, des);
  params = [];
else
  uo = [];
end

if ~isa(uo, 'mardo') % mardo object not passed
  % umbrella object, parse out fields for (this object and children)
  % third argument of 0 prevents recursive call back to here
  [uo, params] = mardo(params, others, 0);
else
  % fill params with other parameters
  params = mars_struct('ffillmerge', params, others);
end  

% parse parameters into those for this object, children
[params, others] = mars_struct('ffillsplit', defstruct, params);

% add cvs tag
params.cvs_version = mars_cvs_version(myclass);

% set the mardo object
o  = class(params, myclass, uo);

return