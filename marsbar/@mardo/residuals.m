function r = residuals(D)
% method returns residuals from model
%
% $Id$
  
if ~is_mars_estimated(D)
  error('Need estimated model');
end
Y = get_data(D);
if ~is_summarized(Y)
  Y = resummarize(Y);
end
if ~is_summarized(Y)
  error('Cannot get summarized data from model data');
end
y = summary_data(Y);

if is_fmri(D) 
  if ~has_filter(D)
    error('FMRI design lacks filter');
  end
  y = apply_filter(D, y);
end

SPM = des_struct(D);
r   = marsy(spm_sp('r',SPM.xX.xKXs,y), ...
	    region_name(Y), ...
	    struct('info',   summary_info(Y),...
		   'descrip', ['Residuals for ' summary_descrip(Y)],...
		   'block_rows', {block_rows(D)}));



