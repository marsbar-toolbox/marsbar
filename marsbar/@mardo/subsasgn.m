function result = subsasgn(this, Struct, rhs)
% method to over load . notation in assignments.
% . assignment for mardo objects default to the contents of des_struct
%
% $Id$

result = builtin('subsasgn', des_struct(this), Struct, rhs);