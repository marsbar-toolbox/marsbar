function [rs,r_nos] = region(o, r_nos, new_data, fieldname)
% gets / sets data for region or regions 
% FORMAT [rs r_nos] = region(o, r_nos) (set) OR
% FORMAT [rs r_nos]= region(o, r_nos, new_data, fieldname) (get)
% 
% Inputs
% o              - marsy object
% r_nos          - region number 
%                  or array of region numbers
%                  or empty - giving all regions
% new_data       - cell array containing new data to set for region
% fieldname      - optional string, to identify field to be set
%                  using data in new_data
%   
% Returns
% (get call)
% rs             - cell array of region structures
% (set_call)
% rs             - new marsy object with fields set
%   
% r_nos          - region nos (empty now -> all region nos)
% 
% $Id$

r = n_regions(o);
if nargin < 2
  r_nos = [];
end
if isempty(r_nos)
  r_nos = 1:r;
end    
if any(r_nos > r)
  error('Region numbers too large');
end

st = y_struct(o);
r_f = isfield(st, 'regions');
y_f = isfield(st, 'Y');
def_r_st = struct('name', '',...
		  'descrip', '',...
		  'Y', [],...
		  'weights', [],...
		  'info', [],...
		  'vXYZ', [],...
		  'mat',  []);
sum_func = sumfunc(o);
r_len = length(r_nos);

if nargin < 3
  % get call
  if ~r_len, rs = {}; return, end
  for i = 1:r_len
    r_st = [];
    if r_f
      r_st = st.regions{r_nos(i)};
    end
    r_st = mars_struct('fillafromb', def_r_st, r_st);
    if isempty(r_st.Y)
      if y_f
	r_st.Y = st.Y(:,r_nos(i));
      end
    end
    rs{i} = r_st;
  end
  return
end 

% set call
if nargin > 3
  % field name specified
  if ~ismember(fieldname, fieldnames(def_r_st))
    error(['Funny data field passed: ' fieldname]);
  end
end

if ~iscell(new_data), new_data = {new_data}; end
if length(new_data) ~= r_len
  error('Different numbers of new data cells and regions');
end
if ~r_len, rs = o; return, end

N = n_time_points(o);

% we need to fill regions if they are not already there
st.regions = region(o);

% flag to tell if we need to resummarize
re_sum_f = 0;

for i = 1:r_len
  r = r_nos(i);
  r_st = st.regions{r};
  if nargin > 3  % fieldname call
    n_st = setfield([], fieldname, new_data{i});
  else % structure call
    n_st = new_data{i};
  end
  
  % check if Y or weights are being set
  % if so, we will have to resummarize
  if isfield(n_st, 'Y')
    re_sum_f = 1;
    if size(n_st.Y, 1) ~= N
      error('Incorrect number of time points in data set call');
    end
  end
  if isfield(n_st, 'weights')
    if strcmp(sum_func, 'wtmean')
      re_sum_f = 1;
    end	  
    if ~isempty(n_st.weights) & size(n_st.weights, 1) ~= N
      error('Incorrect number of time points in weight set call');
    end
  end
  st.regions{r} = mars_struct('ffillmerge', st.regions{r}, n_st);
end

if re_sum_f
  st = mars_struct('strip', st, {'Y','Yvar'});
  rs = resummarize(y_struct(o, st)); 
else
  rs = y_struct(o, st); 
end
