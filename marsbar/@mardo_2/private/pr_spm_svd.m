function [U,S,V] = spm_svd(X,U)
% computationally efficient SVD (that can handle sparse arguments)
% FORMAT [U,S,V] = spm_svd(X,u);
% X    - {m x n} matrix
% u    - threshold for normalized eigenvalues (default = 1e-6)
%
% U    - {m x p} singular vectors
% V    - {m x p} singular variates
% S    - {p x p} singular values
%___________________________________________________________________________
% @(#)spm_svd.m	2.2 Karl Friston 00/10/10


% default threshold
%---------------------------------------------------------------------------
if nargin < 2
	U = 1e-6;
end

% deal with sparse matrices
%---------------------------------------------------------------------------
[M N] = size(X);
p     = find(any(X,2));
q     = find(any(X,1));
X     = X(p,q);

% SVD
%---------------------------------------------------------------------------
[i j s] = find(X);
[m n]   = size(X);
if any(i - j)

	% off-leading diagonal elements - full SVD
	%-------------------------------------------------------------------
	X     = full(X);
	if m > n

		[v S v] = svd(spm_atranspa(X),0);
		S       = sparse(S);
		s       = diag(S);
		s       = s*length(s)/sum(s);
		j       = find(s >= U);
		v       = v(:,j);
		u       = spm_en(X*v);
		S       = sqrt(S(j,j));

	elseif m < n

		[u S u] = svd(spm_atranspa(X'),0);
		S       = sparse(S);
		s       = diag(S);
		s       = s*length(s)/sum(s);
		j       = find(s >= U);
		u       = u(:,j);
		v       = spm_en(X'*u);
		S       = sqrt(S(j,j));

	else

		[u S v] = svd(X,0);
		S       = sparse(S);
		s       = diag(S).^2;
		s       = s*length(s)/sum(s);
		j       = find(s >= U);
		v       = v(:,j);
		u       = u(:,j);
		S       = S(j,j);
	end

else
	S     = sparse(1:n,1:n,s,m,n);
	u     = speye(m,n);
	v     = speye(m,n);
	[i j] = sort(-s);
	S     = S(j,j);
	v     = v(:,j);
	u     = u(:,j);

	s     = diag(S).^2;
	s     = s*length(s)/sum(s);
	j     = find(s >= U);
	v     = v(:,j);
	u     = u(:,j);
	S     = S(j,j);

end

% replace in full matrices
%---------------------------------------------------------------------------
j      = length(j);
U      = sparse(M,j);
V      = sparse(N,j);
U(p,:) = u;
V(q,:) = v;
