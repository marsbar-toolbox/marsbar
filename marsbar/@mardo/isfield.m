function result = isfield(this, fieldn)
% method to overload isfield 
% isfield for  mardo objects default to the contents of des_struct
%
% $Id$

result =isfield(this.des_struct, fieldn);