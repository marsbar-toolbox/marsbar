function strs = summary(M)
% method returns cell array of strings describing marsy object
% 
% $Id$
  
strs{1} = sprintf('Description:           \t%s',  summary_descrip(M));
strs{2} = sprintf('Number of time points: \t%d',  n_time_points(M));
strs{3} = sprintf('Number of regions:     \t%d',  n_regions(M));
s_f = is_summarized(M);
strs{4} = sprintf('Is summarized?:        \t%s',  sf_recode(s_f));
strs{5} = sprintf('Summary function:      \t%s',  sumfunc(M));
if ~s_f
  strs{end+1} = sprintf('Can be summarized?:    \t%s', ...
		    sf_recode(can_summarize(M)));
end
ns = region_name(M, [], [], '');
if isempty(strvcat(ns))
  strs{end+1} = sprintf('Region names:          \t%s', ...
      'not specified');
else
  strs{end+1} = 'Region names:';
  for i = 1:length(ns)
    strs{end+1} = sprintf('Region %d:  %s', i, ns{i});
  end
end
return

function str = sf_recode(tf)
if isnan(tf), str = 'unknown';
elseif tf,    str = 'yes';
else          str = 'no';
end
