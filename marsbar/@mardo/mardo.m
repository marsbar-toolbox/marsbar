function [o, others] = mardo(params, params2)
% mardo - class constructor for MarsBaR design object
% inputs [defaults]
% params  - structure, containing SPM/MarsBaR design
% params2 - structure with other fields for mardo object
%
% $Id$
  
myclass = 'mardo';
defstruct = struct('des_struct', [], 'verbose', 1);

if nargin < 1
  params = [];
end
if isa(params, myclass)
  o = params;
  return
end
if nargin < 2
  params1 = defstruct;
end
params1.des_struct = params;

% check inputs
if ~isstruct(params1) 
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = my_fillsplit(defstruct, params1);

% identify type of design, send to correct object
o  = class(pparams, myclass);

return