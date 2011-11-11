function test_marsy_stripreg;
% Test stripping of regions
% Regions
ry = ones(22,1) * [0 1 2];
ri = struct('name', {'roi1', 'roi1'});
my = marsy({ry, ry}, ri, 'mean');
assert_equal(summary_data(my), ones(22,2));
assert_equal(region_data(my, []), {ry, ry});
my_stripped = as_summary_only(my);
assert_equal(summary_data(my_stripped), ones(22,2));
assert_equal(region_data(my_stripped, []), {ones(22,1), ones(22,1)})
