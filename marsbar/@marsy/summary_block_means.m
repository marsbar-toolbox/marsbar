function mus = summary_block_means(Y)
% return raw means over blocks in summary data
% 
% Input
% Y        - marsy object
% 
% mus      - means over block.  Returns B x N matrix
%            where B is number of blocks, and N is number
%            of ROIs 
% 
% $Id$

y = summary_data(Y);
r = block_rows(Y);

B = length(r);
N = size(y, 2);

mus = zeros(B, N);

for b = 1:B
  mus(b, :) = mean(y(r{b},:),1);
end