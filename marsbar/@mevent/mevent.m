function [o, others] = mevent(params, varargin)
% marmoire - class constructor for mevent container type
% FORMAT [o, others] = mevent(params, varargin)
%  
% $Id$
  
myclass = 'mevent';
defstruct = struct('event_types', []);

if nargin < 1
  params = [];
end
if isa(params, myclass)
  o = params;
  return
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = mars_struct('ffillsplit', defstruct, params);

% add cvs tag
pparams.cvs_version = mars_cvs_version(myclass);

% Set as object
o  = class(pparams, myclass);
