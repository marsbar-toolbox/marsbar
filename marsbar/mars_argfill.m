function varargout = mars_argfill(vin, minin,defvals, efillf)
% checks number of varargin arguments and fills missing args with defaults
% FORMAT varargout = mars_argfill(vin, minin, defvals, efillf)
%
% Inputs [default]
% vin - varargin passed to calling function {}
% minin - min number of varargin allowed [0]
% defvals - cell array of default values {empty arrays}
%           varargins up to max not passed, are filled with values from
%           defvals
% efillf  - if not zero, fills passed empty varargin cells with defvals [0]
% 
% Matthew Brett 9/10/00
%
% $Id$
  
if nargin < 1,vin={};end
if nargin < 2,minin = 0;end
if nargin < 3,defvals = {};end
if nargin < 4,efillf = 0;end
l = length(vin);
if l < minin
  error(sprintf('Only %d varargin args passed. Function needs at least %d args', ...
	l, minin));
end
if l > nargout
  warning(sprintf('%d varargin args passed. Function expects at most %d args', ...
	l, narogut));
end
ld = length(defvals);
if ld<nargout
  [defvals{(ld+1):nargout}] = deal([]);
end
if efillf
  for i = 1:l
    if isempty(vin{i}), vin{i} = defvals{i};end
  end
end
if l<nargout
  [vin{(l+1):nargout}] = deal(defvals{(l+1):nargout});
end
varargout = vin;
return