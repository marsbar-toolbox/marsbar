function test_marsy;
% Test creation of marsy objects
% Simple vector
y = ones(20,1);
my = marsy(y);
assert_equal(summary_data(my), y);
% Regions
ry = ones(22,3);
ri = struct('name', 'roi');
my = marsy({ry}, ri, 'mean');
assert_equal(summary_data(my), ones(22,1));
