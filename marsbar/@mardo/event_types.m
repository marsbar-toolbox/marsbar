function res = event_types(D, et)
% method to get / set event types for design
% FORMAT et = event_types(D)
% to return event types for design
%
% FORMAT D  = event_types(D, et)
% to set event types for design
% 
% $Id$

SPM = des_struct(D);
if nargin < 2
  % get
  res = mars_struct('getifthere', SPM, 'event_types');
else
  % set
  SPM.event_types = et;
  res = des_struct(D, SPM);
end