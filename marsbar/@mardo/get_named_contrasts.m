function [xc, ic]  = get_named_contrasts(D, cname)
% get named contrast(s) from design contrast structure
% FORMAT [xc, ic] = get_named_contrasts(D, cname)
% 
% D      - design object
% cname  - contrast name(s) (string or cell array)
% 
% Returns
% xc     - xCon structure containing only named contrast
% ic     - index of contrast in design contrast structure
%
% e.g. [con ic] = get_named_contrasts(D, 'effects of interest');
%
% $Id$

if nargin < 2
  error('Need contrast name(s)');
end
if ischar(cname)
  cname = cellstr(cname);
end

xc = get_contrasts(D);  
ic = find(ismember({xc(:).name}, cname));
xc = xc(ic);