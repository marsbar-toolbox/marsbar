function [J] = pr_spm_diff(varargin)
% matrix differential
% FORMAT [dfdx] = pr_spm_diff(f,x,...,P,n)
% 
% f   - [inline] function f(x,P)
% x   - argument[s]
% P   - parameter[s]
% n   - argument or parameter to differentiate w.r.t.
%
% dfdx - df(x,P)/dx{n}
%___________________________________________________________________________
% @(#)pr_spm_diff.m	2.1 Karl Friston 03/03/03


% create inline object
%---------------------------------------------------------------------------
f     = fcnchk(varargin{1});
x     = varargin(2:(end - 1));
n     = varargin{end};
dx    = 1e-6;

if length(n) == 1

	% dfdx
	%------------------------------------------------------------------
	f0    = feval(f,x{:});
	J     = sparse(length(f0(:)),length(x{n}(:)));
	for i = 1:length(x{n}(:))
		xi         = x;
		xi{n}(i)   = xi{n}(i) + dx;
		dfdx       = (feval(f,xi{:}) - f0)/dx;
		J(:,i)     = sparse(dfdx(:));
	end
else
	% dfdxdx
	%------------------------------------------------------------------
	f0    = pr_spm_diff(f,x{:},n(1));
	J     = cell(1,length(x{n(2)}(:)));
	for i = 1:length(x{n(2)}(:))
		xi          = x;
		xi{n(2)}(i) = xi{n(2)}(i) + dx;
		dfdx        = (pr_spm_diff(f,xi{:},n(1)) - f0)/dx;
		J{i}        = sparse(dfdx);
	end
end
