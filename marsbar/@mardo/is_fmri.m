function tf = is_fmri(D)
% method returns 1 if this is an fmri design
% 
% $Id$
  
tf = strcmp(modality(D), 'fmri');