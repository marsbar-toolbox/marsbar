function make_contents(aString, flags)
% MAKECONTENTS makes Contents file in current working directory.
%   MAKECONTENTS(STRING,FLAGS) creates a standard "Contents.m" file in the
%   current directory by assembling the first comment (H1) line in
%   each function found in the current working directory.  If a 
%   "Contents.m" file exists, it is renamed to "Contents.old", before
%   a new "Contents.m" file is created.  STRING is inserted as the 
%   first line of the "Contents.m" file;  if omitted, a blank line 
%   is inserted instead.  The function changes permission on the 
%   resultant "Contents.m" file to rw-r--r-- on Unix systems.
%
%   FLAGS can contain none or more of
%      'n'    - suppress path name in Contents file
%      'f'    - include first word of first line (excluded by default)
%      'c'    - use filename 'contents.m' instead of 'Contents.m'
%      'r'    - recursively list subdirectory contents also
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

if any(flags == 'c')
  cont_file = 'contents.m';
else
  cont_file = 'Contents.m';
end
disp(['Creating "' cont_file '" in ' pwd])
if exist([pwd filesep cont_file]) ~= 0 
     copyfile(cont_file,[cont_file(1:end-1) 'old']);
     delete(cont_file)
end

% Header lines
line1 = ['% ' aString];
fcontents = fopen(cont_file,'w'); 
fprintf(fcontents,'%s\n',line1);     
if ~any(flags == 'n')
  line2 = ['% Path ->  ' pwd];
  fprintf(fcontents,'%s\n',line2);     
end

% do write
do_list('.', fcontents, cont_file, flags);
fclose(fcontents);

% Change permissions on Contents.m file
% only valid for Unix systems, no effect in Win32 systems
if isunix
  unix(['chmod go+r ' cont_file]);
end
return

function do_list(dirname, fcontents, cont_file, flags);

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
files.m  = files.m(logical(~strcmpi(files.m, cont_file)));
if length(files.m)==0
     warning(['No m-files found in directory ' dirname])
     return
end
fprintf(fcontents,'%%\n'); 

if strcmp(dirname, '.')
  dirlab = dirname(2:end);
else
  dirlab = [dirname(3:end) filesep];
end
maxlen = size(char(files.m),2) + length(dirlab);

% Write first lines to Contents.m if they exist
for i = 1:length(files.m)
   fid=fopen(fullfile(files.path, files.m{i}),'r'); 
   aLine = '';
   while(isempty(aLine))
     aLine = fgetl(fid);
   end
   if (strcmp(aLine(1:8),'function') == 1),
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
for d = 1:length(dirnames)
  do_list(fullfile(dirname, dirnames{d}), fcontents, cont_file, flags);
end
return