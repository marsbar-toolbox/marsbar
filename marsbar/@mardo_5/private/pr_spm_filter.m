function [argout] = pr_spm_filter(K,Y)
% Removes low frequency confounds X0
% FORMAT [Y] = pr_spm_filter(K,Y)
% FORMAT [K] = pr_spm_filter(K)
%
% K           - filter matrix or:
% K(s)        - struct array containing partition-specific specifications
%
% K(s).RT     - observation interval in seconds
% K(s).row    - row of Y constituting block/partition s
% K(s).HParam - cut-off period in seconds
%
% K(s).X0     - low frequencies to be removed (DCT)
% 
% Y           - data matrix
%
% K           - filter structure
% Y           - filtered data
%___________________________________________________________________________
%
% spm_filter implements high-pass filtering in an efficient way by
% using the residual forming matrix of X0 - low frequency confounds
%.spm_filter also configures the filter structure in accord with the 
% specification fields if called with one argument
%___________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Karl Friston
% $Id: spm_filter.m 184 2005-05-31 13:23:32Z john $



% set or apply
%---------------------------------------------------------------------------
if nargin == 1 && isstruct(K)

	% set K.X0
	%-------------------------------------------------------------------
	for s = 1:length(K)

		% make high pass filter
		%-----------------------------------------------------------
		k       = length(K(s).row);
		n       = fix(2*(k*K(s).RT)/K(s).HParam + 1);
		X0      = spm_dctmtx(k,n);
		K(s).X0 = X0(:,2:end);
	end

	% return structure
	%-------------------------------------------------------------------
	argout = K;

else
	% apply
	%-------------------------------------------------------------------
	if isstruct(K)

		% ensure requisite feilds are present
		%-----------------------------------------------------------
		if ~isfield(K(1),'X0')
			K = pr_spm_filter(K);
		end

		for s = 1:length(K)

			% select data
			%---------------------------------------------------
			y = Y(K(s).row,:);

			% apply high pass filter
			%---------------------------------------------------
			y = y - K(s).X0*(K(s).X0'*y);

			% reset filtered data in Y
			%---------------------------------------------------
			Y(K(s).row,:) = y;

		end

	% K is simply a filter matrix
	%-------------------------------------------------------------------
	else
		Y = K*Y;
	end

	% return filtered data
	%-------------------------------------------------------------------
	%if any(~isfinite(Y)), warning('Found non-finite values in Y (could be the data).'); end;
	argout = Y;
end

