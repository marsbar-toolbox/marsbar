function save_mricro(o, fname, sp)
% saves in MRIcro format
%
% $Id$

if nargin < 2
  error('Need filename for MRIcro save');
end
if nargin < 3
  sp = native_space(o);
end
rlem = rle(o, sp);
fid = fopen(fname, 'wb');
if fid == -1
  error(['Could not open file ' fname]);
end
fclose(fid);
error('Come to think of it, I don''t understand the format anyhow');