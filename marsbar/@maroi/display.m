function display(obj)
% display - method 
%
% $Id$

inp_str = [inputname(1) ' ='];

sz = size(obj);
if prod(sz)>1
  arr_str = num2str(sz(1));
  for d = 2:length(sz)
    arr_str = [arr_str 'x' num2str(sz(d))];
  end
  arr_str = [arr_str ' maroi array with first element:'];
  
  if isequal(get(0,'FormatSpacing'),'compact')
    disp(inp_str);
    disp(arr_str);
  else
    disp(' ')
    disp(inp_str);
    disp(' ');
    disp(arr_str);
  end
  inp_str = [inputname(1) '(1) ='];
  obj = obj(1);
end

X = struct(obj);
bO.label = label(obj);
bO.source = source(obj);
bO.binarize = binarize(obj);
bO.roithresh = roithresh(obj);
bO.spm_hold = spm_hold(obj);

n =  descrip(obj);
if isempty(n), n = '(no descrip)';end
src = ['[' class(obj) ' - ' n ']'];
if isequal(get(0,'FormatSpacing'),'compact')
  disp(inp_str);
  disp(src);
  disp(bO)
  disp(X)
else
  disp(' ')
  disp(inp_str);
  disp(' ');
  disp(src);
  disp(' ');
  disp(bO)
  disp(' ');
  disp(X)
end    