function D = set_contrasts(D, C)
% method to set contrasts into design object
% 
% $Id$
  
SPM = des_struct(D);
C = SPM.xCon;
D = des_struct(D, SPM);