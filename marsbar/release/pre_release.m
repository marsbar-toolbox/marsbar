function pre_release(rname)
% Runs pre-release export, cleanup
if nargin < 1
  rname = '';
end

V = marsbar('ver');
disp(['MarsBaR version: ' V]);

% export from CVS
usename = 'matthewbrett';
host    = 'cvs.sourceforge.net';
proj    = 'marsbar';
cmd = sprintf('cvs -d:ext:%s@%s:/cvsroot/%s export -D tomorrow %s',...
	      usename, host, proj, proj);
unix(cmd);

% make contents file
make_contents(['Contents of MarsBaR ROI toolbox version ' V], 'fncrd', proj);

% move, tar directory
full_name = sprintf('%s-%s%s',proj,V,rname);
unix(sprintf('mv %s %s', proj full_name));
unix(sprintf('tar zcvf %s.tar.gz %s', full_name, full_name));



