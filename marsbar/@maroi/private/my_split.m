function [stin, stout] = my_split(a, b)
% function my_split - split structure a into two, according to fields in b
%
% $Id$

if nargin < 2
  error('Need two structures');
end
stout = a;
stin = [];
if isempty(b), return, end

if ischar(b), b = {b};end
if isstruct(b), b = fieldnames(b);end

for bf = b(:)'
  if isfield(a, bf{1})
    stin = setfield(stin, bf{1}, getfield(a, bf{1}));
    stout = rmfield(stout, bf{1});
  end
end