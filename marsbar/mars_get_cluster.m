function [cXYZ, Z, M, pt, str] = mars_get_cluster
% load SPM results, returns XYZ point list for cluster
% FORMAT [cXYZ, Z, M, pt, str] = mars_get_cluster
% 
% Output
% cXYX     - XYZ for voxels in cluster
% Z        - statistic values for cluster
% M        - 4x4 matrix to convert to mm
% pt       - selected point in cluster
% str      - SPM title string
%
% $Id$
  
[cXYZ Z M pt str] = deal([]);

% Accept results already present, or load new ones
try 
  SPM = evalin('base', 'SPM');
catch
  evalin('base','[hReg,SPM,VOL,xX,xCon,xSDM] = spm_results_ui;');
end

cXYZ = []; M = [];
spm_input('Select cluster, then Yes to continue',1,'d');
if ~spm_input('Continue?',2, 'y/n',[1 0],1)
  return
end

errstr = sprintf(['''Cannot find SPM/VOL structs in the workspace; '...
		  'Please (re)run SPM results GUI''']);
SPM = evalin('base', 'SPM', ['error(' errstr ')']);
M = evalin('base', 'VOL.M', ['error(' errstr ')']);

%-Get current location
%-----------------------------------------------------------------------
pt   = spm_results_ui('GetCoords');

%---------------------------------------------------------------
if ~length(SPM.XYZ)
  spm('alert!','No suprathreshold clusters!',mfilename,0);
  spm('FigName',['SPM{',SPM.STAT,'}: Results']);
  return
end

Clusters = spm_clusters(SPM.XYZ);

[xyzmm,i] = spm_XYZreg('NearestXYZ',pt,SPM.XYZmm);
spm_results_ui('SetCoords',xyzmm);
tmp = Clusters==Clusters(i);
cXYZ = SPM.XYZmm(:, tmp);  
Z = SPM.Z(tmp);
str = SPM.title;