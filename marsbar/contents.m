% Contents of MarsBaR ROI toolbox version 0.24
%
%   affichevol           - main ROI drawing function with all callbacks from the interface
%   is_there             - determines if field specified by string input is present and not empty
%   make_contents        - MAKECONTENTS makes Contents file in current working directory.
%   mars_argfill         - checks number of varargin arguments and fills missing args with defaults
%   mars_arm_call        - services callbacks from mars_armoire set functions
%   mars_armoire         - multifunction function to get/set various stores of stuff
%   mars_blob2roi        - saves ROI for cluster in xSPM structure, containing point pt
%   mars_blob_menu       - puts up ROI menu to add to SPM results interface
%   mars_blobs2rois      - creates ROIs from spm_results_ui SPM 
%   mars_build_roi       - builds ROIs via the SPM GUI
%   mars_conman          - wrapper for spm_conman, adding indicator for change of xCon
%   mars_display_roi     - utility routines for display of ROIs in graphic window
%   mars_fill_design     - fills missing entries from SPM FMRI design matrix (spm2 version)
%   mars_get_filter      - gets filter using spm_fmri_spm_ui routines
%   mars_get_region      - select region from list box / input
%   mars_image_scaling   - get image scaling data for images, maybe via SPM design
%   mars_img2rois        - creates ROIs from cluster image or image containing ROIs defined by unique nos
%   mars_merge_xcon      - merge contrasts from one xCon to another
%   mars_mm_model        - set sub-space of interest and the related matrix of normalisation. 
%   mars_new_space       - make a new image space to contain image with rotations etc
%   mars_options         - options utility routines
%   mars_process_design  - creates MarsBaR compatible design from SPM design (spm2 version)
%   mars_roidata         - gets data in ROIs from images
%   mars_rois2img        - creates cluster or number labelled ROI image from ROIs
%   mars_spm_graph       - Graphical display of adjusted data
%   mars_stat_compute    - calculates contrast value, stats and p values for contrasts
%   mars_stat_compute_mv - compute multivariate statistics across ROIs
%   mars_stat_struct     - compute and return stats
%   mars_stat_table      - gets Mars statistics and displays to a table on the matlab console  
%   mars_struct          - multifunction function for manipulating structures
%   mars_sum_func        - creates summary stats for region data
%   marsbar              - Startup, callback and utility routine for Marsbar
%   savestruct           - saves data in structure as variables in .mat file
%   splitstruct          - split input structure a into two, according to fields in b
%
%   @mardo/des_struct      - get/set method for des_struct field
%   @mardo/design_type     - returns SPM version string corresponding to design type
%   @mardo/display         - display - placeholder display for mardo object
%   @mardo/flip_images     - flips images in design
%   @mardo/flip_option     - get/set flag for flipping images in design
%   @mardo/has_filter      - returns 1 if object contains filter
%   @mardo/has_images      - returns 1 if design contains images
%   @mardo/is_marsed       - returns 1 if design has been processed with MarsBaR
%   @mardo/isempty         - overloaded isempty method
%   @mardo/isfield         - method to overload isfield 
%   @mardo/mardo           - mardo - class constructor for MarsBaR design object
%   @mardo/mars_tag        - returns, or sets, Mars tagging structure in design
%   @mardo/paramfields     - returns struct with fields from maroi object useful for copying objects
%   @mardo/savestruct      - saves data in def_struct as variables in .mat file
%   @mardo/subsasgn        - method to over load . notation in assignments.
%   @mardo/subsref         - method to overload the . notation.
%   @mardo/verbose         - get/set method for verbose field
%   @mardo/cd_images       - method for changing path to image files in design
%   @mardo/deprefix_images - method for removing prefix from file names in design
%   @mardo/get_image_names - method returning image file names for design
%
%   @mardo_2/design_type     - returns SPM version string corresponding to design type
%   @mardo_2/has_images      - returns 1 if design contains images
%   @mardo_2/is_valid_design - returns 1 if object contains valid SPM/MarsBaR design
%   @mardo_2/mardo_2         - mardo_2 - class constructor for SPM2 MarsBaR design object
%   @mardo_2/mardo_99        - method to convert SPM2 design to SPM99 design
%   @mardo_2/savestruct      - saves data in def_struct into .mat file with variable name SPM
%   @mardo_2/get_images      - method to get image vols from design
%   @mardo_2/estimate        - estimate method - estimates GLM for SPM2 model
%   @mardo_2/set_images      - method to set image vols to design
%
%   @mardo_2/private/my_design   - returns 1 if design looks like it is of SPM2 type
%   @mardo_2/private/pr_estimate - [Re]ML Estimation of a General Linear Model
%
%   @mardo_99/design_type     - returns SPM version string corresponding to design type
%   @mardo_99/fill_design     - fills missing entries from SPM FMRI design matrix 
%   @mardo_99/flip_images     - flips images in design
%   @mardo_99/has_fcontrasts  - returns 1 if design contains F contrast information
%   @mardo_99/has_filter      - returns 1 if object contains filter
%   @mardo_99/has_images      - returns 1 if design contains images
%   @mardo_99/is_valid_design - returns 1 if object contains valid SPM/MarsBaR design
%   @mardo_99/mardo_99        - mardo_2 - class constructor for SPM99 MarsBaR design object
%   @mardo_99/modality        - returns guessed modality of design, 'FMRI' or 'PET'
%   @mardo_99/get_images      - method to get image vols from design
%   @mardo_99/set_images      - method to set image vols from design
%   @mardo_99/estimate        - estimate method - estimates GLM for SPM99 model
%
%   @mardo_99/private/get_filter  - gets filter using spm_fmri_spm_ui routines
%   @mardo_99/private/my_design   - returns 1 if design looks like it is of SPM99 type
%   @mardo_99/private/my_fcons    - takes design, adds F contrasts
%   @mardo_99/private/pr_estimate - compute statistics for timecourses from design and data
%
%   @maroi/back2base     - back2base method - check for spacebase, transform thereto
%   @maroi/and           - overloaded add function 
%   @maroi/binarize      - binarize - returns / sets binarize value for object
%   @maroi/c_o_m         - c_o_m method - calculates unweighted centre of mass
%   @maroi/classdata     - classdata method - see private/_classdata
%   @maroi/descrip       - name - returns / sets name value for object
%   @maroi/display       - display - method 
%   @maroi/eq            - overloaded xor function 
%   @maroi/flip_lr       - flips ROI left / right
%   @maroi/ge            - overloaded xor function 
%   @maroi/getdata       - getdata method - fetches time series data for ROI from images 
%   @maroi/gt            - overloaded xor function 
%   @maroi/has_space     - has_space method - returns true if object has a native space
%   @maroi/history       - history - returns / sets history value for object
%   @maroi/label         - label - returns / sets label value for object
%   @maroi/le            - overloaded xor function 
%   @maroi/lt            - overloaded xor function 
%   @maroi/maroi         - maroi - class constructor for umbrella ROI object
%   @maroi/maroi_matrix  - maroi_matrix method - converts roi to maroi matrix type
%   @maroi/minus         - overloaded xor function 
%   @maroi/mrdivide      - overloaded xor function 
%   @maroi/mtimes        - overloaded mtimes function 
%   @maroi/native_space  - native_space method - returns native space of object
%   @maroi/ne            - overloaded ne function 
%   @maroi/not           - overloaded not function 
%   @maroi/or            - overloaded or function 
%   @maroi/paramfields   - returns struct with fields from maroi object useful for copying objects
%   @maroi/plus          - overloaded xor function 
%   @maroi/rdivide       - overloaded rdivide function 
%   @maroi/realpts       - realpts method - returns 3xN XYZ matrix in mm
%   @maroi/rle           - run length encoding method
%   @maroi/roithresh     - roithresh - returns / sets roithresh value for object
%   @maroi/save_as_image - method save_as_image - saves ROI as image
%   @maroi/save_mricro   - saves in MRIcro format
%   @maroi/saveroi       - saveroi method - checks fname, sets source field, saves object
%   @maroi/source        - source - returns / sets source value for object
%   @maroi/spm_hold      - hold - returns / sets hold value for object
%   @maroi/times         - overloaded times function 
%   @maroi/volume        - volume method - returns volume of ROI in mm
%   @maroi/xor           - overloaded xor function 
%
%   @maroi/private/my_classdata - my_classdata method - sets/gets class data
%   @maroi/private/my_loadroi   - my_loadroi function - loads ROI(s) from file, sets source field
%   @maroi/private/my_roifname  - changes fname to appropriate ROI format
%
%   @maroi_box/centre       - centre method - sets / returns centre of ROI in mm
%   @maroi_box/flip_lr      - flips ROI left / right
%   @maroi_box/is_empty_roi - is_empty_roi - returns true if ROI contains no volume
%   @maroi_box/maroi_box    - maroi_box - class constructor
%   @maroi_box/volume       - volume method - returns volume of ROI in mm
%   @maroi_box/voxpts       - voxpts method - voxels within a box in given space
%
%   @maroi_image/flip_lr      - flips ROI left / right
%   @maroi_image/loadobj      - loadobj method - reloads matrix from img file
%   @maroi_image/maroi_image  - maroi_image - class constructor
%   @maroi_image/maroi_matrix - maroi_matrix method - converts maroi_image to maroi_matrix
%   @maroi_image/saveobj      - saveobj method - removes matrix information from parent to save space
%   @maroi_image/vol          - vol - returns / sets image vol for object
%
%   @maroi_image/private/my_vol_func - checks vol and func, returns processed image matrix or error
%
%   @maroi_matrix/do_write_image - save_as_image method - saves matrix as image and returns spm_vol
%   @maroi_matrix/domaths        - helper function to do maths on matrix object
%   @maroi_matrix/flip_lr        - flips ROI left / right
%   @maroi_matrix/is_empty_roi   - is_empty_roi - returns true if ROI contains no volume
%   @maroi_matrix/loadobj        - loadobj function - undoes run length encoding if appropriate
%   @maroi_matrix/maroi_matrix   - maroi_matrix - class constructor
%   @maroi_matrix/matrixdata     - matrixdata method - gets matrix from ROI object
%   @maroi_matrix/native_space   - native_space method - returns native space of object
%   @maroi_matrix/rebase         - rebase method - returns data from maroi_matrix in new space
%   @maroi_matrix/saveobj        - saveobj function - does run length encoding if helpful
%   @maroi_matrix/spm_mat        - spm_mat method - returns mat file defining orientation etc
%   @maroi_matrix/voxpts         - voxpts method - returns 3xN ijk matrix in voxels
%
%   @maroi_matrix/private/my_rld - function to do run length decoding 
%   @maroi_matrix/private/my_rle - method to do run length encoding on matrix
%
%   @maroi_pointlist/flip_lr         - flips ROI left / right
%   @maroi_pointlist/getvals         - returns vals for pointlist object
%   @maroi_pointlist/is_empty_roi    - is_empty_roi - returns true if ROI contains no volume
%   @maroi_pointlist/loadobj         - loadobj method - creates temporary voxel block
%   @maroi_pointlist/maroi_matrix    - maroi_matrix method - converts roi to maroi matrix type
%   @maroi_pointlist/maroi_pointlist - mars_roi - class constructor
%   @maroi_pointlist/native_space    - native_space method - returns native space of object
%   @maroi_pointlist/saveobj         - saveobj method - removes temporary voxblock structure
%   @maroi_pointlist/voxpts          - voxpts method - returns 3xN ijk matrix in voxels
%
%   @maroi_pointlist/private/my_voxblock - my_voxblock function - returns voxel block and modified mat file
%
%   @maroi_shape/has_space    - has_space method - returns true if object has a native space
%   @maroi_shape/c_o_m        - c_o_m method - calculates centre of mass
%   @maroi_shape/maroi_matrix - maroi_matrix converter method for shape objects
%   @maroi_shape/maroi_shape  - maroi_shape - (virtual) shape roi class constructor
%
%   @maroi_sphere/centre       - centre method - sets / returns centre of ROI in mm
%   @maroi_sphere/flip_lr      - flips ROI left / right
%   @maroi_sphere/is_empty_roi - is_empty_roi - returns true if ROI contains no volume
%   @maroi_sphere/maroi_sphere - maroi_sphere - class constructor
%   @maroi_sphere/volume       - volume method - returns volume of ROI in mm
%   @maroi_sphere/voxpts       - voxpts method - voxels within a sphere in given space
%
%   @mars_space/display    - display - placeholder display for mars_space
%   @mars_space/eq         - overloaded eq method for mars_space objects
%   @mars_space/mars_space - mars_space - class constructor for space defining object
%   @mars_space/subsasgn   - method to over load . notation in assignments.
%   @mars_space/subsref    - method to overload the . notation.
%
%   fonct/bare_head    - returns bare header (pre mat file) mat info
%   fonct/draw         - draw function for ROI drawing tool
%   fonct/remplie      - find the index of the points within the polygon for image 
%   fonct/set_box_view - set_box_view function for ROI drawing tool
%   fonct/splatch_vol  - splatch_vol function for ROI drawing tool
%
%   init/affiche_tpos - affiche_tpos function for ROI drawing tool
%   init/initfigvol   - initialize figure for volume
%   init/mycolorbar   - display color bar (color scale) for ROI drawing tool
%   init/panel        - do panel for ROI drawing tool
%
%   spm2/mars_blob_ui - Displays SPM results, and ROI menu in SPM input window
%   spm2/mars_veropts - returns SPM version specific parameters
%
%   spm99/mars_blob_ui    - Displays SPM results, and ROI menu in SPM input window
%   spm99/mars_veropts    - returns SPM version specific parameters
%   spm99/spm_bch_DoCont  - SPM batch system: Contrast computation - disabled for MarsBar
%   spm99/spm_bch_GetCont - SPM batch system: Contrast structure creation - MarsBaR version
%   spm99/spm_get_bf      - creates basis functions for each trial type {i} in struct BF{i}
%   spm99/spm_spm         - replacement spm_spm function to trap design->estimate calls
%
%   spm_common/spm_bch_tsampl - MarsBaR replacement for spm_bch_tsampl; edits to allow SPM2 to use file
%   spm_common/spm_orthviews  - Display Orthogonal Views of a Normalized Image
