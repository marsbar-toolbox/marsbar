function [img, errstr] = my_vol_func(vol, func)
% checks vol and func, returns processed image matrix or error
%
% $Id$

if nargin < 1
  error('Need object or vol struct');
end
if isa(vol, 'maroi_image')
  [vol def_func] = deal(vol.vol, vol.func);
else
  def_func = '';
end
if nargin < 2
  func = '';
end
if isempty(func), func = def_func; end

img = [];
errstr = '';

if ischar(vol) % filename passed?
  try 
    vol = spm_vol(vol);
  catch
    errstr = lasterr;
    return
  end
end

if isempty(vol)
  errstr = 'vol is empty';
  return
end
if ~isstruct(vol)
  errstr = 'vol is not struct';
  return
end
if ~isfield(vol, 'fname')
  errstr = 'vol does not contain fname field';
  return
end
  
try 
  % load image into matrix
  img = spm_read_vols(vol);
catch
  errstr = lasterr;
  return
end

% apply and check function if passed
if ~isempty(func)
  sz = size(img);
  try 
    img = double(eval(func));
  catch
    errstr = lasterr;
    img = [];
    return
  end
  
  % check that the image has not changed size
  sz2 = size(img);
  if length(sz) ~= length(sz2) | any(sz ~= sz2)
    img = [];
    errstr = sprintf('Bad function "%s" - the image has changed size',...
		     func);
  end
end