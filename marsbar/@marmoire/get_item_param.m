function value = get_item_param(o, item, param)
% method to get item parameters
% FORMAT value = get_item_param(o, item, param)
%
% o     - object
% item  - item name
% param - parameter name
%
% Returns
% value - value for parameter
% 
% $Id$
  
if nargin < 2
  error('Need item name');
end
if nargin < 3
  error('Need parameter name');
end

I = get_item_struct(o, item);

fns = fieldnames(I);
tmp = strmatch('data', fns, 'exact');
fns(tmp) = [];

if ~ismember(param, fns)
  error(['There is no parameter callled: ' param]);
end

value = getfield(I, param);
