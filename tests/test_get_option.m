function test_get_option
% Test mars_get_option
% Tests assume no default configuration change
assert_equal(mars_get_option('statistics', 'voxfilter'), 0);
global MARS
MARS.OPTIONS.statistics.voxfilter = 1;
assert_equal(mars_get_option('statistics', 'voxfilter'), 1);
MARS.OPTIONS.statistics.voxfilter = 0;
assert_equal(mars_get_option('statistics', 'voxfilter'), 0);
% Not existing in base defaults, is empty
assert_equal(mars_get_option('not_likely', 'voxfilter'), [])
