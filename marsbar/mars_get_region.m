function rno = mars_get_region(cols, prompt)
% select region from list box / input
% FORMAT rno = mars_get_region(cols, prompt)
% cols is cell array of strings, or columns from marsY structure
%
% $Id$

if nargin < 1
  error('Need region names to select from');
end
if nargin < 2
  prompt = 'Select region';
end

% maximum no of items in list box
maxlist = 200;

if isfield(cols{1}, 'name')
  % marsY cell format
  for i = 1:length(cols)
    tmp{i} = cols{i}.name;
  end
  cols = tmp;
end

rno = [];
if length(cols) > maxlist
  % text input, maybe
  error('Too many regions');
else
  % listbox
  rno = spm_input(prompt, '+1', 'm', char(cols));  
end