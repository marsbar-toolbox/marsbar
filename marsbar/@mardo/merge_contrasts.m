function [D,changef] = merge_contrasts(D, D2, Ic)
% merge contrasts from one design to another
% FORMAT [D changef] = merge_contrasts(D, D2, Ic)
%
% Matthew Brett 13/11/01 - CRD
%
% $Id$

if nargin < 2
  error('Need source of contrasts to merge');
end
if nargin < 3
  Ic = [];
end

% Get designs, xCons
SPM = des_struct(D);
xX = SPM.xX;
xCon_o = SPM.xCon;

% Second input can be structure or design
if isa(D2, 'mardo')
  D2 = des_struct(D2);
elseif isstruct(D2)
  D2 = mars_struct('ffillmerge', SPM, D2);
else
  error('Source should be a design or a structure');
end
try 
  xCon_s = D2.xCon;
catch
  error('Source does not appear to contain contrasts');
end
D2 = mardo(D2);

% Check all matches up
if size(xX.X, 2) ~= size(xCon_s(1).c, 1)
  error(['Source contrasts should have same no of rows as the ' ...
	 'design has columns']);
end

if isempty(Ic);
  Ic = ui_get_contrast(D2,'T&F',Inf,...
		       'Select contrasts to merge','',0);
end

% input, check if already present
sX = xX.xKXs;
xCon = xCon_o;
changef = 0;
for i=Ic
  contrast = xCon_s(i);
  iFc2 = spm_FcUtil('In', contrast, sX, xCon);
  if ~iFc2, 
      xCon(length(xCon)+1) = contrast;
      changef = 1;
   else 
      %- 
      fprintf('\ncontrast %s (type %s) already in xCon\n', ...
	      contrast.name, contrast.STAT);
   end
end
if changef
  SPM.xCon = xCon;
  D = des_struct(D, SPM);
end