function pre_release(username, rname, outdir)
% Runs pre-release export, cleanup
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

% export from CVS
proj    = 'marsbar';
cmd = sprintf(['cvs -d:ext:%s@cvs.sourceforge.net:/cvsroot/%s ' ...
	       'export -D tomorrow %s'], username, proj, proj);
unix(cmd);

% make contents file
make_contents(['Contents of MarsBaR ROI toolbox version ' V], 'fncrd', ...
	      fullfile(pwd, proj));

% move, tar directory
full_name = sprintf('%s-%s%s',proj,V,rname);
unix(sprintf('mv %s %s', proj, full_name));
unix(sprintf('tar zcvf %s.tar.gz %s', full_name, full_name));
unix(sprintf('rm -rf %s', full_name));

fprintf('Created %s release %s\n', proj, full_name);

