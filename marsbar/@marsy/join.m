function o = join(varargin)
% joins marsy objects into one object
% 
% $Id$

% assemble all input object into a cell array
% (deals with arrays of objects)
o_c_a = {};
ctr = 0;
n_n = [];
for v = 1:nargin
  o_arr = varargin{v};
  for i = 1:prod(size(o_arr))
    ctr = ctr + 1;
    
    % Check number of time points
    n = n_time_points(o_arr(i));
    if isempty(n_n), n_n = n;
    else
      if n ~= n_n
	error(sprintf(...
	    'Regions %d and %d have different numbers of time points',...
	    ctr, ctr-1));
      end
    end
    
    o_c_a{ctr} = o_arr(i);
  end
end

o = o_c_a{1};
want_sum_f = 1;
sum_func = sumfunc(o);
regions = {};
Y = [];
Yvar = [];
for i = 1:ctr
  o_a = o_c_a{i};
  if want_sum_f
    % if summary function differs from other
    % objects, abort collecting summary data
    if ~strcmp(sum_func,sumfunc(o_a)) | ...
      ~can_summarize(o_a)
      want_sum_f = 0;
    else
      if ~is_summarized(o_a)
	o_a = resummarize(o_a);
      end
      [t1 t2] = summary_data(o_a);
      Y =    [Y t1];
      Yvar = [Yvar t2];
    end
  end
  regions = [regions region(o_a)];
end

st = y_struct(o);
if want_sum_f
  st.Y = Y;
  st.Yvar = Yvar;
  st.sumfunc = sum_func;
else
  st = mars_struct('strip', st, {'Y','Yvar','sumfunc'});
end
st.regions = regions;
o = y_struct(o, st);