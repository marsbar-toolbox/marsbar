function savestruct(obj, filename)
% saves data in def_struct into .mat file with variable name SPM
% FORMAT savestruct(object, matname)  
%
% $Id$
  
if nargin ~= 2
  error('Need matfile name');
end

% allow args to be in reverse order
if ischar(obj)
  tmp = obj;
  obj = filename;
  filename = tmp;
end

SPM = des_struct(obj);
save(filename,'SPM');
return