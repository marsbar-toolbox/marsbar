% Contents of MarsBaR ROI toolbox version 0.22
%
%   affichevol           - main ROI drawing function with all callbacks from the interface
%   fillafromb           - fills structure fields empty or missing in a from those present in b
%   is_there             - determines if field specified by string input is present and not empty
%   make_contents        - MAKECONTENTS makes Contents file in current working directory.
%   mars_argfill         - checks number of varargin arguments and fills missing args with defaults
%   mars_build_roi       - builds ROIs via the SPM GUI
%   mars_extract_data    - helper function to extract raw / filtered data from images via ROIs
%   mars_fill_design     - fills missing entries from SPM FMRI design matrix
%   mars_get_cluster     - load SPM results, returns XYZ point list for cluster
%   mars_get_filter      - gets filter using spm_fmri_spm_ui routines
%   mars_get_region      - select region from list box / input
%   mars_glm_estim       - does General Linear Model given data, design, covariance
%   mars_inputdata_ui    - gets model and data from matlab input
%   mars_merge_xcon      - merge contrasts from one xCon to another
%   mars_mm_model        - set sub-space of interest and the related matrix of normalisation. 
%   mars_model_data_ui   - gets model and data from matlab input
%   mars_new_space       - make a new image space to contain image with rotations etc
%   mars_roidata         - gets data in ROIs from images
%   mars_spm_graph       - Graphical display of adjusted data
%   mars_stat            - compute and save statistics for timecourses
%   mars_stat_compute    - calculates contrast value, stats and p values for contrasts
%   mars_stat_compute_mv - compute multivariate statistics across ROIs
%   mars_stat_struct     - compute and return stats
%   mars_stat_table      - gets Mars statistics and displays to a table on the matlab console  
%   mars_sum_func        - creates summary stats for region data
%   savestruct           - saves data in structure as variables in .mat file
%   splitstruct          - split input structure a into two, according to fields in b
%   mars_options         - options utility routines
%   mars_rois2img        - creates cluster or number labelled ROI image from ROIs
%   marsbar              - Startup, callback and utility routine for Marsbar
%   mars_display_roi     - utility routines for display of ROIs in graphic window
%   mars_img2rois        - creates ROIs from cluster image or image containing ROIs defined by unique nos
%
%   @maroi\and           - overloaded add function 
%   @maroi\back2base     - back2base method - check for spacebase, transform thereto
%   @maroi\binarize      - binarize - returns / sets binarize value for object
%   @maroi\c_o_m         - c_o_m method - calculates unweighted centre of mass
%   @maroi\classdata     - classdata method - see private/_classdata
%   @maroi\descrip       - name - returns / sets name value for object
%   @maroi\display       - display - method 
%   @maroi\eq            - overloaded xor function 
%   @maroi\ge            - overloaded xor function 
%   @maroi\getdata       - getdata method - fetches time series data for ROI from images 
%   @maroi\gt            - overloaded xor function 
%   @maroi\has_space     - has_space method - returns true if object has a native space
%   @maroi\history       - history - returns / sets history value for object
%   @maroi\label         - label - returns / sets label value for object
%   @maroi\le            - overloaded xor function 
%   @maroi\lt            - overloaded xor function 
%   @maroi\maroi         - maroi - class constructor for umbrella ROI object
%   @maroi\maroi_matrix  - maroi_matrix method - converts roi to maroi matrix type
%   @maroi\minus         - overloaded xor function 
%   @maroi\mrdivide      - overloaded xor function 
%   @maroi\mtimes        - overloaded mtimes function 
%   @maroi\native_space  - native_space method - returns native space of object
%   @maroi\ne            - overloaded ne function 
%   @maroi\not           - overloaded not function 
%   @maroi\or            - overloaded or function 
%   @maroi\paramfields   - returns struct with fields from maroi object useful for copying objects
%   @maroi\plus          - overloaded xor function 
%   @maroi\rdivide       - overloaded rdivide function 
%   @maroi\realpts       - realpts method - returns 3xN XYZ matrix in mm
%   @maroi\rle           - run length encoding method
%   @maroi\roithresh     - roithresh - returns / sets roithresh value for object
%   @maroi\save_as_image - method save_as_image - saves ROI as image
%   @maroi\save_mricro   - saves in MRIcro format
%   @maroi\saveroi       - saveroi method - checks fname, sets source field, saves object
%   @maroi\source        - source - returns / sets source value for object
%   @maroi\spm_hold      - hold - returns / sets hold value for object
%   @maroi\times         - overloaded times function 
%   @maroi\volume        - volume method - returns volume of ROI in mm
%   @maroi\xor           - overloaded xor function 
%   @maroi\flip_lr       - flips ROI left / right
%
%   @maroi\private\my_classdata - my_classdata method - sets/gets class data
%   @maroi\private\my_fillsplit - fills fields in a from those present in b, returns a, remaining b
%   @maroi\private\my_loadroi   - my_loadroi function - loads ROI(s) from file, sets source field
%   @maroi\private\my_merge     - function my_merge - merges two structures
%   @maroi\private\my_roifname  - changes fname to appropriate ROI format
%   @maroi\private\my_split     - function my_split - split structure a into two, according to fields in b
%
%   @maroi_box\is_empty_roi - is_empty_roi - returns true if ROI contains no volume
%   @maroi_box\maroi_box    - maroi_box - class constructor
%   @maroi_box\volume       - volume method - returns volume of ROI in mm
%   @maroi_box\voxpts       - voxpts method - voxels within a box in given space
%   @maroi_box\flip_lr      - flips ROI left / right
%   @maroi_box\centre       - centre method - sets / returns centre of ROI in mm
%
%   @maroi_image\maroi_matrix - maroi_matrix method - converts maroi_image to maroi_matrix
%   @maroi_image\vol          - vol - returns / sets image vol for object
%   @maroi_image\flip_lr      - flips ROI left / right
%   @maroi_image\loadobj      - loadobj method - reloads matrix from img file
%   @maroi_image\maroi_image  - maroi_image - class constructor
%   @maroi_image\saveobj      - saveobj method - removes matrix information from parent to save space
%
%   @maroi_image\private\my_vol_func - checks vol and func, returns processed image matrix or error
%
%   @maroi_matrix\do_write_image - save_as_image method - saves matrix as image and returns spm_vol
%   @maroi_matrix\domaths        - helper function to do maths on matrix object
%   @maroi_matrix\is_empty_roi   - is_empty_roi - returns true if ROI contains no volume
%   @maroi_matrix\loadobj        - loadobj function - undoes run length encoding if appropriate
%   @maroi_matrix\maroi_matrix   - maroi_matrix - class constructor
%   @maroi_matrix\native_space   - native_space method - returns native space of object
%   @maroi_matrix\rebase         - rebase method - returns data from maroi_matrix in new space
%   @maroi_matrix\saveobj        - saveobj function - does run length encoding if helpful
%   @maroi_matrix\spm_mat        - spm_mat method - returns mat file defining orientation etc
%   @maroi_matrix\voxpts         - voxpts method - returns 3xN ijk matrix in voxels
%   @maroi_matrix\flip_lr        - flips ROI left / right
%   @maroi_matrix\matrixdata     - matrixdata method - gets matrix from ROI object
%
%   @maroi_matrix\private\my_rld - function to do run length decoding 
%   @maroi_matrix\private\my_rle - method to do run length encoding on matrix
%
%   @maroi_pointlist\getvals         - returns vals for pointlist object
%   @maroi_pointlist\is_empty_roi    - is_empty_roi - returns true if ROI contains no volume
%   @maroi_pointlist\loadobj         - loadobj method - creates temporary voxel block
%   @maroi_pointlist\maroi_matrix    - maroi_matrix method - converts roi to maroi matrix type
%   @maroi_pointlist\maroi_pointlist - mars_roi - class constructor
%   @maroi_pointlist\native_space    - native_space method - returns native space of object
%   @maroi_pointlist\saveobj         - saveobj method - removes temporary voxblock structure
%   @maroi_pointlist\voxpts          - voxpts method - returns 3xN ijk matrix in voxels
%   @maroi_pointlist\flip_lr         - flips ROI left / right
%
%   @maroi_pointlist\private\my_voxblock - my_voxblock function - returns voxel block and modified mat file
%
%   @maroi_shape\has_space    - has_space method - returns true if object has a native space
%   @maroi_shape\maroi_matrix - maroi_matrix converter method for shape objects
%   @maroi_shape\maroi_shape  - maroi_shape - (virtual) shape roi class constructor
%   @maroi_shape\c_o_m        - c_o_m method - calculates centre of mass
%
%   @maroi_sphere\is_empty_roi - is_empty_roi - returns true if ROI contains no volume
%   @maroi_sphere\maroi_sphere - maroi_sphere - class constructor
%   @maroi_sphere\volume       - volume method - returns volume of ROI in mm
%   @maroi_sphere\voxpts       - voxpts method - voxels within a sphere in given space
%   @maroi_sphere\flip_lr      - flips ROI left / right
%   @maroi_sphere\centre       - centre method - sets / returns centre of ROI in mm
%
%   @mars_space\display    - display - placeholder display for mars_space
%   @mars_space\eq         - overloaded eq method for mars_space objects
%   @mars_space\mars_space - mars_space - class constructor for space defining object
%   @mars_space\subsasgn   - method to over load . notation in assignments.
%   @mars_space\subsref    - method to overload the . notation.
%
%   @mars_space\private\my_fillsplit - fills fields in a from those present in b, returns a, remaining b
%
%   fonct\bare_head    - returns bare header (pre mat file) mat info
%   fonct\draw         - draw function for ROI drawing tool
%   fonct\remplie      - find the index of the points within the polygon for image 
%   fonct\set_box_view - set_box_view function for ROI drawing tool
%   fonct\splatch_vol  - splatch_vol function for ROI drawing tool
%
%   init\affiche_tpos - affiche_tpos function for ROI drawing tool
%   init\initfigvol   - initialize figure for volume
%   init\mycolorbar   - display color bar (color scale) for ROI drawing tool
%   init\panel        - do panel for ROI drawing tool
%
%   spmrep\spm_bch_DoCont  - SPM batch system: Contrast computation - disabled for MarsBar
%   spmrep\spm_get_bf      - creates basis functions for each trial type {i} in struct BF{i}
%   spmrep\spm_orthviews   - Display Orthogonal Views of a Normalized Image
%   spmrep\spm_bch_GetCont - SPM batch system: Contrast structure creation - MarsBar version
%   spmrep\spm_spm         - replacement spm_spm function to trap design->estimate calls
