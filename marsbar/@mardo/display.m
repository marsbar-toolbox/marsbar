function display(obj)
% display method for mardo objects
%
% $Id$

src = ['[' class(obj) ' design object]'];
if length(obj) > 1 % array of objects
  sz = size(obj);
  src = sprintf('%d by %d array of %s', sz(1), sz(2), src);
  if isequal(get(0,'FormatSpacing'),'compact')
    disp([inputname(1) ' =']);
    disp(src);
  else
    disp(' ')
    disp([inputname(1) ' =']);
    disp(' ');
    disp(src);
    disp(' ');
  end    
else % single object
  X = char(summary(obj));
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
    disp(' ');
  end    
end
