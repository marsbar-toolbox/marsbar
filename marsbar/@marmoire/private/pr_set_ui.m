function res = pr_set_ui(I)
% private function to set item data via GUI
% 
% $Id$ 

if nargin < 1
  error('Need item');
end

[fn pn] = mars_uifile('get', I.filter_spec, ['Select ' I.title '...']);
if isequal(fn,0) | isequal(pn,0), res = []; return, end
res = pr_set(I, 'set_ui', [], fullfile(pn, fn));
return
