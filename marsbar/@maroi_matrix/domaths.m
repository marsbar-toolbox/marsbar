function o = domaths(func, dat1, dat2)
% helper function to do maths on matrix object
% Binary operations (& | ~ xor etc) return binarize type objects
% Other operations return not-binarize type objects
% ROI reslicing thresholds are set from defaults
%
% $Id$
  
if nargin < 2
  error('Need function and object');
end
if nargin < 3
   dat2 = [];
end
d1 = describething(dat1);
d2 = describething(dat2);

if isa(dat1, 'maroi')
  o = dat1; dat1 = dat1.dat;
else % second must be an object
  o = dat2; 
end
if isa(dat2, 'maroi')
  dat2 = dat2.dat;
end

if nargin < 3 % no second object
  d = sprintf('%s(%s)', func, d1);
else % there is a second object / thing
  d = sprintf('%s(%s, %s)', func, d1, d2);
end

switch func
  case 'and'
   o.dat = dat1 & dat2;
  case 'or'
   o.dat = dat1 | dat2;
  case 'not'
   o.dat = ~dat1;
  case 'xor'
   o.dat = xor(dat1, dat2);
  case 'plus'
   o.dat = dat1 + dat2;
  case 'minus'
   o.dat = dat1 - dat2;
  case 'times'
   o.dat = dat1 .* dat2;
  case 'divide'
   o.dat = dat1 ./ dat2;
  case 'lt'
   o.dat = dat1 < dat2;
  case 'gt'
   o.dat = dat1 > dat2;
  case 'le'
   o.dat = dat1 <= dat2;
  case 'ge'
   o.dat = dat1 >= dat2;
  case 'eq'
   o.dat = dat1 == dat2;
  case 'ne'
   o.dat = dat1 ~= dat2;
 otherwise
  error(['Function ' func ' not yet defined']);
end

% convert from logical to double if necessary
o.dat = double(o.dat);

binf = ismember(func, {...
    'and',...
    'or',...
    'not',...
    'xor',...
    'lt',...
    'gt',...
    'le',...
    'ge',...
    'eq',...
    'ne'});

o = binarize(o, binf);
if binf
  o = roithresh(o, maroi('classdata', 'def_binthresh'));
else
  o = roithresh(o, maroi('classdata', 'def_wtthresh'));
end
o = descrip(o, d);
o = source(o, '');

function d = describething(o)
if isa(o, 'maroi')
  d = descrip(o);
elseif isnumeric(o)
  if prod(size(o)) == 1 % scalar
    d = num2str(o);
  else
    d = '[matrix]';
  end	
else
  d = '[non numeric input]';
end