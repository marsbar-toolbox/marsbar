function r = ui_plot(o, plot_spec, plot_params)
% method plots data in various formats
% FORMAT r = ui_plot(o, plot_spec, plot_params)
%
% Input
% o            - marsy object
%
% plot_spec    - can be a
%                string, in which case it has the same meaning as
%                    the structure version below, with only field 'types'
%                    set to this value, OR 
%                structure, with none ore more of fields
%                (in all cases, field missing is the same as the field
%                being empty)
%                r_nos      - region number(s) 
%                             (if empty, -> all regions)
%                b_nos      - session/subject numbers 
%                             (if empty, -> all blocks)  
%                types      - string, or cell arrays of strings
%                             specifying plot type(s).  Plot types can be
%                             one or more of: 
%                  'raw'    - plots raw time series 
%                  'acf     - plots autocorrelation function
%                  'fft'    - plots fourier analysis of time series
%                  'all'    - all of the above 
%                  (defaults to 'raw')
%                graphics_obj - graphics object(s) for plot.  
%                            If empty, becomes handle SPM graphics
%                            window, otherwise, can be a handle to
%                            figure, or enough handles to axes for all
%                            requested plots.  This is useful for putting
%                            the plot on a convenient figure or axis 
%   
% plot_params  - (optional) Parameters to pass to plots
%                Can be empty (giving defaults) or structure, or
%                cell array of structures, one per requested plot
%                Relevant fields of structure differ for different plot
%                types;
%                Plot 'fft': fields 'bin_length' distance between time
%                            points in seconds
%                     'acf': fields 'lags' no of lags to plot [10]
%
% Returns
% r            - results that were plotted; all the data for 'raw', all
%                the acf values for 'acf', all the fft coefficients for
%                'fft'.  Cell array, one cell per plot.
%
% Examples
% ui_plot(Y, 'all')  plots all plot types for all regions and sessions 
% ui_plot(Y, 'acf')  just plots ACF, for all regions
% ui_plot(Y, struct('types', 'fft', 'r_nos', 1))
%                    will plot fft for region 1 only
% f = figure; ui_plot(Y, struct('graphics_obj', f))
%                    will plot all plot types to the new figure
% ui_plot(Y, 'acf', struct('lags', 8))
%                    plots ACF for all regions, with lag of 8 rather than
%                    the default of 10
%
% $Id$ 
  
% Get, check data from object
[n_rows n_cols] = summary_size(o);
if ~prod([n_rows n_cols]), warning('No data to plot'), return, end
rows = block_rows(o);
Y    = summary_data(o);
N    = region_name(o);
S    = sumfunc(o);
info = summary_info(o);
if strcmp(S, 'unknown'), S = ''; end
if ~isempty(S), S = [' - ' S]; end

def_spec = struct('types', {{'raw'}}, ...
		  'r_nos', 1:n_cols, ...
		  'b_nos', 1:length(rows),...
		  'graphics_obj', []);

% Process plot type arguments
if nargin < 2
  plot_spec = [];
end
if ischar(plot_spec), plot_spec = struct('types', plot_spec); end
plot_spec = mars_struct('fillafromb', plot_spec, def_spec);

plot_types = plot_spec.types;
if ~iscell(plot_types)
  plot_types = {plot_types};
end
if strcmp('all', plot_types{1})
  plot_types = {'raw','acf','fft'};
end
n_p_t   = length(plot_types);
n_plots = n_p_t * length(plot_spec.r_nos); 

% Check passed graphics object(s)
gr_ob = plot_spec.graphics_obj;
if isempty(gr_ob)
  gr_ob = spm_figure('GetWin','Graphics');
  spm_results_ui('Clear', gr_ob, 0);
end
if ~all(ishandle(gr_ob))
  error('One or more graphics objects are not valid');
end
o_t = get(gr_ob, 'type');
if iscell(o_t)
  if any(diff(strvcat(o_t{:}),[],1))
    error('All graphics objects must be of the same type');
  end
  o_t = o_t{1};
end
switch o_t
 case 'figure'
  figure(gr_ob);
 case 'axes'
  if n_plots > length(gr_ob)
    error('Not enough axes for planned number of plots');
  end
 otherwise
  error(['Completely confused by graphics object type: ' o_t]);
end

rows     = rows(plot_spec.b_nos);
n_blocks = length(rows);

% Process plot_param arguments
if nargin < 3
  plot_params = cell(1,n_p_t);
end
if ~iscell(plot_params)
  plot_params = {plot_params};
end
if length(plot_params) == 1
  plot_params = repmat(plot_params, 1, n_p_t);
elseif length(plot_params) < n_p_t
  error(sprintf('You need %d plot_param entries', n_p_t));
end
 
% Default string, bin_length for fft plots
if mars_struct('isthere', info, 'TR')
  bin_length = info.TR;
  bin_str = 'Hz';	
else
  bin_length = 1;
  bin_str = 'cycles per time point';
end

p_ctr = 1;
for c = plot_spec.r_nos
  for p = 1:n_p_t
    switch o_t
     case 'figure'
      subplot(n_plots, 1, p_ctr); 
     case 'axes'
      axes(gr_ob(p_ctr));
    end

    y = Y(:,c);
    
    switch lower(plot_types{p})
     case 'raw'
      a_r = [];
      for s = 1:n_blocks
	a_r = [a_r; rows{s}(:)];
      end
      plot(y(a_r));
      axis tight
      hold on
      % add session indicators
      yrg = [min(y) max(y)];
      for s = 1:n_blocks
	rw = rows{s};
	if s > 1 % session divider
	  plot([rw(1) rw(1)]-0.5, yrg, 'k:');
	end
      end
      ylabel(['Signal intensity' S])
      xlabel('Time point');
      r{p_ctr} = y;
      
     case 'acf'
      if isfield(plot_params{p}, 'lags')
	lags = plot_params{p}.lags;
      else lags = 10;
      end
      mn_len = Inf;
      for s = 1:n_blocks
	if length(rows{s}) < mn_len, mn_len = length(rows{s}); end
      end
      lags = max([1 min([mn_len-4 lags])]);

      C = [];
      for s = 1:n_blocks
	by = y(rows{s});
	nb_rows = length(by);
	ty = toeplitz(by, [by(1) zeros(1, lags)]);
	ty([1:lags n_rows+1:end], :) = [];
	Cs      = corrcoef(ty);
	C       = [C Cs(1,:)];
	n       = nb_rows - 2;                   % df for correlation
	t_th    = spm_invTcdf(1-0.025, n);       % t for two tailed p=0.05 
	r_th(s) = sqrt(1/(n/t_th.^2+1));         % r equivalent
      end
      stem(C);
      axis tight
      hold on
      % add confidence intervals, labels, session indicators
      Crg = [min(C) max(C)];
      for s = 1:n_blocks
	s_vals = [0 lags] + (s-1)*(lags+1) + 1;
	plot(s_vals,  [r_th(s) r_th(s)], 'r:');
	plot(s_vals, -[r_th(s) r_th(s)], 'r:');
	if s > 1 % session divider line
	  plot([s_vals(1) s_vals(1)]-0.5, Crg, 'k:');
	end
      end
      xtl = get(gca,'xticklabel');
      xtl = num2str(mod(str2num(xtl)-1, lags+1));
      set(gca, 'xticklabel', xtl);

      ylabel('Correlation coefficient')
      xlabel('Lag');
      r{p_ctr} = C;
     case 'fft'
      if isfield(plot_params{p}, 'bin_length')
	b_len = plot_params{p}.bin_length;
	b_str = 'Hz';
      else
	b_len = bin_length;
	b_str = bin_str;
      end
      P = []; H = []; St = [];
      for s = 1:n_blocks
	by    = y(rows{s});
	gX    = abs(fft(by)).^2;
	gX    = gX*diag(1./sum(gX));
	q     = size(gX,1);
	Hz    = [0:(q - 1)]/(q * b_len);
	q     = 2:fix(q/2);
	P     = [P gX(q)'];
	St(s) = length(H)+1;
	H     = [H; Hz(q)'];
      end
      plot(P)
      hold on
      Prg = [min(P) max(P)];
      for s = 2:n_blocks
	plot([St(s) St(s)]-0.5, Prg, 'k-');
      end
      axis tight
      % Rename tick labels 
      xt  = get(gca, 'xtick');
      xt  =  xt(xt==fix(xt));
      set(gca, 'xtick', xt);
      for t = 1:length(xt)
	xtl_fft{t} = sprintf('%5.3f', H(xt(t)));
      end
      set(gca, 'xticklabel', xtl_fft);
      xlabel(sprintf('Frequency (%s)', b_str))
      ylabel('Relative spectral density')
      axis tight
      r{p_ctr} = P;
     otherwise
      error(['What is this plot type: ' plot_types{p} '?']);
    end
    title(N{c}, 'interpreter', 'none');
  
    p_ctr = p_ctr + 1;
  end
end

return

