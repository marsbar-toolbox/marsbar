function x = pr_spm_orth(X)
% recursive orthogonalization of basis functions
% FORMAT x = pr_spm_orth(X)
%
% serial orthogionalization starting with the first column
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_orth.m 112 2005-05-04 18:20:52Z john $


x     = X(:,1);
for i = 2:size(X,2)
        D     = X(:,i);
        D     = D - x*(pinv(x)*D);
        if any(D)
                x = [x D];
        end
end

