function bw = remplie(roix,roiy,num_rows,num_cols)
% find the index of the points within the polygon for image 
% an image of dimension [ num_rows,num_cols ]
%
% $Id$

%close it
    if ((roix(1) ~= roix(end)) | (roiy(1) ~= roiy(end)))
        roix = [roix;roix(1)]; roiy = [roiy;roiy(1)];
    end


% Initialize output matrix.  We need one extra row to begin with.
bw = zeros(num_rows+1,num_cols);

num_segments = prod(size(roix)) - 1;

% Process each segment.
for counter = 1:num_segments
  x1 = roix(counter);
  x2 = roix(counter+1);
  y1 = roiy(counter);
  y2 = roiy(counter+1);

  % We only have to do something with this segment if it is not vertical
  % or a single point.
  if (x1 ~= x2)

    % Compute an approximation to the segment drawn on an integer
    % grid.  Mark appropriate changes in the x direction in the
    % output image.
    [x,y] = intline(x1,x2,y1,y2);
    if ((x1 < 1) | (x1 > num_cols) | (x2 < 1) | (x2 > num_cols) | ...
        (y1 < 1) | (y1 > (num_rows+1)) | (y2 < 1) | (y2 > (num_rows+1)))
      xLowIdx = find(x < 1);
      if (length(xLowIdx))
        x(xLowIdx) = ones(size(xLowIdx));
      end
      xHighIdx = find(x > num_cols);
      if (length(xHighIdx))
        x(xHighIdx) = (num_cols+1) * ones(size(xHighIdx));
      end
      yLowIdx = find(y < 1);
      if (length(yLowIdx))
        y(yLowIdx) = ones(size(yLowIdx));
      end
      yHighIdx = find(y > (num_rows+1));
      if (length(yHighIdx))
        y(yHighIdx) = (num_rows+1) * ones(size(yHighIdx));
      end
    end
    diffx = diff(x);
    dx_indices = find(diffx);
    dx_indices = dx_indices(:);  % converts [] to rectangular empty;
                                 % helps code below work for degenerate case
    if (x2 > x1)
      mark_val = 1;
    else
      mark_val = -1;
      dx_indices = dx_indices + 1;
    end
    d_indices = [y(dx_indices) (x(dx_indices)-1)] * [1; (num_rows+1)];
    bw(d_indices) = bw(d_indices) + mark_val(ones(size(d_indices)),1);
  end
    
end


% Now a cumulative sum down the columns will fill the region with 
% either 1's or -1's.  Compare the result with 0 to force a
% logical output.
bw = uint8(cumsum(bw) ~= 0);

% Get rid of that extra row and we're done!
bw(end,:) = [];


function [x,y] = intline(x1, x2, y1, y2)
%INTLINE Integer-coordinate line drawing algorithm.
%   [X, Y] = INTLINE(X1, X2, Y1, Y2) computes an
%   approximation to the line segment joining (X1, Y1) and
%   (X2, Y2) with integer coordinates.  X1, X2, Y1, and Y2
%   should be integers.  

dx = abs(x2 - x1);
dy = abs(y2 - y1);

% Check for degenerate case.
if ((dx == 0) & (dy == 0))
  x = x1;
  y = y1;
  return;
end

flip = 0;
if (dx >= dy)
  if (x1 > x2)
    % Always "draw" from left to right.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (y2 - y1)/(x2 - x1);
  x = (x1:x2).';
  y = round(y1 + m*(x - x1));
else
  if (y1 > y2)
    % Always "draw" from bottom to top.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (x2 - x1)/(y2 - y1);
  y = (y1:y2).';
  x = round(x1 + m*(y - y1));
end
  
if (flip)
  x = flipud(x);
  y = flipud(y);
end