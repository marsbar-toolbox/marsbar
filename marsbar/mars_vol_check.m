function [samef, msg, chgf] = mars_vol_check(varargin)
% FORMAT [samef, msg, chgf] = mars_vol_check(V1, V2, ...)
% checks spm_vol structs are in same space
%
% V1, V2, etc      - arrays of spm_vol structs
%
% samef            - true if images have same dims, mats
% msg              - cell array containing helpful message if not
% chgf             - logical Nx2 array of difference flags
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Copied from spm_vol_check.m
% Matthew Brett
% $Id: spm_vol_check.m 2696 2009-02-05 20:29:48Z guillaume $


[fnames samef msg] = deal({},1,{});

if nargin < 1,
    return;
end

for i = 1:numel(varargin),
    vols   = varargin{i};
    if ~isempty(vols),
        if i == 1,
            dims   = cat(3,vols(:).dim);
            mats   = cat(3,vols(:).mat);
        else
            dims   = cat(3,dims,vols(:).dim);
            mats   = cat(3,mats,vols(:).mat);
        end
        fnames = {fnames{:}, vols(:).fname};
    end
end
  
nimgs = size(dims, 3);
if nimgs < 2,
    return;
end

labs = {'dimensions', 'orientation & voxel size'};

dimf = any(diff(dims(:,1:3,:),1,3));
matf = any(any(diff(mats,1,3)));
chgf = logical([dimf(:) matf(:)]);
chgi = find(any(chgf, 2));
if ~isempty(chgi),
    samef = 0;
    e1    = chgi(1);
    msg   = {['Images don''t all have the same ' ...
          sepcat(labs(chgf(e1,:)),', ')],...
        'First difference between image pair:',...
        fnames{e1},...
        fnames{e1+1}};
end

function s = sepcat(strs, sep)
% returns cell array of strings as one char string, separated by sep
if nargin < 2,
    sep = ';';
end
if isempty(strs),
    s = '';
    return
end
strs = strs(:)';
strs = [strs; repmat({sep}, 1, length(strs))];
s    = [strs{1:end-1}];

