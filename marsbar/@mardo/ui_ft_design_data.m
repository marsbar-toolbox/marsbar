function ui_ft_design_data(D, mY, e_s, opts)
% method plots FT of design and data to graphics window
% FORMAT ui_ft_design_data(D, mY, e_s, opts)
% 
% Inputs
% D           - design object
% mY          - marsy data object
% e_s         - event specification (session no, event no)
% opts        - struct containing optional fields
%               'event_name' - name for the event
%               'filter' - apply design filter
%               'fig'    - figure handle to plot to
%
% $Id$
  
if ~is_fmri(D)
  disp('Need an FMRI design for design/data plot');
  return
end
if nargin < 2
  error('Need data to plot against');
end
mY = marsy(mY);
if n_time_points(mY) ~= n_time_points(D)
  error('Design and data have different number of rows');
end

if nargin < 3, e_s = []; end
if nargin < 4, opts = []; end

e_n = 'Event';
if isempty(e_s)
  % Setup input window
  [Finter,Fgraph,CmdLine] = spm('FnUIsetup','Design filter', 1);
  [e_s e_n] = ui_get_event(D);
end
if isfield(opts, 'fig')
  Fgraph = opts.fig; 
else 
  Fgraph = spm_figure('GetWin');
end
e_n_tmp = mars_struct('getifthere', opts, 'event_name');
if ~isempty(e_n_tmp)
  e_n = e_n_tmp;
end

s = e_s(1);
e = e_s(2);

% Get the regressors and data
X         = design_matrix(D);
R         = X(:, event_cols(D,e_s));
Y         = summary_data(mY);
r         = block_rows(D);
r         = r{s};
R         = R(r,:);
Y         = Y(r,:);

% Filter data if requested
if isfield(opts, 'filter')
    R = apply_filter(D, R, struct('sessions', s));
    Y = apply_filter(D, Y, struct('sessions', s));
end 

TR        = tr(D);
if isempty(TR)
  b_len = 1; 
  b_str   = 'cycles per time point';
else
  b_len = TR; 
  b_str   = 'Hz';
end
q         = length(r);
Hz        = [0:(q - 1)]/(q * b_len);
q         = 2:fix(q/2);
Hz        = Hz(q);

figure(Fgraph)
subplot(2,1,1);
gX    = abs(fft(R)).^2;
gX    = gX*diag(1./sum(gX));
gX    = gX(q,:);
plot(Hz, gX);
xlabel(sprintf('Frequency (%s)', b_str))
ylabel('Relative spectral density')
t_str = sprintf('Regressors for %s: block %d', e_n, e_s(1));
title(t_str, 'interpreter', 'none');
axis tight

subplot(2,1,2);
gX    = abs(fft(spm_detrend(Y))).^2;
gX    = gX*diag(1./sum(gX));
gX    = gX(q,:);
plot(Hz, gX);
xlabel(sprintf('Frequency (%s)', b_str))
ylabel('Relative spectral density')
title('Region data');
legend(region_name(mY));
axis tight

