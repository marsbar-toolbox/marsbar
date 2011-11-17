function test_add_contrasts
% Test the nasty bug for F contrasts
pth = fileparts(mfilename('fullpath'));
% The contrasts in this file messed up by the bug
des_pth = fullfile(pth, 'bad_mres.mat');
% good and bad statistic values
t_val = 2.2173;
good_stats = [t_val, t_val*t_val]';
bad_stats = [t_val, 31.9573]';
% Do raw load first
st = load(des_pth);
xCon = st.SPM.xCon;
% Reload into marsbar design
bad_e = mardo(des_pth);
% Set bad contrasts by hand (no checking)
bad_e.xCon = xCon;
res = compute_contrasts(bad_e);
assert_equal(res.stat, bad_stats, 1e-4);
% If we re-add the contrasts, they are correct
fresh_e = set_contrasts(bad_e, get_contrasts(bad_e));
res = compute_contrasts(fresh_e);
assert_equal(res.stat, good_stats, 1e-3);
% Bad is still bad
res = compute_contrasts(bad_e);
assert_equal(res.stat, bad_stats, 1e-4);
% Re-adding without refreshing is also bad
not_so_fresh_e = set_contrasts(bad_e, get_contrasts(bad_e), 0);
res = compute_contrasts(not_so_fresh_e);
assert_equal(res.stat, bad_stats, 1e-4);
% Adding always refreshes
fresh_e.xCon = [];
fresh_e = add_contrasts(fresh_e, get_contrasts(bad_e));
res = compute_contrasts(fresh_e);
assert_equal(res.stat, good_stats, 1e-3);
% Straight load does refresh with default options
bad_e = mardo(des_pth);
res = compute_contrasts(bad_e);
assert_equal(res.stat, good_stats, 1e-3);
% But does not when you set the right option
global MARS
MARS.OPTIONS.statistics.refresh_contrasts = 0;
bad_e = mardo(des_pth);
res = compute_contrasts(bad_e);
assert_equal(res.stat, bad_stats, 1e-4);
% Refreshing explicitly
fresh_e = refresh_contrasts(bad_e);
res = compute_contrasts(fresh_e);
assert_equal(res.stat, good_stats, 1e-3);
% Loading via mardo_2
SPM = des_struct(bad_e);
MARS.OPTIONS.statistics.refresh_contrasts = 1;
bad_e = mardo_2(SPM);
res = compute_contrasts(bad_e);
assert_equal(res.stat, good_stats, 1e-3);
MARS.OPTIONS.statistics.refresh_contrasts = 0;
bad_e = mardo_2(SPM);
res = compute_contrasts(bad_e);
assert_equal(res.stat, bad_stats, 1e-4);
