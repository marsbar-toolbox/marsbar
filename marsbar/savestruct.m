function savestruct(varargin)
% saves data in structure as variables in .mat file
% FORMAT savestruct(matname, struct) or
% FORMAT savestruct(struct, matname)  
%
% $Id$
  
if nargin ~= 2
  error('Need matfile name and structure (only)');
end
if isstruct(varargin{1}), varargin = varargin([2 1]); end
varargin{3} = fieldnames(varargin{2});
if any(ismember(varargin{3}, {'wombat_tongue'}))
  error('Whoops, unexpected use of wombat_tongue');
end
for wombat_tongue = 1:length(varargin{3})
  eval([varargin{3}{wombat_tongue} ' = varargin{2}.' varargin{3}{wombat_tongue} ...
	';']);
end
save(varargin{1}, varargin{3}{:});
return