function savestruct(obj, filename)
% saves data in def_struct as variables in .mat file
% FORMAT savestruct(object, matname)  
%
% $Id$
  
if nargin ~= 2
  error('Need matfile name');
end

% unobjectify marsy object before save
SPM = des_struct(obj);
if isfield(SPM, 'marsY')
  SPM.marsY = y_struct(SPM.marsY);
end
savestruct(SPM, filename)

return