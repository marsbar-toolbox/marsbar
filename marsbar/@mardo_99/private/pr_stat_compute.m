function [Num, Stat, P, Pc] = pr_stat_compute(xCon, Xs, V, betas, ResidualMS);
% calculates contrast value, stats and p values for contrasts
% FORMAT [Num, Stat, P, Pc] = pr_stat_compute(xCon, Xs, V, betas, ResidualMS);
% 
% xCon      - contrast structure
% Xs        - design matrix
% V         - covariance matrix
% betas     - parameter estimates
% ResidualMS       - root mean square of residuals
% 
% Output
% Num       - contrast value (ess for F test)
% Stat      - statistic value
% P         - uncorrected p value
% Pc        - P value corrected for number of columns analyzed
%--------------------------------------------------------------------
%
% $Id$

nROI = size(betas,2);
nCon = length(xCon);

xpxm = spm_sp('xpx-',Xs);
xpVx = Xs.X'*V*Xs.X;
Bcov = xpxm*xpVx*xpxm;

[trRV trRVRV] = spm_SpUtil('trRV',Xs,V);
erdf = trRV^2/trRVRV;
RMS = sqrt(ResidualMS);

T_indices = [];
F_indices = [];
dfnum     = [];

Stat    = zeros(nCon, nROI);
P    = zeros(nCon, nROI);
check_Tvalue = zeros(nCon, nROI);

for ii = 1:nCon

%	[edf_tsp edf_Xsp] = spm_FcUtil('FconEdf', xCon(ii), Xs, V);

	switch(xCon(ii).STAT)
	   case 'T'
		%----------- to check calculation with h -----------
		h       = spm_FcUtil('Hsqr', xCon(ii), Xs);
		[trMV trMVMV]= spm_SpUtil('trMV', ...
				spm_FcUtil('X1o',xCon(ii),Xs), V);

		check_Tvalue(ii,:) = ((h*betas)/trMV)./RMS;
		check_dfnum(ii) = trMV;

		%----------- t value  -----------

		Num(ii,:) = xCon(ii).c'*betas;
    		Stat(ii,:) = Num(ii,:) ./ ...
			  (RMS .* sqrt((xCon(ii).c'*Bcov*xCon(ii).c)));
		P(ii,:) = 1 - spm_Tcdf(Stat(ii,:), erdf);
		T_indices = [T_indices ii];


    	   case 'F'  
		[trMV trMVMV]= spm_SpUtil('trMV', ...
				spm_FcUtil('X1o',xCon(ii),Xs), V);
		dfnum   = [dfnum trMV^2/trMVMV];
		h       = spm_FcUtil('Hsqr', xCon(ii), Xs);

		Num(ii,:) = sum( (h*betas).^2, 1 );
		Stat(ii,:) = (Num(ii,:)/trMV) ./ (RMS.^2);
		check_Tvalue(ii,:) = Stat(ii,:) ;
		P(ii,:) = 1 - spm_Fcdf(Stat(ii,:), ...
					[dfnum(end) erdf]);
		F_indices       = [F_indices ii];
		

	   otherwise
	        error(['unknown STAT "',xCon(ii).STAT,'"'])
	end
end

%- corrected P value for the number of ROI
%--------------------------------------------------------------------	   
Pc = ones(nCon, nROI) - (ones(nCon, nROI) - P).^nROI;