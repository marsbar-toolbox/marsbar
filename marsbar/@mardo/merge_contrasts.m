function [D,changef] = merge_contrasts(D, D2, Ic)
% merge contrasts from one design to another
% FORMAT [D changef] = merge_contrasts(D, D2, Ic)
%
% D         - design to put contrasts into
% D2        - design with contrasts to add OR
%             contrast structure
% Ic        - indices of contrasts to add OR
%             empty, not passed to get GUI OR
%             'all' to add all contrasts
%
% Returns
% D         - design with any added contrasts
% changef   - set to 1 if any contrasts have been added
%  
% The routine only adds contrasts that are not already present
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

% Get design, xCons
SPM = des_struct(D);
xX = SPM.xX;
xCon_o = SPM.xCon;

% second input can be a design or a contrast structure
if isstruct(D2)
  xCon_s = D2;
  if isfield('xCon')
    xCon_s = xCon_s.xCon;
  end
else  % it's another mardo design
  xCon_s = get_contrasts(D2);
  if isempty(xCon_s)
    error('Source does not appear to contain contrasts');
  end
end

% Check all matches up
if size(xX.X, 2) ~= size(xCon_s(1).c, 1)
  error(['Source contrasts should have same no of rows as the ' ...
	 'design has columns']);
end

changef = 0;
if isempty(Ic);
  % need to make a design for running GUI, if only a structure
  if ~isa(D2, 'mardo')
    D2 = set_contrasts(D, D2);
  end
  Ic = ui_get_contrast(D2,'T&F',Inf,...
		       'Select contrasts to merge','',0);
end
if strcmp(Ic, 'all')
  Ic = 1:length(xCon_s);
end
if isempty(Ic)
  return;
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