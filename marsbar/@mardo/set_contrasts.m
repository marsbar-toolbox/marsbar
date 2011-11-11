function D = set_contrasts(D, C, refreshf)
% method to set contrasts into design object
%
% D     - design
% C     - contrasts
%           C can be a contrast structure, or a structure containing
%           a contrast structure
% refreshf - if 1 then refresh contrasts with respect to design matrix
%            structures in `D`. Default is 1
%
% Returns
% D     - design with contrasts set to C
%
% $Id$

if nargin < 2
  error('Need contrasts');
end
if nargin < 3
    refreshf = 1;
end
if isfield(C, 'xCon');
  C = C.xCon;
end
SPM = des_struct(D);
if refreshf
    % Use add contrasts routine to refresh contrasts
    SPM.xCon = [];
    D = des_struct(D, SPM);
    D = add_contrasts(D, C);
else % Hope for the best
    SPM.xCon = C;
    D = des_struct(D, SPM);
end
