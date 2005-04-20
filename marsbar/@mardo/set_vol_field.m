function D = set_vol_field(D, fieldn, imgs)
% method to set named field, containing or referring to vol structs
% FORMAT D = get_vol_field(D, fieldn, imgs)
% 
% D        - design object
% fieldn   - field name
% imgs     - image names or vol structs
%  
% Returns
% D        - changed object
%
% e.g D = get_vol_field(D, 'Vbeta', Vbeta);
% 
% We need to deal with the fact that vol fields can be char or vol_structs.
% SPM99, for good reason, stored the design structs from the results of the
% estimation as file names, which then had to be remapped with spm_vol to
% get the vol structs.  The good reason was that this avoided
% byte-swapping problems if the design was copied to another system.
% 
% $Id$

if nargin < 2
  error('Need field name');
end

SPM = des_struct(D);

V = design_vol(D, imgs);

SPM = setfield(SPM, fieldn, V);
D = des_struct(D, SPM);