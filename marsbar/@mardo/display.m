function display(obj)
% display - placeholder display for mardo object
%
% $Id$
  
X = struct(obj);
src = ['[MarsBaR design object]'];
if isequal(get(0,'FormatSpacing'),'compact')
  disp([inputname(1) ' =']);
  disp(src);
  disp(X)
else
  disp(' ')
  disp([inputname(1) ' =']);
  disp(' ');
  disp(src);
  disp(' ');
  disp(X)
end    