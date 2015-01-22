function pre_release(rname, outdir, proj, proj_descrip, proj_url)
% Runs pre-release export, cleanup
% FORMAT pre_release(rname, outdir, proj, proj_descrip)
%
% Inputs [defaults]
% rname        - string to define release version ['-%s']
% outdir       - directory to output release to [pwd]
% proj         - project name (and name of main project file) ['marsbar']
% proj_descrip - short description of project ['MarsBaR ROI toolbox']
% proj_url     - URL from which to clone project
%                ['git://github.com/matthew-brett/marsbar.git']
%
% e.g.  pre_release('-devel-%s', '/tmp')
% would output a release called marsbar-devel-0.34.tar.gz (if the marsbar
% version string is '0.34') to the /tmp directory

if nargin < 1
  rname = '';
end
if isempty(rname)
  rname = '-%s';
end
if nargin < 2
  outdir = '';
end
if isempty(outdir)
  outdir = pwd;
end
if nargin < 3
  proj = 'marsbar';
end
if nargin < 4
  proj_descrip = 'MarsBaR ROI toolbox';
end
if nargin < 5
    proj_url = 'git://github.com/matthew-brett/marsbar.git';
end

% project version
V = eval([proj '(''ver'')']);
rname = sprintf(rname, V);

% Clone from git
cmd = sprintf('git clone %s %s', proj_url, proj);
unix(cmd);

% make contents file
contents_str = sprintf('Contents of %s version %s', proj_descrip, V);
make_contents(contents_str, 'fncrd', fullfile(pwd, proj, proj));

% move directory
full_name = sprintf('%s%s', proj, rname);
unix(sprintf('mv %s/%s %s', proj, proj, full_name));
% Make archives
unix(sprintf('tar zcvf %s.tar.gz %s', full_name, full_name));
unix(sprintf('zip -r %s.zip %s', full_name, full_name));
% Remove traces of checkout
unix(sprintf('rm -rf %s', full_name));
unix(sprintf('rm -rf %s', proj));

fprintf('Created %s release %s\n', proj, full_name);
fprintf('Consider Changelog, e.g git log --pretty=%%s --first-parent\n');
