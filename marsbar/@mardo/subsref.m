function result = subsref(this, Struct)
% method to overload the . notation.
% . reference for mardo objects returns contents of des_struct
%
% $Id$

result = builtin('subsref', des_struct(this), Struct );