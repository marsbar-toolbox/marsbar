function [rs,r_nos] = region(o, r_nos)
% gets best fill of region data into cell array
% FORMAT ri = region(o, r_nos)
% 
% Inputs
% o              - marsy object
% r_nos          - region number 
%                  or array of region numbers
%                  or empty - giving all regions
% 
% Returns
% rs             - cell array of region structures
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

def_r_st = struct('name', '',...
		  'descrip', '',...
		  'Y', [],...
		  'weights', [],...
		  'info', struct([]),...
		  'vXYZ', [],...
		  'mat',  []);

st = y_struct(o);
r_f = isfield(st, 'regions');
y_f = isfield(st, 'Y');

for i = 1:length(r_nos)
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

