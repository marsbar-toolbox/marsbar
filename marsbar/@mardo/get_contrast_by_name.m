function [C, Ic] = get_contrast_by_name(D, con_name)
% get named contrast from design object
% FORMAT [C, Ic] = get_named_con(D, con_name)
%
% D        - mardo design object
% con_name - contrast name
%
% Returns
% C        - xCon structure containing only named contrast
% Ic       - index of found contrast, within design
%
% $Id$

if nargin < 2
  error('Need contrast name');
end
Ic = [];
C = get_contrasts(D);
if isempty(C), return, end

c_len = length(C);
[c_ns{1:c_len}] = deal(C.name);
Ic = strmatch(con_name, c_ns, 'exact');
C = C(Ic);
