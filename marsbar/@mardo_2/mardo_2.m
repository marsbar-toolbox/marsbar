function [o, others] = mardo_2(params, others)
% mardo_2 - class constructor for SPM2 MarsBaR design object
% inputs [defaults]
% params  - structure, containing SPM/MarsBaR design
%
% $Id$
  
myclass = 'mardo_2';

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

if isa(params, 'mardo')
  % check if this is our kind of thing
end

% fill with defaults
pparams = mars_struct('fillmerge', defstruct, params);

% split required fields from others
[pparams, others] = mars_struct('fillsplit', defstruct, params);

% set the mardo object
o  = class(pparams, myclass);

% offer as food to children
o = mardo_99(o);
o = mardo_2(o);

return