function [tc, dt] = event_fitted_fir(D, event_spec, bin_length, bin_no)
% method to compute fitted event time courses using FIR
% FORMAT [tc, dt] = event_fitted_fir(D, event_spec, bin_length, bin_no)
% 
% (defaults are in [])
% D          - design
% event_spec - 2 by N array specifying events to combine
%                 with row 1 giving session number
%                 and row 2 giving event number in session
%                 This may in due course become an object type
% bin_length  - duration of time bin for FIR in seconds [TR]
% bin_no      - number of time bins [24 seconds / TR]
% 
% Returns
% tc         - fitted event time course, averaged over events
% dt         - time units (seconds per row in tc = bin_length)
%
% $Id$ 

if nargin < 2
  error('Need event specification');
end
if nargin < 3
  bin_length = [];
end
if nargin < 4
  bin_no = [];
end
if ~is_fmri(D) | isempty(event_spec)
  tc = []; dt = [];
  return
end
if ~is_mars_estimated(D)
  error('Need a MarsBaR estimated design');
end

if size(event_spec, 1) == 1, event_spec = event_spec'; end
[SN EN] = deal(1, 2);
e_s_l = size(event_spec, 2);
SPM   = des_struct(D);

if isempty(bin_length)
  bin_length = tr(D);
end
if isempty(bin_no)
  bin_no = 25/bin_length;
end
bin_no = round(bin_no);

% build a simple FIR model subpartition (X)
%------------------------------------------
dt          = bf_dt(D);
blk_rows    = block_rows(D);
SxX         = SPM.xX;
[n_t_p n_eff] = size(SxX.X);
y           = summary_data(SPM.marsY);
y           = apply_filter(D, y);
n_rois      = size(y, 2);
tc          = zeros(bin_no, n_rois);

% for each session
for s = 1:length(blk_rows)
  sess_events = event_spec(EN, event_spec(SN, :) == s);
  jX          = blk_rows{s};
  iX          = [];
  X           = [];
  n_s_e       = length(sess_events);
  for e = sess_events
    Xn          = event_x_fir(D, [s e]', bin_length, bin_no);
    X           = [X Xn];
    iX          = [iX event_cols(D, [s e])];
  end

  % put into previous design, and filter
  %------------------------------------------------------
  iX0         = [1:n_eff];
  iX0(iX)     = [];
  X           = [X SxX.X(jX,iX0)];
  KX          = apply_filter(D, X, struct('sessions', s));
  
  % Re-estimate to get tc
  %------------------------------------------------------
  j           = bin_no * n_s_e;
  xX          = spm_sp('Set',KX);
  pX          = spm_sp('x-',xX);
  tc_s        = pX*y(jX,:);
  tc_s        = tc_s(1:j, :)/dt;
  tc_s        = reshape(tc_s, bin_no, n_s_e, n_rois);
  
  % Sum over events
  tc          = tc + squeeze(sum(tc_s, 2));  
  
end
tc = tc / e_s_l;
dt = bin_length;