function [tc, dt] = event_fitted_fir(D, e_spec, bin_length, bin_no, opts)
% method to compute fitted event time courses using FIR
% FORMAT [tc, dt] = event_fitted_fir(D, e_spec, bin_length, bin_no, opts)
% 
% (defaults are in [])
% D          - design
% e_spec     - 2 by N array specifying events to combine
%                 with row 1 giving session number
%                 and row 2 giving event number in session
%                 This may in due course become an object type
% bin_length  - duration of time bin for FIR in seconds [TR]
% bin_no      - number of time bins [24 seconds / TR]
% opts       - structure, containing fields with options
%                'single' - if field present, gives single FIR 
%                  This option removes any duration information, and
%                  returns a simple per onset FIR model, where 1s in the
%                  design matrix corresponds to 1 event at the given
%                  offset.  
%                'percent' - if field present, gives results as percent
%                  of block means
% 
% Returns
% tc         - fitted event time course, averaged over events
% dt         - time units (seconds per row in tc = bin_length)
%
% Here, just some notes to explain 'single' and 'stacked' FIR models.  Imagine
% you have an event of duration 10 seconds, and you want an FIR model.  To
% make things simple, let's say the TR is 1 second, and that a standard
% haemodynamic response function (HRF) lasts 24 seconds.
%  
% In order to do the FIR model, there are two ways to go.  The first is to
% make an FIR model which estimates the signal (say) at every second (TR)
% after event onset, where your model (Impulse Response) lasts long enough
% to capture the event and its HRF response - say 10+24 = 24 seconds.  This
% is what I will call a 'single' FIR model.  Another approach - and this is
% what SPM does by default - is to think of the 10 second event as a (say)
% 10 events one after the other, each starting 1 second after the last.
% Here the FIR model estimates the effect of one of these 1 second events,
% and the length of your FIR model (Impulse response) is just the length of
% the HRF (24 seconds).  This second approach I will call a 'stacked' FIR
% model, because the events are stacking up one upon another.
% 
% The single and stacked models are the same thing, if you specify a
% duration of 0 for all your events.  If your events have different
% durations, it is very difficult to model the event response sensibly with
% a single FIR, because, for the later FIR time bins, some events will have
% stopped, and activity will be dropping to baseline, whereas other events
% will still be continuing.  In this case the stacked model can make sense,
% as it just models longer events as having more (say) 1 second events.
% However, if your events have non-zero durations, but each duration is the
% same, then it may be that you do not want the stacked model, because your
% interest is in the event time course across the whole event, rather than
% some average response which pools together responses in the start middle
% and end of your actual event response, as the stacked model does.  In such
% a case, you may want to switch to a single FIR model.
%
% There is an added problem for the stacked models, which is what to do
% about the actual height of the regressors.  That problem also requires
% a bit of exposition which I hope to get down to in due course.
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
if nargin < 5
  opts = [];
end

if ~is_fmri(D) | isempty(e_spec)
  tc = []; dt = [];
  return
end
if ~is_mars_estimated(D)
  error('Need a MarsBaR estimated design');
end

if size(e_spec, 1) == 1, e_spec = e_spec'; end
[SN EN] = deal(1, 2);
e_s_l = size(e_spec, 2);

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
oX          = design_matrix(D);
[n_t_p n_eff] = size(oX);
y           = summary_data(data(D));
y           = apply_filter(D, y);
n_rois      = size(y, 2);
tc          = zeros(bin_no, n_rois);
blk_mns     = block_means(D);

% for each session
for s = 1:length(blk_rows)
  sess_events = e_spec(EN, e_spec(SN, :) == s);
  brX         = blk_rows{s};
  iX_out      = [];
  X           = [];
  n_s_e       = length(sess_events);
  if isempty(n_s_e), break, end
  
  for ei = 1:n_s_e
    e           = sess_events(ei);
    
    % New design bit for FIR model for this trial type
    Xn          = event_x_fir(D, [s e]', bin_length, bin_no, opts);
    
    % Columns from original design that need to be removed
    iX_out      = [iX_out event_cols(D, [s e])];
    
    % Columns in new design matrix for basic FIR model
    iX_in(ei,:) = size(X, 2) + [1:size(Xn,2)];
    
    X           = [X Xn];
  end

  % put into previous design for this session, and filter
  %------------------------------------------------------
  iX0         = [1:n_eff];
  iX0(iX_out) = [];
  aX          = [X oX(brX,iX0)];
  KX          = apply_filter(D, aX, struct('sessions', s));
  
  % Reestimate to get FIR time courses
  %------------------------------------------------------
  xX          = spm_sp('Set',KX);
  pX          = spm_sp('x-',xX);
  betas       = pX*y(brX,:);
  tc_s        = betas(1:size(X,2), :);
  
  % Sum over events  
  tc_s        = reshape(tc_s, bin_no, n_s_e, n_rois);
  tc_s        = squeeze(sum(tc_s, 2));  
  
  % Do percent if necessary
  if isfield(opts, 'percent'), tc_s = tc_s / blk_mns(s) * 100; end
  
  % Sum over sessions
  tc            = tc + tc_s;
  
end
tc = tc / e_s_l;
dt = bin_length;