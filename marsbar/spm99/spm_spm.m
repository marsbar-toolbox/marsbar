function spm_spm(VY,xX,xM,F_iX0,varargin)
% replacement spm_spm function to trap design->estimate calls
%
% $Id$

global BCH
mars = spm('getglobal', 'MARS');

% Make SPM design structure
spmD = struct('SPMid',['MarsBar version: ' marsbar('ver')],...
	      'VY', VY,...
	      'xX', xX,...
	      'xM', xM,...
	      'F_iX0', F_iX0);

if nargin > 4
  %-Extra arguments were passed for saving in the SPM design
  %---------------------------------------------------------------
  for i=5:nargin
    spmD = setfield(spmD, inputname(i), varargin{i-4});
  end
end
	      
% get ROIs + data
if isempty(BCH)
  roilist = spm_get(Inf,'roi.mat','Select ROI(s) to analyze data for');
  sumfunc = mars.statistics.sumfunc;
else
  % in batch mode
  roilist = spm_input('batch',{},'roilist'); 
  sumfunc = spm_input('batch', {}, 'sumfunc');
end
if isempty(roilist)
  return
end
marsY = mars_roidata(roilist, VY, mars.statistics.sumfunc, 'v');
if isempty(marsY.Y)
  warning('No data to analyze');
  return
end

% do stats
mars_stat(spmD, marsY);