function result = subsasgn(this, Struct, rhs)
% method to overload . notation in assignments.
% . assignment for mardo objects acts on the contents of des_struct
%
% $Id$

SPM = des_struct(this);
SPM = builtin('subsasgn', SPM, Struct, rhs);
result = des_struct(this, SPM);