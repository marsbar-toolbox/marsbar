function result = subsasgn(this, Struct, rhs)
% method to over load . notation in assignments.
%   Publicize subscripted assignments to private fields of object.
%
% $Id$

result = builtin('subsasgn', this, Struct, rhs );