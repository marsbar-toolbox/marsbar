function str = modality(o)
% returns guessed modality of design, 'FMRI' or 'PET'
str = 'PET';
if isfield(o, 'Sess')
  str = 'FMRI';
end
