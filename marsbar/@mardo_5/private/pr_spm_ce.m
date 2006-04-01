function [C] = pr_spm_ce(v,a)
% return error covariance constraints for serially correlated data
% FORMAT [C] = pr_spm_ce(v,a)
% v  - (1 x l) v(i) = number of observations for ith block
% a  - AR coefficient expansion point  (default a = [])
% 
%  C{1} = h(1)*AR(a)
%  C{2} = h(1)*AR(a) + h(2)*dAR(a)/da(1);
%  C{3} = h(1)*AR(a) + h(2)*dAR(a)/da(1) + h(3)*dAR(a)/da(2);
%
% See also: spm_Q.m
%___________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_Ce.m 190 2005-06-20 07:04:35Z klaas $



% defaults
%---------------------------------------------------------------------------
if nargin == 1
	a = [];
end


% create blocks
%---------------------------------------------------------------------------
C    = {};
l    = length(v);
n    = sum(v);
k    = 0;
if l > 1
	for i = 1:l
		dCda  = pr_spm_ce(v(i),a);
		for j = 1:length(dCda)
			[x y q]    = find(dCda{j});
			x          = x    + k;
			y          = y    + k;
			C{end + 1} = sparse(x,y,q,n,n);
		end
		k          = v(i) + k;
	end
else
	% dCda
	%==================================================================
	C{1}  = pr_spm_q(a,v);
	dCda  = pr_spm_diff('pr_spm_q',a,v,1);
	for i = 1:length(a)
            try
		C{i + 1} = dCda{i};
            catch
                C{i + 1} = dCda;
            end
	end

end
