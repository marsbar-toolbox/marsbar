function savestruct(obj, filename)
% saves data in def_struct as variables in .mat file
% FORMAT savestruct(object, matname)  
%
% $Id$
  
if nargin ~= 2
  error('Need matfile name');
end
savestruct(des_struct(obj), filename)
return