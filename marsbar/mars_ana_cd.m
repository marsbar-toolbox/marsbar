function mars_ana_cd(spmmat, newpath, newspmpath, byteswap)
% utility for changing path to spm image files
% FORMAT mars_ana_cd(spmmat, newpath, newspmpath, byteswap)
%
% spmmat     - spm99 analysis filename or structure [GUI]
% newpath    - path to replace common path of files in analysis [GUI]
% newspmpath - path to save new spm analysis structure (same name) [GUI]
% byteswap   - whether to indicate byte swapping in vol structs [0]
%
% $Id$
  
if nargin < 1
  spmmat = [];
end
if nargin < 2
  newpath = spm_get(-1, '', 'New directory root for files');
end
if nargin < 3
  newspmpath = spm_get(-1, '', 'New directory for saved SPM.mat');
end
if nargin < 4
  byteswap=0;
end

% accepts or fetches name of SPM.mat file, returns SPM.mat structure
swd = [];
if isempty(spmmat)
  spmmat = spm_get(1, 'SPM.mat', 'Select analysis');
  if isempty(spmmat),return,end
end
if ischar(spmmat) % assume is SPM.mat file name
  [swd fn e] = fileparts(spmmat);
  spmmat = load(spmmat);
  spmmat.swd = swd;
elseif isstruct(spmmat)
  if isfield(spmmat, 'sfn')
    fn = spmmat.sfn;
  else
    fn = 'SPM.mat';
  end
  if isfield(spmmat,'swd')
    swd = spmmat.swd;
  end
else
  error('Requires string or struct as input');
end

% check the structure
if ~isfield(spmmat,'SPMid')
  %-SPM.mat pre SPM99
  error('Incompatible SPM.mat - old SPM results format!?')
end

% now change directory
if filesep == '\',sepchar='/';else sepchar='\';end
n = length(spmmat.VY);
strout = strvcat(spmmat.VY(:).fname);
msk    = diff(strout+0)~=0; % common path
d1     = min(find(sum(msk,1))); 
d1     = max([find(strout(1,1:d1) == sepchar | strout(1,1:d1) == filesep) 0]);
ffnames = strout(:,d1+1:end); % common path removed
tmp = ffnames == sepchar; % sepchar exchanged for this platform
ffnames(ffnames == sepchar) = filesep;
nfnames = cellstr(...
    strcat(repmat(newpath,n,1),filesep,ffnames));
[spmmat.VY(:).fname] = deal(nfnames{:});

% do byteswap as necessary
if byteswap
  scf = 256;
  if (spmmat.VY(1).dim(4) / 256)>=1;
    scf = 1/scf;
  end
  for i = 1:n
    spmmat.VY(i).dim(4) = spmmat.VY(i).dim(4) * scf;
  end
end    

% save 
savestruct(fullfile(newspmpath,fn),spmmat);

return

function savestruct(varargin)
% savestruct - saves data in structure to .mat file
% FORMAT savestruct(matname, struct)
  
if nargin ~= 2
  error('Need matfile name and structure (only)');
end
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
