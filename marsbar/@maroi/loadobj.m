function o = loadobj(o)
% loadobj method - fills fields needed for backwards compatibility
%
% $Id$

% add cvs tag
if ~isfield(o, 'cvs_version')
  o.cvs_version = '';
end
