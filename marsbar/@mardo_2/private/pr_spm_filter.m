function [vargout] = pr_spm_filter(K,Y)
% Removes low frequency confounds X0
% FORMAT [Y] = pr_spm_filter(K,Y)
% FORMAT [K] = pr_spm_filter(K)
%
% K           - filter matrix or:
% K(s)        - struct array containing partition-specific specifications
%
% K(s).RT     - observation interval in seconds
% K(s).row    - row of Y constituting block/partition s
% K(s).LChoice  - Low-pass  filtering {'hrf' 'Gaussian' 'none'}
% K(s).LParam   - Gaussian parameter in seconds
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
% pr_spm_filter implements high-pass filtering in an efficient way by
% using the residual forming matrix of X0 - low frequency confounds
%.pr_spm_filter also configures the filter structure in accord with the 
% specification fields if called with one argument
%___________________________________________________________________________
% @(#)pr_spm_filter.m	2.10 Karl Friston 03/03/04


% set or apply
%---------------------------------------------------------------------------
if nargin == 1 & isstruct(K)

	% set K.X0
	%-------------------------------------------------------------------
	for s = 1:length(K)

		% make high pass filter
		%-----------------------------------------------------------
		k       = length(K(s).row);
		n       = fix(2*(k*K(s).RT)/K(s).HParam + 1);
		X0      = spm_dctmtx(k,n);
		K(s).X0 = X0(:,2:end);
		
		% make low pass filter
		%-----------------------------------------------------------
		if isfield(K(s), 'LChoice')
		switch K(s).LChoice

			case 'none'
			%---------------------------------------------------
			h       = 1;
			d       = 0;

			case 'hrf'
			%---------------------------------------------------
			h       = spm_hrf(K(s).RT);
			h       = [h; zeros(size(h))];
			g       = abs(fft(h));
			h       = real(ifft(g));
			h       = fftshift(h)';
			n       = length(h);
			d       = [1:n] - n/2 - 1;

			case 'Gaussian'
			%---------------------------------------------------
			sigma   = K(s).LParam/K(s).RT;
			h       = round(4*sigma);
			h       = exp(-[-h:h].^2/(2*sigma^2));
			n       = length(h);
			d       = [1:n] - (n + 1)/2;
			if      n == 1, h = 1; end

			otherwise
			%---------------------------------------------------
			error('Low pass Filter option unknown');
			return
		end
		% create and normalize low pass filter
		%-----------------------------------------------------------
		K(s).KL = spdiags(ones(k,1)*h,d,k,k);
		K(s).KL = spdiags(1./sum(K(s).KL')',0,k,k)*K(s).KL;

		end
	end

	% return structure
	%-------------------------------------------------------------------
	vargout = K;

else
	% apply
	%-------------------------------------------------------------------
	if isstruct(K)

		% ensure requisite feilds are present
		%-----------------------------------------------------------
		if ~isfield(K(1),'X0') | ...
		      (isfield(K(1),'LChoice') & ~isfield(K(1), 'KL'))
			K = pr_spm_filter(K);
		end

		for s = 1:length(K)

			% select data
			%---------------------------------------------------
			y = Y(K(s).row,:);
			
			% apply low pass filter
			%---------------------------------------------------
			if isfield(K(s), 'KL')
				y = K(s).KL*y;
			end

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
	vargout   = Y;

end


