function r = ui_plot(o, r_nos, plot_types, plot_params, graphics_obj)
% method plots data in various formats
% FORMAT r = ui_plot(o, r_nos, plot_types, plot_params, graphics_obj)
%
% Input
% o            - marsy object
% r_nos        - region number(s) 
%                (if empty, -> all regions)
% plot_types   - (optional) string, or cell arrays of strings specifying
%                plot type(s).  Plot types can be one or more of:
%                'raw'    - plots raw time series 
%                'acf     - plots autocorrelation function
%                'fft'    - plots fourier analysis of time series
%                'all'    - all of the above 
%                (defaults to 'raw')
% plot_params  - (optional) Parameters to pass to plots
%                Can be empty (giving defaults) or structure, or
%                cell array of structures, one per requested plot
%                Relevant fields of structure differ for different plot
%                types;
%                Plot 'fft': fields 'bin_length' distance between time
%                            points in seconds
%                     'acf': fields 'lag' no of lags to plot [10]
% graphics_obj - (optional) graphics object(s) for plot.  
%                If empty, becomes handle SPM graphics window
%                otherwise, can be a handle to figure, or 
%                enough handles to axes for all requested plots
% 
% $Id$ 
  
% Get, check data from object
[n_rows n_cols] = summary_size(o);
if ~prod([n_rows n_cols]), warning('No data to plot'), return, end
Y    = summary_data(o);
N    = region_name(o);
S    = sumfunc(o);
info = summary_info(o);
if strcmp(S, 'unknown'), S = ''; end
if ~isempty(S), S = [' - ' S]; end

if nargin < 2
  r_nos = [];
end
if isempty(r_nos)
  r_nos = 1:n_cols;
end
if ischar(r_nos)
  error('Second argument should be empty or contain region number(s)');
end
if nargin < 3
  plot_types = '';
end
if isempty(plot_types)
  plot_types = 'raw';
end
if ~iscell(plot_types)
  plot_types = {plot_types};
end
if strcmp('all', plot_types{1})
  plot_types = {'raw','acf','fft'};
end
n_p_t = length(plot_types);
if nargin < 4
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
if nargin < 5
  graphics_obj = spm_figure('GetWin','Graphics');
  spm_results_ui('Clear',graphics_obj, 0);
end
if ~all(ishandle(graphics_obj))
  error('One or more graphics objects are not valid');
end

n_p_t  = length(plot_types);
n_plots = n_p_t * length(r_nos); 

% Check passed graphics object(s)
o_t = get(graphics_obj, 'type');
if iscell(o_t)
  if any(diff(strvcat(o_t{:}),[],1))
    error('All graphics objects must be of the same type');
  end
  o_t = o_t{1};
end
switch o_t
 case 'figure'
  figure(graphics_obj);
 case 'axes'
  if n_plots > length(graphics_obj)
    error('Not enough axes for planned number of plots');
  end
 otherwise
  error(['Completely confused by graphics object type: ' o_t]);
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
for c = r_nos
  for p = 1:n_p_t
    switch o_t
     case 'figure'
      subplot(n_plots, 1, p_ctr); 
     case 'axes'
      axes(graphics_obj(p_ctr));
    end

    y = Y(:,c);
    
    switch lower(plot_types{p})
     case 'raw'
      plot(y);
      axis tight
      ylabel(['Signal intensity' S])
      xlabel('Time point');
      r{p_ctr} = y;
     case 'acf'
      if isfield(plot_params{p}, 'lag')
	lag = plot_params{p}.lag;
      else
	lags = 10; 
      end
      ty = toeplitz(y, [y(1) zeros(1, lags)]);
      ty([1:lags n_rows+1:end], :) = [];
      C    = corrcoef(ty);
      n    = n_rows - 2;                    % df for correlation
      t_th = spm_invTcdf(1-0.025, n);       % t for two tailed p=0.05 
      r_th = sqrt(1/(n/t_th.^2+1));         % r equivalent
      stem(0:lags,C(1,:));
      hold on
      plot([0 lags],  [r_th r_th], 'r:');
      plot([0 lags], -[r_th r_th], 'r:');
      ylabel('Correlation coefficient')
      xlabel('Lag');
      r{p_ctr} = C(1,:);
     case 'fft'
      if isfield(plot_params{p}, 'bin_length')
	b_len = plot_params{p}.bin_length;
	b_str = 'Hz';
      else
	b_len = bin_length;
	b_str = bin_str;
      end
      gX    = abs(fft(y)).^2;
      gX    = gX*diag(1./sum(gX));
      q     = size(gX,1);
      Hz    = [0:(q - 1)]/(q * b_len);
      q     = 2:fix(q/2);
      plot(Hz(q),gX(q,:))
      xlabel(sprintf('Frequency (%s)', b_str))
      ylabel('Relative spectral density')
      axis tight
      r{p_ctr} = gX;
     otherwise
      error(['What is this plot type: ' plot_types{p} '?']);
    end
    title(N{c}, 'interpreter', 'none');
  
    p_ctr = p_ctr + 1;
  end
end

return
