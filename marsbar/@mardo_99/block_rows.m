function rows = block_rows(D)
% returns cell array of rows for each (subject/session) block
%
% $Id$
  
SPM = des_struct(D);
if strcmp(modality(D), 'fmri')
  Sess = SPM.Sess;
  for i = 1:length(Sess)
    rows{i} = Sess{i}.row;
  end
else % PET I guess
  xX = SPM.xX;
  if ~isfield(xX, 'I')
    error('Expecting I field in SPM design');
  end
  scol = xX.I(:, 3); % the subject column
  subjnos = unique(scol);
  for s = 1:length(subjnos);
    rows{s} = find(scol == subjnos(s));
  end
end
