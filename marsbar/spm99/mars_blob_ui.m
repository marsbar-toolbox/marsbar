function mars_blob_ui(action)
% Displays SPM results, and ROI menu in SPM input window
% FORMAT mars_blob_ui(action)
% 
% This is the SPM99 version
%
% action     - action string; can be
%                'init'      - initialise results interface
%                'save_one'  - UI to save current cluster
%                'save_many' - UI to save all clusters
%
% This routine does SPM version specific stuff, the main
% work is in mars_blob2roi.m and mars_blobs2rois.m
%
% $Id$  
  
if nargin < 1
  action = 'init';
end

errstr = sprintf(['''Cannot find SPM struct in the workspace; '...
		  'Please (re)run SPM results GUI''']);

switch lower(action)
 case 'init'
  try % and find valid SPM results stuff 
    evalin('base', 'SPM;');
    evalin('base', 'VOL.M;');
    hReg = evalin('base', 'hReg;');
    RD = get(hReg,'UserData');
    spm_XYZreg('VReg',RD.Reg,0);
    mars_blob_menu;
  catch % no good, need a new one
    mars_blob_ui('reinit');
  end
 case 'reinit'
  % Display SPM results
  evalin('base','[hReg,SPM,VOL,xX,xCon,xSDM] = spm_results_ui;');
  % and menu
  mars_blob_menu;
 case 'save_one'
  xSPM = evalin('base', 'SPM', ['error(' errstr ')']);
  xSPM.M =  evalin('base', 'VOL.M', ['error(' errstr ')']);
  %-Get current location
  pt   = spm_results_ui('GetCoords');
  mars_blob2roi(xSPM, pt);
 case 'save_many'
  xSPM = evalin('base', 'SPM', ['error(' errstr ')']);
  xSPM.M =  evalin('base', 'VOL.M', ['error(' errstr ')']);
  mars_blobs2rois(xSPM);
 otherwise
  error(['Worried by request for ' action]);
end
