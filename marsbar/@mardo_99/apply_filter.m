function Y = apply_filter(D, Y, flags)
% applies filter in design to data
% FORMAT Y = apply_filter(D, Y, flags)
%
% D      - design, which includes a filter
% Y      - data to filter (2D matrix or marsy data object)
% flags  - cell array of options including none or more of
%          {nothing yet}
%
% Returns
% Y      - filtered data
%
% $Id$
  
if nargin < 2
  error('Need data to filter');
end
if nargin < 3
  flags = '';
end
if ischar(flags), flags = {flags}; end

if ~is_fmri(D)
  return
end
if ~has_filter(D)
  error('This FMRI design does not contain a filter');
end

SPM = des_struct(D);
K = SPM.xX.K;

if isa(Y, 'marsy')  % marsy object
  rd = region_data(Y);
  for r = 1:length(rd)
    rd{r} = pr_spm_filter('apply', K, rd{r});
  end
  Y = region_data(Y, [], rd);
else                % 2D matrix
  Y = pr_spm_filter('apply', K, Y);
end
