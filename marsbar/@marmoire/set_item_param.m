function o = set_item_param(o, item, param, value)
% method to set item parameters
% FORMAT o = set_item_param(o, item, param, value)
%
% o     - object
% item  - item name
% param - parameter name
% value - value to set
%
% Returns
% o     - object
% 
% $Id$
  
if nargin < 2
  error('Need item name');
end
if nargin < 3
  error('Need parameter name');
end
if nargin < 4
  error('Need value to set')
end

I = get_item_struct(o, item);

fns = fieldnames(I);
tmp = strmatch('data', fns, 'exact');
fns(tmp) = [];

if ~ismember(param, fns)
  error(['There is no parameter callled: ' param]);
end

I = setfield(I, param, value);
o = set_item_struct(o, item, I);