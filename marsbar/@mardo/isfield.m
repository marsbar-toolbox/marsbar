function result = isfield(this, fieldn)
% method to overload isfield for mardo objects
% isfield for mardo objects replies according to the contents of
% the des_struct field
%
% $Id$

result =isfield(this.des_struct, fieldn);