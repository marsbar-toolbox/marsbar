%---------------------------------------------------------------
% script to smooth images prior to analysis
%---------------------------------------------------------------
%
% $Id$

subjroot = spm_get('CPath', '..'); % from batch directory
exps = {'sess1','sess2','sess3'};
nexps = length(exps);

imgs = '';
for e = 1:nexps
  dirn = fullfile(subjroot,exps{e});
  % get files in this directory
  imgs = strvcat(imgs,...
		 spm_get('files', dirn, 'nu*img'));
end

% and this is just spm_smooth_ui pasted/edited
s     = 8;
P     = imgs;
n     = size(P,1);

% implement the convolution
%---------------------------------------------------------------------------
for i = 1:n
  Q = deblank(P(i,:));
  [pth,nm,xt,vr] = fileparts(deblank(Q));
  U = fullfile(pth,['s' nm xt vr]);
  spm_smooth(Q,U,s);
end




