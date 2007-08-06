function Ya = adjusted_data(D, Ic)
% Return adjusted data for estimated design and contrast no
% FORMAT Ya = adjusted_data(D, Ic)
% 
% D      - Estimated marsbar design
% Ic     - Contrast number to adjust for
% 
% Outputs
% Ya     - Adjusted data, N by M, where N is number of time points
%          and M is number of regions in estimated marsbar design
% 
% e.g
% E = estimate(D, Y);
% [E Ic] = add_contrasts(E, 'task', 'T', [1 0 0]);
% Ya = adjusted_data(E, Ic);
% 
% Matthew Brett

if nargin < 2
  error('Need contrast number');
end
if nargin < 3
  r_no = 1;
end
Ya = [];
if ~is_mars_estimated(D)
  error('Need a MarsBaR estimated design');
end

SPM   = des_struct(D);
B = betas(D);
xCon = get_contrasts(D);
Ya = spm_FcUtil('Yc', xCon(Ic),SPM.xX.xKXs, B);
