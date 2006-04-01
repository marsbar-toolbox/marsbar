function o = convert_vols(o, ver)
% method that converts vol structs in design and converts to format 'ver'
% FORMAT o = convert_fo(o, ver)
% 
% Input
% o        - design object
% ver      - optional version for vols from '99' or '5'
%            Defaults to version for current SPM version
%
% Output
% o        - object with converted vols
% 
% Example
% % Convert vols to current format
% o = convert_vols(o);
% 
% % Convert to native format for SPM99 designs
% o = convert_vols(o, native_vol_ver(o));
% 
% $Id$

if nargin < 2
  ver = mars_vol_utils('current_ver');
end

SPM = des_struct(o);
SPM = sf_conv(SPM, ver, 'VY');
SPM = sf_conv(SPM, ver, 'xM', 'VM');
o = des_struct(o, SPM);

return

function S = sf_conv(S, ver, varargin)
V = mars_struct('getifthere', S, varargin{:});
if ~isempty(V)
  V = mars_vol_utils('convert', V, ver);
  S = setfield(S, varargin{:}, V);
end
return