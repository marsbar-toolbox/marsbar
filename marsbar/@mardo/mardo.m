function [o, others] = mardo(params)
% mardo - class constructor for MarsBaR design object
% inputs [defaults]
% params  - structure, containing SPM/MarsBaR design
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

% check inputs
if ~isstruct(params)
  error('Need structure as input to constructor function');
end
if ~isfield(params, 'des_struct')
  % Appears to be an SPM design
  params.des_struct = params;
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = mars_struct('fillsplit', defstruct, params);

% set the mardo object
o  = class(pparams, myclass);

% offer as food to children
o = mardo_99(o, others);
o = mardo_2(o, others);

return