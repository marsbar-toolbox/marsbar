function Y = apply_filter(D, Y, flags)
% applies filter in design to data
% FORMAT Y = apply_filter(D, Y, flags)
%
% D      - design, which includes a filter
% Y      - data to filter (2D matrix or marsy data object)
% flags  - string specifying one option, or cell array specifying more
%          than one option, or struct with fields specifying options.
%          Values for strings, cell contents or field names are
%          'sessions'      - when used as struct field, value for field
%                            specifies sessions to apply filter for. The
%                            data size must match the length of the
%                            included sessions.
%
% Returns
% Y      - filtered data
%
% $Id$
  
if nargin < 2
  error('Need data to filter');
end
if nargin < 3
  flags = [];
end
if ~isempty(flags)
  if ischar(flags), flags = {flags}; end
  if iscell(flags)
    flags = cell2struct(repmat({''}, size(flags)), flags, 1);
  end
end
if ~is_fmri(D)
  return
end
if ~has_filter(D)
  error('This FMRI design does not contain a filter');
end

SPM = des_struct(D);
K = SPM.xX.K;

% Filtering from subset of sessions
if isfield(flags, 'sessions')
  ss = flags.sessions;
  if ~isempty(ss)
    blk_rows = block_rows(D);
    if any(ss < 1 | ss > length(blk_rows))
      error('Sessions appear to be out of range');
    end
    K = K(ss);
    K{1}.row = blk_rows{ss} - blk_rows{ss}(1) + 1; 
  end
end

if isa(Y, 'marsy')  % marsy object
  rd = region_data(Y);
  for r = 1:length(rd)
    rd{r} = pr_spm_filter('apply', K, rd{r});
  end
  Y = region_data(Y, [], rd);
else                % 2D matrix
  Y = pr_spm_filter('apply', K, Y);
end
