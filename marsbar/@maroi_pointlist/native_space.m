function sp = native_space(obj)
% native_space method - returns native space of object
%
% $Id$

sp = mars_space(size(obj.voxblock.dat), obj.voxblock.mat);