function [o, others] = mardo_99(params, others)
% class constructor for SPM99 MarsBaR design object
% FORMAT [o, others] = mardo_99(params, others)
% Inputs 
% params  - structure,containing fields, or SPM/MarsBaR design
% others  - structure, containing other fields to define
%
% Outputs
% o       - mardo_99 object (unless disowned)
% others  - any unrecognized fields from params, for processing by
%           children
%
% This object is called from the mardo object contructor
% with a mardo object as input.  mardo_99 checks to see
% if the contained design is an SPM99 design, returns
% the object unchanged if not.  If it is an SPM99
% design, it claims ownership of the passed object.
%
% $Id$
  
myclass = 'mardo_99';
cvs_v   = mars_cvs_version(myclass);

% Default object structure
defstruct = [];

if nargin < 1
  defstruct.cvs_version = cvs_v;
  o = class(defstruct, myclass, mardo);
  others = [];
  return
end
if nargin < 2
  others = [];
end

% Deal with passed objects of this (or child) class
if isa(params, myclass)
  o = params;
  % Check for simple form of call
  if isempty(others), return, end

  % Otherwise, we are being asked to set fields of object
  % (Moot at the moment, as there are no fields specific for this object)
  [p others] = mars_struct('split', others, defstruct);
  return
end
    
% normal call is via mardo constructor
if isa(params, 'mardo')
  % Check to see if this is a suitable design, return if not
  des = des_struct(params);
  if ~my_design(des), o = params; return, end
  uo = params;
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
params.cvs_version = cvs_v;

% set the mardo object
o  = class(params, myclass, uo);

% set filter (to allow sparse->full trick to work for spm_spm.m)
SPM = des_struct(o);
K   = mars_struct('getifthere', SPM, 'xX', 'K');
if iscell(K);
  SPM.xX.K = pr_spm_filter('set', K);
  o = des_struct(o, SPM);
end

return