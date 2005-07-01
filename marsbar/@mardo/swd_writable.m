function tf = swd_writable(D)
% returns true if swd directory can be written to 
% 
% $Id$
  
tf = 0;
Swd = swd(D);
if isempty(Swd), return, end

test_file = fullfile(Swd, 'write_test.txt');
try
  save(test_file, 'test_file');
  tf = 1;
end
if tf, delete(test_file); end