function tf = swd_writable(D)
% returns true if swd directory can be written to 
% 
% $Id$
  
tf = 0;
swd = swd(D);
if isempty(swd), return, end

test_file = fullfile(swd, 'write_test.txt');
try
  save(test_file, 'test_file');
  tf = 1;
end
if tf, delete(test_file); end