function display(obj)
% display - placeholder display for mars_space
%
% $Id$
  
X = struct(obj);
src = ['[mars_space object]'];
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