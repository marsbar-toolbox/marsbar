% Runs pre-release clean up 
V = marsbar('ver');
disp(['MarsBaR version: ' V]);
make_contents(['Contents of MarsBaR ROI toolbox version ' V], 'fncr');
if exist('contents.old', 'file')
  delete('contents.old');
end
