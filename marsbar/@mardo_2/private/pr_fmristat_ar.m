function [rho,Vmhalf,V] = pr_fmristat_ar(res,X,nlags)
% function returns estimated AR coefficients using fmristat algorithm
% FORMAT [rho,Vmhalf,V] = pr_fmristat_ar(res,X,nlags)
% 
% See http://www.math.mcgill.ca/keith/fmristat/ and
% fmrilm.m in fmristat package for code, and
% Worsley, K.J., Liao, C., Aston, J., Petre, V., Duncan, G.H., Morales,
% F., Evans, A.C. (2002). A general statistical analysis for fMRI
% data. NeuroImage, 15:1-15
% for description of the algorithm
%  
% $Id$

if nargin < 2
  error('Need covariance and design');
end
if nargin < 3
  nlags = 1;
end

sX = spm_sp('Set', X);
R  = spm_sp('r', sX);

nlp1     = nlags+1;
[n nvox] = size(res);

% Bias reduction 
M=zeros(nlp1);
for i=1:(nlp1)
  for j=1:(nlp1)
    Di=(diag(ones(1,n-i+1),i-1)+diag(ones(1,n-i+1),-i+1))/(1+(i==1));
    Dj=(diag(ones(1,n-j+1),j-1)+diag(ones(1,n-j+1),-j+1))/(1+(j==1));
    M(i,j)=trace(R*Di*R*Dj)/(1+(i>1));
  end
end
invM = inv(M);

a = zeros(nlp1,nvox);
for lag = 0:nlags
  a(lag+1,:)= sum(res(1:(n-lag),:).*res((lag+1):n,:));
end

vhat = invM*a;
rho  = vhat(2:end,:) ./ (ones(nlags, 1) * vhat(1,:));
rho  = mean(rho,2)';

if nargout > 1
  % Whitening matrix; Appendix A3 Worsley et al (2002)
  [Ainvt posdef] = chol(toeplitz([1 rho]));
  p1 = size(Ainvt,1);
  A  = inv(Ainvt');
%  Vmhalf = toeplitz([A(p1,p1:-1:1) zeros(1,n-p1)], zeros(1,n)); 
  B  = [A(p1,p1:-1:1) zeros(1,n-p1)];
  Vmhalf = toeplitz(B, [B(1) zeros(1,n-1)]); 
  Vmhalf(1:p1,1:p1) = A;
end

if nargout > 2
  % Estimated covariance
  V = inv(Vmhalf*Vmhalf');
end