function V = get_vol_field(D, fieldn)
% method to get named field, containing or referring to vol structs
% FORMAT V = get_vol_field(D, fieldn)
% 
% D        - design object
% fieldn   - field name
% 
% Returns
% V        - vol struct
%
% e.g Vbeta = get_vol_field(D, 'Vbeta');
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
if ~isfield(SPM, fieldn)
  error([ fieldn ' is not a field in design']);
end
V = getfield(SPM, fieldn);
V = full_vol(D, V);
