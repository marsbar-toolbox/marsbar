function D = set_contrasts(D, C)
% method to set contrasts into design object
% 
% D     - design
% C     - contrasts 
%           C can be a contrast structure, or a structure containing
%           a contrast structure 
%
% Returns
% D     - design with contrasts set to C 
% 
% $Id$

if nargin < 2
  error('Need contrasts');
end
if isfield(C, 'xCon');
  C = C.xCon;
end

SPM = des_struct(D);
SPM.xCon = C;
D = des_struct(D, SPM);