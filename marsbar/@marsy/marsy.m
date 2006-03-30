function [o,others] = marsy(params, region_stuff, summary_stuff)
% Class constructor for marsy: the MarsBaR data object
% FORMAT [o,others] = marsy(params, region_stuff, summary_stuff)
%
% Synopsis:
% % Some example data
% Y = rand(100, 10);
% 
% % Use data as time courese from 10 regions
% m_Y = marsy(Y);
% 
% % Use data as 10 samples (voxels from one region)
% m_Y = marsy({Y}, 'region_1', 'mean');
%
% % Extract data for ROI 'my_roi', from list (string array) of images P
% m_Y = get_marsy(my_roi, P, 'mean');  % method for maroi (region) object
%
% Inputs
% params  - can be: structure, either:
%             containing MarsBaR data structure or
%             containing fields for marsy object, which should include
%             'y_struct', containing data structure
%           OR: filename, which loads to give structure as above
%           OR: 2D matrix, containing summary data (Y) only (see below)
%           OR: cell array of 2D matrices, one per region 
% 
% region_stuff  - (optional) cell array of names for regions 
%                or array of structures containing information for
%                   regions
%                or cell array of structures with information 
%                Structure can have fields;
%                name    - string identifying region
%                descrip - longer description of region
%                Y       - matrix of samples (voxel data) for this
%                          region, size N by S1 for region 1, N by S2 for
%                          region 2 etc.
%                weights - weighting vector, one value for each sample
%                          1..S1 (for region 1) etc.
%                          Can be empty, so each sample has weight 1.
%                info    - structure containing any other fields of
%                          interest  
%                vXYZ    - any voxel coordinates in X Y Z dimension 
%                          (3 by S1 for region 1 etc).  
%                mat     - a 4x4 transformation matrix giving coordinates
%                          in mm from voxel coordinates in vXYZ
%
% summary_stuff - (optional) summary function to summarize data (string)
%                or structure containing information for summary data
%                Structure can have fields;
%                sumfunc - the summary function used to summarize the
%                          samples (voxels) per time point;  a string, 
%                          which is usually one of 'mean', 'median',
%                          'wtmean', 'eigen1', or 'unknown'
%                descrip - text field describing the origin of the data  
%                info    - a structure with fields defining any other
%                          interesting information about the region
%                block_rows - optional cell array, specifying the rows in
%                          the data that correspond to a particular
%                          session or subject (see below). If absent, the
%                          data is assumed to come from a single session
%                          or subject.
%
% Any data in region_stuff, summary info will overwrite region or summary
% information passed in the first argument
% 
% Outputs
% o       - marsy object
% others  - any unrecognized fields from params, for processing by
%           (as yet non-existent) children
%
% marsy is an object to contain MarsBaR data structures. 
% 
% The marsy object contains data for one or more ROIs.  It offers two
% possible views of the data; the SUMMARY view, which gives one summary time
% course for each ROI, and the REGION view, which gives all the timecourses
% available from the ROI.  For example, most ROIs contain more than one
% voxel, and, in the REGION view, there will be one time course for each
% voxel.  In the SUMMARY view, all the data for a single region, for each
% timepoint, are combined with a summary function, to give one
% representative value per time point, and therefore a single time course
% for the whole ROI.  The most common summary function would be the mean of
% all the samples (voxels) at each time point, but there are others (see
% below).
%  
% At its simplest, the marsy object can just contain a single time-course
% for a single ROI.   In this case the summary and region view will be
% the same.
% 
% It can also contain data for more than one ROI, and more than one 
% time course per region.  In this case the object needs to know how to
% summarize the timecourses for the ROIs to give the summary view.    
%
% Let's call the number of regions R
% All regions in the structure have data with the same number of time points
% Let's call the number of time points N
% For each region there may be many samples at each time point.
% For example, there is usually one sample from each voxel in the ROI.
% Let's call the number of samples (voxels) per time point S1..SR for
% regions 1..R.
% 
% Thus, the summary view will give an N by R matrix, with one row for
% each ROI.  The region view, for (say) region 2, will return all the
% samples for ROI 2, an N by S2 matrix.
% 
% The regions may also be associated with names, for interpreting output and
% to help remember where the data has come from.  They may also (optionally)
% be associated with a longer text description ('descrip'), and any fields
% you the user think may be useful (contained in 'info').
% 
% You can also (optionally) set text description and info data for the
% whole object, for examnple specifying where (all) the data was
% extraxcted from.
% 
% The data can come from several sessions or subjects.  Optionally, this
% can be specified with the summary data field 'block_rows', specifying
% which rows in the data correspond to which session or subject
%
% The object contains a data structure of a particular format, listed in
% the programmer's help for this function.  Please avoid using this
% structure directly, as this format may change at any time.  Instead,
% please use the public methods listed below
% 
% Methods
% verbose      - get/set whether reporting is verbose or not (1 or 0)
% summary_data - gets (N by R) summary matrix Y
% summary_descrip - gets/sets description of object
% summary_stuff - gets/sets information field of object
% resummarize  - recalculates summary data if possible
% is_summarized - returns 1 if data has been summarized already
% can_summarize - returns 1 if data can be suumarized without error
% sumfunc      - gets/sets summary function to summarize data
% block_rows   - gets/sets information on rows corresponding to
%                sessions/subjects 
% n_regions    - gets number of regions (R above)
% n_time_points - gets number of time points (N above)
% ui_plot      - a variety of plots of the data to SPM interface
% save_struct  - saves y_struct to disk as structure
%  
% region       - returns region structure, filled with defaults as necessary
% region_data  - gets region sample (voxel) data as cell array; returns
%                all regions if no region number specificed, or one cell
%                per region if region numbers are specified
% region_weights - as above, but for region weighting vector (see above)
% region_name  - gets cell array of region names as 1 by R cell array 
%                (if no region number is specified) or single cell string
%                if a single region is specified
% region_descrip - gets cell array of descriptions of specified region
% region_stuff  - gets cell array of info field of specified region
% xyz          - gets voxel or mm XYZ coordinates of given region
% join         - accepts several marsy objects, and merges into one (if
%                possible)
% split        - splits object into array of objects, with one element
%                for each region 
% 
% Other methods (to avoid)
% y_struct     - sets or gets data structure
% 
% $Id$
  
% Programmer's help
%
% Please see the caveats in the main help about using the object
% structure to access the object data.
%   
% Fields 
% ------
%  
% y_struct - structure containing MarsBaR data structure
% verbose - flag for verbose messages while working
% 
% The MarsBaR data structure
% --------------------------
% 
% The data structure contains fields:
%   Y       - matrix of summary time courses, N by R
%   Yvar    - matrix of summary time course variance, over samples for
%            each time point (usually voxels) - N by R 
%            (the marsbar code does not currently use Yvar)
%   sumfunc - the summary function used to summarize the samples (voxels)
%             per time point;  a string, which is usually one of
%             'mean', 'median', 'wtmean', 'eigen1', or 'unknown'
%   descrip - text field describing the origin of the data (optional)
%   info    - a structure defining any other interesting information
%             about where the data came from
% 
%   regions - cell array of structures, with one element per region (and
%             therefore one element per column in the Y field).
%             Regions is a cell array to allow different fields to be
%             filled for each region
%             Each structure in the cell array has fields 
%             name    - string identifying region
%             descrip - longer description of region
%             Y       - matrix of samples (voxel data) for this region, size
%                       N by S1 for region 1, N by S2 for region 2 etc.
%             weights - weighting vector, one value for each sample 1..S1
%                       can be empty, so each sample has weight 1.
%             info    - structure containing any other fields of interest
%             vXYZ    - any voxel coordinates in X Y Z dimension 
%                       (3 by S1 for region 1 etc).  
%             mat     - a 4x4 transformation matrix giving coordinates in
%                       mm from voxel coordinates in vXYZ

myclass = 'marsy';
defstruct = struct('y_struct', [],...
		   'verbose', 1);

if nargin < 1
  params = [];
end
if isa(params, myclass)
  o = params;
  return
end
if nargin < 2
  region_stuff = [];
end
if nargin < 3
  summary_stuff = [];
end

% check first input
if ischar(params)  % maybe filename
  params = load(params);
end
switch class(params)
 case 'marsy'
  % pass quietly through 
  o = params;
  return
 case 'struct'
  if ~isfield(params, 'y_struct')
    % Appears to be an MarsBaR data structure
    params = struct('y_struct',params);
  end
  
  % need to process old data structure format here
  if isfield(params.y_struct, 'cols')
    params.y_struct = sf_convert_0p23(params.y_struct);
  end
 case {'double','float'}
  % direct set of summary data call
  params = struct('y_struct', ...
		  struct('Y', ...
			 params, 'Yvar', ...
			 params * Inf, ...
			 'sumfunc', 'unknown'));
 case 'cell'
  % specifying region data
  n = size(params{1}, 1);
  for i = 1:length(params)
    n2 = size(params{i}, 1);
    if any(n - n2)
      error('All regions must have the same number of time points');
    end
    if isstruct(params{i})
      regions{i} = params{i};
    else
      regions{i} = struct('Y', params{i});
    end
  end
  params = struct('y_struct', struct('regions', {regions}));
 otherwise
  error('Unexpected data type for first input');
end

% get number of regions
R = NaN;
st = params.y_struct;
if isfield(st, 'Y')
  R = size(st.Y);
elseif isfield(st, 'regions')
  R = length(st.regions);
end

% process further inputs
if ~isempty(region_stuff)
  % region_stuff has been specified
  if ischar(region_stuff)
    region_stuff = {region_stuff};
  end
  if ~isnan(R)
    if length(region_stuff) ~= R
      error('region_stuff should have one entry per region');
    end
  end
  if iscell(region_stuff) & ischar(region_stuff{1}) % names only
    tmp = region_stuff; region_stuff = cell(size(region_stuff));
    for i = 1:length(tmp)
      region_stuff{i}.name = tmp{i};
    end
  end
  if isstruct(region_stuff) % need a cell array
    tmp = region_stuff; region_stuff = cell(size(region_stuff));
    for i = 1:length(tmp)
      region_stuff{i} = tmp(i);
    end
  end

  % set 
  if ~isfield(params.y_struct, 'regions')
    params.y_struct.regions = cell(1, length(region_stuff));
  end
  for i = 1:length(region_stuff)
    params.y_struct.regions{i} = mars_struct('ffillmerge', ...
					     params.y_struct.regions{i},...
					     region_stuff{i});
  end
end

if ~isempty(summary_stuff)
  % summary_stuff has been specified
  if ischar(summary_stuff) % sumfunc only
    summary_stuff = struct('sumfunc', summary_stuff);
  end
  params.y_struct = mars_struct('ffillmerge', ...
				params.y_struct, ...
				summary_stuff);
end

% fill with defaults, parse into fields for this object, children
[pparams, others] = mars_struct('ffillsplit', defstruct, params);

% add version tag (was CVS; now marsbar version)
pparams.cvs_version = marsbar('ver');

% set the marsy object
o  = class(pparams, myclass);

% calculate summary data if possible
o = resummarize(o);

return

% Subfunctions

% convert structure from MarsBaR <= 0.23
function o_st = sf_convert_0p23(i_st)
if ~isfield(i_st, 'cols')
  o_st = i_st;
  return
end
for r = 1:length(i_st.cols)
  col = i_st.cols{r};
  regions{r} = struct('name', col.name,...
		      'descrip', col.descrip,...
		      'Y', col.y,...
		      'weights', [],...
		      'info', struct('file', col.file),...
		      'vXYZ', [], ...
		      'mat', []);
end
o_st = struct('Y', i_st.Y,...
	      'Yvar', i_st.Yvar,...
	      'regions', {regions},...
	      'sumfunc', i_st.sumfunc,...
	      'descrip', 'Data from MarsBaR <= 0.23',...
	      'info', []);
return

