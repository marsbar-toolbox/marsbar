function test_mardos
% Test the mardo initializations
pth = fileparts(mfilename('fullpath'));
des_pth = fullfile(pth, 'bad_mres.mat');
D = mardo(des_pth);
assert_equal(class(D), 'mardo_2');
% Filenames don't work for specific constructors
all_errors = 0;
try
    D = mardo_99(des_pth);
catch
    was_error = 1;
end
assert_true(was_error);
all_errors = 0;
try
    D = mardo_2(des_pth);
catch
    was_error = 1;
end
assert_true(was_error);
all_errors = 0;
try
    D = mardo_5(des_pth);
catch
    was_error = 1;
end
assert_true(was_error);
% From structure is OK
D = mardo_2(des_struct(D));
assert_equal(class(D), 'mardo_2');
