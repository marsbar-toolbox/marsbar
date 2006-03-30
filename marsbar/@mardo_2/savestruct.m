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

% Convert vols to native format
obj = convert_vols(obj, native_vol_ver(obj));

% unobjectify marsy object before save
SPM = des_struct(obj);
if isfield(SPM, 'marsY')
  SPM.marsY = y_struct(SPM.marsY);
end

save(filename,'SPM');
return