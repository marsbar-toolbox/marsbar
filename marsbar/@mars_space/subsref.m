function result = subsref(this, Struct)
% method to overload the . notation.
%   Publicize subscripted reference to private fields of object.
%
% $Id$

result = builtin('subsref', this, Struct );