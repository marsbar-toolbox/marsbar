function savestruct(obj, filename)
% saves data in y_struct as variables in .mat file
% FORMAT savestruct(object, matname)  
%
% $Id$
  
if nargin ~= 2
  error('Need matfile name');
end
savestruct(y_struct(obj), filename)
return