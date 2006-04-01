%---------------------------------------------------------------
% Generic single analysis wrapper for SPM99 crash mode.
% Sorry, I mean SPM99 batch mode.
%---------------------------------------------------------------
% The analysis parameters are specified here using the global variable
% SPM_BCH_VARS
% Fields are:
% work_dir      - work_dir
% ana_type      - number specifying analysis type
% m_file        - string giving mfile to run
% 
% We have to use the global variable to pass parameters here because of
% the peculiarities of the batch mode.
%---------------------------------------------------------------
%
% $Id: do_bch_wrapper.m,v 1.1.1.1 2004/08/14 00:07:52 matthewbrett Exp $

global SPM_BCH_VARS

% get (and make) the subdirectory in the main directory
work_dir = {SPM_BCH_VARS.work_dir};
[pn1 pn2] = fileparts(work_dir{1});
if ~exist(work_dir{1}, 'dir')
  mkdir(pn1, pn2);
end

analyses = struct( ... 
      'type', 		SPM_BCH_VARS.ana_type, ... 
      'index', 		1, ...
      'work_dir', 	1, ...
      'mfile', 		1 ...
    );

type = {'model','contrasts','defaults_edit','headers',...
	'means','realign','normalize','smooth'};

mfile = {SPM_BCH_VARS.m_file};
