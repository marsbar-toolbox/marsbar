function pre_release(rname, outdir)
% Runs pre-release export, cleanup
if nargin < 1
  rname = '';
end
if nargin < 2
  outdir = pwd;
end

% MarsBaR version
V = marsbar('ver');

% export from CVS
proj    = 'marsbar';
cmd = sprintf('cvs export -D tomorrow %s',...
	      proj);
unix(cmd);

% make contents file
make_contents(['Contents of MarsBaR ROI toolbox version ' V], 'fncrd', proj);

% move, tar directory
full_name = sprintf('%s-%s%s',proj,V,rname);
unix(sprintf('mv %s %s', proj, full_name));
unix(sprintf('tar zcvf %s.tar.gz %s', full_name, full_name));
unix(sprintf('rm -rf %s', full_name));

fprintf('Created %s release %s\n', proj, full_name);

