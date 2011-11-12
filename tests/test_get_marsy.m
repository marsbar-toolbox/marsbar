function test_get_marsy
% test get_marsy, and nearest neighbor handling bug
% Thanks to Peter Zeidman for spotting this one
st = struct('XYZ', [2,1,1], 'mat', diag([2,3,4,1]), 'vals', [])
roi = maroi_point
