function ui_ft_design_data(D, mY, e_s, e_n)
% method plots FT of design and data to graphics window
% FORMAT ui_ft_design_data(D, mY, e_s, e_n)
% 
% Inputs
% D           - design object
% mY          - marsy data object
% e_s         - event specification (session no, event no)
% e_n         - optional name for the event
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
if nargin < 4, e_n = ''; end

if isempty(e_s)
  % Setup input window
  [Finter,Fgraph,CmdLine] = spm('FnUIsetup','Design filter', 1);
  [e_s e_n] = ui_get_event(D);
end
if isempty(e_n), e_n = 'Event'; end

% Get the regressors and data
X         = x(D);
R         = X(:, event_cols(D,e_s));
Y         = summary_data(mY);
r         = block_rows(D);
r         = r{e_s(1)};
R         = R(r,:);
Y         = Y(r,:);
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
