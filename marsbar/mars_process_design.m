function [marsD, changef] = mars_process_design(marsD)
% creates MarsBaR compatible design from SPM design (spm2 version)
% Strips out any unwanted estimation fields to save space
% FORMAT [marsD, changef] = mars_process_design(marsD)
% 
% Inputs
% marsD      - SPM design structure
% 
% Outputs
% marsD      - (possibly) stripped design
% changef    - flag, set to 1 if the design has been stripped
% 
% $Id$

changef = 0;
if nargin < 1
  error('Need SPM design');
end

if SPM2
  % SPM2 designs saved as single 'SPM' structure
  if isfield(marsD,'SPM')
    changef = 1;
    marsD = marsD.SPM;
  end
  
  rm_fields = {'xVol', 'Vbeta', 'VResMS', 'VM','xCon','swd'};
  if isfield(marsD, 'xVol') % It's been estimated
    changef = 1;
    marsD = rmfield(marsD, rm_fields);
    marsD.xVi = rmfield(marsD.xVi, {'V','Cy','CY'});
  end

elseif SPM99
  rm_fields = {'XYZ','FWHM','Vbeta', 'VResMS', 'VM','R'};
  if isfield(marsD, 'XYZ')
    changef = 1;
    marsD = rmfield(marsD, rm_fields);
  end
end