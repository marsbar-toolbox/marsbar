function roifname = my_roifname(fname)
% changes fname to appropriate ROI format
%
% $Id$

if nargin < 1
  fname = [];
end
roifname = fname;
if isempty(fname)
  return
end
gend = maroi('classdata', 'fileend');
lg = length(gend);

[p f e] = fileparts(roifname);
f2 = [f e];
if length(f2)<lg | ~strcmp(gend, [f2(end - lg +1 : end)])
  roifname = fullfile(p, [f gend]);
end
% make absolute path
roifname = spm_get('cpath', roifname);