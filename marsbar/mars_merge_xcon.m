function xCon = mars_merge_xcon(xX, xCon_o, xCon_s, savename)
% merge contrasts from one xCon to another
% FORMAT xCon = mars_merge_xcon(xX, xCon_o, xCon_s, savename)
%
% xX        - design structure matching contrasts
% xCon_o    - original xCon, into which to merge
% xCon_s    - source xCon with contrasts to merge
% savename  - filename to save merged xCon (no save it not specified)
%
% Matthew Brett 13/11/01 - CRD
%
% $Id$

if nargin < 1
  des_n = spm_get(1, '.mat', 'Select file with design matrix');
  des = load(des_n);
  if ~isfield(des, 'xX')
    error('Cannot find xX matrix in selected design file');
  end
  if ~isfield(des.xX, 'xKXs')
    error('Cannot find filtered matrix in selected design');
  end
  xX = des.xX;
  clear des;
end
  
if nargin < 4
  savename = '';
end
if nargin < 2
  xCon_o_n = spm_get(1, 'xCon.mat', 'Select destination xCon');
  load(xCon_o_n);
  xCon_o = xCon;
  if isempty(savename), savename = xCon_o_n;end
end
if nargin < 3
  xCon_s_n = spm_get(1, 'xCon.mat', 'Select source xCon');
  load(xCon_s_n);
  xCon_s = xCon;
end

% Check all matches up
if size(xX.X, 2) ~= size(xCon_o(1).c, 1)
  error(['Original contrasts should have same no of rows as the ' ...
	 'design has columns']);
end
if size(xX.X, 2) ~= size(xCon_s(1).c, 1)
  error(['Source contrasts should have same no of rows as the ' ...
	 'design has columns']);
end

[Ic xCon_m] = spm_conman(xX,xCon_s,'T&F',Inf,...
			 'Select contrasts to merge','',0);

% input, check if already present
sX = xX.xKXs;
xCon = xCon_o;
for i=Ic
  contrast = xCon_m(i);
  iFc2 = spm_FcUtil('In', contrast, sX, xCon);
  if ~iFc2, 
      xCon(length(xCon)+1) = contrast;
   else 
      %- 
      fprintf('\ncontrast %s (type %s) already in xCon\n', ...
	      contrast.name, contrast.STAT);
   end
end

if ~isempty(savename)
  try
    save(savename,'xCon')
  catch
    str = ['Can''t write file ' savename];
    warning(str);
  end
end