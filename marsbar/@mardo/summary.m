function strs = summary(D)
% method returns cell array of strings describing design
% 
% $Id$
  
strs{1} = sprintf('Design type:       \t%s',  type(D));
strs{2} = sprintf('Modality:          \t%s',  modality(D));
if is_fmri(D)
  tmp = sf_recode(has_filter(D));
else
  tmp = 'N/A';
end
strs{3} = sprintf('Has filter?:       \t%s',  tmp);
strs{4} = sprintf('Has images?:       \t%s',  sf_recode(has_images(D)));
strs{5} = sprintf('MarsBaR estimated?:\t%s',  sf_recode(is_estimated(D)));

return

function str = sf_recode(tf)
if isnan(tf), str = 'unknown';
elseif tf,    str = 'yes';
else          str = 'no';
end
