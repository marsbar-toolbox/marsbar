function strs = summary(D)
% method returns cell array of strings describing design
% 
% $Id$

strs{1} = sprintf('SPM working dir    \t%s',  swd(D));
strs{2} = sprintf('Design type:       \t%s',  type(D));
strs{3} = sprintf('Modality:          \t%s',  modality(D));
if is_fmri(D)
  tmp = sf_recode(has_filter(D));
else
  tmp = 'N/A';
end
strs{4} = sprintf('Has filter?:       \t%s',  tmp);
strs{5} = sprintf('Has images?:       \t%s',  ...
		  sf_recode(has_images(D)));
strs{6} = sprintf('MarsBaR estimated?:\t%s', ...
		  sf_recode(is_mars_estimated(D)));
strs = [strs {'Description:'}, descrip(D)];

return

function str = sf_recode(tf)
if isnan(tf), str = 'unknown';
elseif tf,    str = 'yes';
else          str = 'no';
end
