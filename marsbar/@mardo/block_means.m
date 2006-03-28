function bms = block_means(D)
% method returns means for blocks in design
% 
% Inputs
% D        - design object
%
% Outputs
% bms      - means over block.  Returns B x N matrix
%            where B is number of blocks, and N is number
%            of ROIs 
%
% $Id$

Y = data(D);
if isempty(Y)
  error('Design does not yet have data');
end
bms = summary_block_means(data(D));


