function result = subsasgn(this, Struct, rhs)
% method to over load . notation in assignments.
% . assignment for mardo objects default to the contents of des_struct
%
% $Id$

SPM = des_struct(this);
SPM = builtin('subsasgn', SPM, Struct, rhs);
result = des_struct(this, SPM);