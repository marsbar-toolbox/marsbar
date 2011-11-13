function subjroot = get_subjroot()
% FORMAT subjroot = get_subjroot()
%
% Gets the root path for the example data.
% Looks first for an environment variable, if not defined, uses GUI
subjroot = getenv('MARSBAR_EG_DATAPATH');
% Otherwise fetch via the GUI
if isempty(subjroot)
    subjroot = spm_get(-1, '', 'Root directory of example data');
end
if ~exist(fullfile(subjroot, 'sess1'), 'dir')
    error(sprintf('Expecting "sess1" directory in %s', subjroot))
end
return
