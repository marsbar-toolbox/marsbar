function bf = pr_spm_orth(BF)
% recursive orthogonalization of basis functions
% FORMAT bf = pr_spm_orth(bf)
%
% From spm_get_bf.m, see that file for credits
% 
% $Id$ 

if nargin < 1
  error('Need BF');
end

bf    = BF(:,1);
bf    = bf/sqrt(mean(bf.^2));
for i = 2:size(BF,2)
  D     = BF(:,i);
  D     = D - bf*(pinv(bf)*D);
  if any(D)
    bf = [bf D/sqrt(mean(D.^2))];
  end
end


