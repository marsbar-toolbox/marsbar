function pre_release(username, rname, outdir)
% Runs pre-release export, cleanup
% FORMAT pre_release(username, rname, outdir)
% Inputs
% username     - marsbar CVS username
% rname        - string to define release version
% outdir       - directory to output release to
% 
% e.g.  pre_release('matthewbrett', '-devel-%s', '/tmp')
% would output a release called marsbar-devel-0.34.tar.gz (if the marsbar
% version string is '0.34') to the /tmp directory
%
% $Id$
  
if nargin < 1
  error('Need username');
end
if nargin < 2
  rname = '';
end
if nargin < 3
  outdir = pwd;
end

% MarsBaR version
V = marsbar('ver');
rname = sprintf(rname, V);

% export from CVS
proj    = 'marsbar';
cmd = sprintf(['cvs -d:ext:%s@cvs.sourceforge.net:/cvsroot/%s ' ...
	       'export -D tomorrow %s'], username, proj, proj);
unix(cmd);

% make contents file
make_contents(['Contents of MarsBaR ROI toolbox version ' V], 'fncrd', ...
	      fullfile(pwd, proj));

% make m2html documentation if the program is available
if ~isempty(which('m2html'))
  m2html('mfiles', proj, ...
	 'htmldir', fullfile(proj, 'doc'), ...
	 'graph', 'on', ...
	 'recursive', 'on', ...
	 'global', 'on')
end

% move, tar directory
full_name = sprintf('%s%s',proj, rname);
unix(sprintf('mv %s %s', proj, full_name));
unix(sprintf('tar zcvf %s.tar.gz %s', full_name, full_name));
unix(sprintf('rm -rf %s', full_name));

fprintf('Created %s release %s\n', proj, full_name);

