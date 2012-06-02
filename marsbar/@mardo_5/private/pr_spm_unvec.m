function [varargout] = pr_spm_unvec(vX,varargin)
% unvectorises a vectorised array
% FORMAT [X] = pr_spm_unvec(vX,X);
% X  - numeric, cell or stucture array
% vX - pr_spm_vec(X)
%
% i.e. X      = pr_spm_unvec(pr_spm_vec(X),X)
%      [X{:}] = pr_spm_unvec(pr_spm_vec(X{:}),X{:})
%                                              - (i.e. can also deal)
%
% see pr_spm_vec
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_vec.m 184 2005-05-31 13:23:32Z karl $

% deal to multiple outputs if necessary
%--------------------------------------------------------------------------
if nargout > 1
    varargout = pr_spm_unvec(vX,varargin);
    return
end
if length(varargin) == 1
    X = varargin{1};
else
    X = varargin;
end

% fill in structure arrays
%--------------------------------------------------------------------------
if isstruct(X)
    f = fieldnames(X);
    for i = 1:length(f)
        c          = {X.(f{i})};
        n          = length(pr_spm_vec(c));
        c          = pr_spm_unvec(vX(1:n),c);
        [X.(f{i})] = deal(c{:});
        vX         = vX(n + 1:end);
    end
    varargout      = {X};
    return
end

% fill in cells arrays
%--------------------------------------------------------------------------
if iscell(X)
    for i = 1:length(X(:))
        n     = length(pr_spm_vec(X{i}));
        X{i}  = pr_spm_unvec(vX(1:n),X{i});
        vX    = vX(n + 1:end);
    end
    varargout      = {X};
    return
end

% reshape numerical arrays
%--------------------------------------------------------------------------
if isnumeric(X)
    X(:)  = vX;
else
    X     = [];
end
varargout = {X};
