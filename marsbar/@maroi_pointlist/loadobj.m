function o = loadobj(o)
% loadobj method - creates temporary voxel block
%
% $Id$

o.voxblock = my_voxblock(o.XYZ, o.mat, o.vals);