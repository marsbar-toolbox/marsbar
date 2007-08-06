function e = unfiltered_efficiency(D, Ic)
% Calculate unfiltered efficiency for given SPM design and contrast

if nargin < 2
  error('Need design and contrast number');
end
if ~has_contrasts(D)
  error('Need design with contrasts');
end

% Get contrast matrix to test for
xCon = get_contrasts(D);
con = xCon(Ic).c;

X = design_matrix(D);
e = 1 / trace(con' * pinv(X' * X) * con);
return
