function res = pr_isempty(I)
% private function returns 1 if there is no data, or filename
% 
% $Id$
  
res = isempty(I.data) & isempty(I.file_name);
