function res = pr_needs_save(I)
% private function returning 1 if item data needs save
% 
% $Id$

res = ~pr_isempty(I) & I.has_changed & I.save_if_changed;
