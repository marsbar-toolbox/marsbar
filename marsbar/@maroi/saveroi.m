function roi = saveroi(roi, fname)
% saveroi method - checks fname, sets source field, saves object
%
% $Id$

if nargin < 2
  fname = source(roi);
end
if isempty(fname)
  error('Need filename for save');
end
roi.source = fname;
save(roi.source, 'roi');