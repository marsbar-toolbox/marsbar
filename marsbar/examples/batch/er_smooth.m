function er_smooth(subjroot, sesses, filt, fwhm)
% smooth images prior to analysis
%
% Inputs
% subjroot     - root directory containing session directories
% sesses       - cell array containing session subdirectories
% filt         - shell exp filter for selecting files
% fwhm         - FWHM in mm for smoothing
%
% $Id: er_smooth.m,v 1.1.1.1 2004/08/14 00:07:52 matthewbrett Exp $

nsesses = length(sesses);

imgs = '';
for s = 1:nsesses
  dirn = fullfile(subjroot,sesses{s});
  % get files in this directory
  imgs = strvcat(imgs, spm_get('files', dirn, filt));
end

% and this is just spm_smooth_ui pasted/edited
P     = imgs;
n     = size(P,1);

% implement the convolution
%---------------------------------------------------------------------------
for i = 1:n
  Q = deblank(P(i,:));
  [pth,nm,xt] = fileparts(deblank(Q));
  U = fullfile(pth,['s' nm xt]);
  spm_smooth(Q,U,fwhm);
end




