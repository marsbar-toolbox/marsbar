function make_contents(aString, flags, start_dir)
% MAKECONTENTS makes Contents file, usually in current working directory.
%   MAKECONTENTS(STRING [FLAGS [START_DIR]]) 
%   creates a standard "Contents.m" file in the
%   current directory by assembling the first comment (H1) line in
%   each function found in the current working directory.  If a 
%   "Contents.m" file exists, it is renamed to "Contents.old", before
%   a new "Contents.m" file is created.  STRING is inserted as the 
%   first line of the "Contents.m" file;  if omitted, a blank line 
%   is inserted instead.  The function changes permission on the 
%   resultant "Contents.m" file to rw-r--r-- on Unix systems.
%
%   FLAGS can contain none or more of
%      'n'    - suppress path name at top of Contents file
%      'f'    - include first word of first line (excluded by default)
%      'c'    - use filename 'contents.m' instead of 'Contents.m'
%      'r'    - recursively list subdirectory contents also
%      'i'    - include starting directory from file name path list
%      'p'    - save contents file in current rather than listed directory 
%      'd'    - don't make backup of old contents file  
% 
%   START_DIR can be omitted, giving a listing of current working
%       directory, or it can specify the directory to list
%
% Updated 29 June 2000.
% Revised to recurse down directories, handle options by
% Matthew Brett; 28 June 2003
%
% See also CONTENTS.
%
% $Id$

% Author(s): L. Bertuccioli 
%            A. Prasad

% Based on mkcontents.m by Denis Gilbert

% Default value of input string
if nargin < 1,
  aString =' ';
end
if nargin < 2
  flags = '';
end
if isempty(flags)
  flags = ' ';
end
if nargin < 3
  start_dir = '';
end
if isempty(start_dir)
  start_dir = pwd;
end

% parse flags
if any(flags == 'c')
  cont_file = 'contents.m';
else
  cont_file = 'Contents.m';
end
if any(flags == 'p')
  cont_dir = pwd;
else
  cont_dir = start_dir;
end
disp(['Creating "' cont_file '" in ' cont_dir])
cont_path = fullfile(cont_dir, cont_file);
if ~any(flags == 'd')  
  if exist(cont_path, 'file') 
    copyfile(cont_path, ...
	     fullfile(cont_dir, [cont_file(1:end-1) 'old']));
    delete(cont_path)
  end
end

% Header lines
line1 = ['% ' aString];
fcontents = fopen(cont_path,'wt');
if fcontents == -1
  error(['Could not open file: ' cont_path]);
end
fprintf(fcontents,'%s\n',line1);     
if ~any(flags == 'n')
  line2 = ['% Path ->  ' start_dir];
  fprintf(fcontents,'%s\n',line2);     
end

% set first past flag
flags = [flags '1'];

% do write
do_list(start_dir, fcontents, flags);
fclose(fcontents);

% Change permissions on Contents.m file
% only valid for Unix systems, no effect in Win32 systems
if isunix
  unix(['chmod go+r ' cont_path]);
end
return

function do_list(dirname, fcontents, flags)
persistent START_DIR ST_D_LEN;
if any(flags == '1') % first pass through
  START_DIR = dirname;
  ST_D_LEN = length(dirname) + 2; 
end

if any(flags == 'r')
  % find directories  
  dirlist = dir(dirname);
  dirnames = {dirlist([dirlist.isdir]).name};
  dirnames = dirnames(~(strcmp('.', dirnames) | strcmp('..', dirnames)));
else
  dirnames = {};
end

% find m files
files = what(dirname);  

% fix apparent bug in what function 
files = files(1);

% exclude any contents files
files.m  = files.m(logical(~strcmpi(files.m,'contents.m')));
if length(files.m)==0
     warning(['No m-files found in directory ' dirname])
     return
end
fprintf(fcontents,'%%\n'); 

% maybe exclude starting path from listing
if ~any(flags == 'i')  
  dirlab = dirname(ST_D_LEN:end);
  if ~any(flags == '1') % not first pass
    dirlab = [dirlab filesep];
  end
else % not excluding starting directory
  dirlab = [dirname filesep];
end
    
maxlen = size(char(files.m),2) + length(dirlab);

% Write first lines to Contents.m if they exist
for i = 1:length(files.m)
  fname = fullfile(files.path, files.m{i});
  fid=fopen(fname, 'rt'); 
  if fid == -1, error(['Error opening file: ' fname]); end
  aLine = '';
  while(isempty(aLine) | length(aLine) < 8)
    aLine = fgetl(fid);
  end
  if strcmp(aLine(1:8),'function'),
    count_percent = 0;
    while count_percent < 1 & feof(fid)==0; 
      line = fgetl(fid);
      if length(line) > 0 
	if ~isempty(findstr(line,'%')) 
	  count_percent = count_percent + 1;
	  rr=line(2:length(line));
	  if ~any(flags == 'f') % remove first word
	    [tt,rr]=strtok(line(2:length(line)));
	  end
	  rr = fliplr(deblank(fliplr(rr)));
	  fn = [dirlab strtok(char(files.m(i)),'.')];
	  n = maxlen - length(fn) - 1;
	  line = ['%   ' fn blanks(n) '- ' rr];
	  fprintf(fcontents,'%s\n',line);
	end % if ~isempty
      end % if length
      if feof(fid)==1  
	fn = [dirlab strtok(char(files.m(i)),'.')];
	n = maxlen - length(fn) - 1;
	line = ['%   ' fn blanks(n) '- (No help available)'];
	fprintf(fcontents,'%s\n',line); 
      end % if feof
    end % while
  end % if strcmp
  fclose(fid);
end
% recurse down directory tree
flags = flags(flags ~= '1'); % reset first pass flag 
for d = 1:length(dirnames)
  do_list(fullfile(dirname, dirnames{d}), fcontents, flags);
end
return