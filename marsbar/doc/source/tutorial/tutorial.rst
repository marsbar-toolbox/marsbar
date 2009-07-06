The MarsBaR-devel tutorial
==========================

This is a short introduction to using the development version of MarsBaR, a
region of interest toolbox for SPM.  It takes the form of a guided tour,
showing the usage of MarsBaR with a standard dataset.

The tutorial assumes you have some experience using SPM
(`http://www.fil.ion.ucl.ac.uk/`_ `spm`_).

What's new in the development version?
--------------------------------------

At the moment (marsbar version 0.41) the development and stable version are the
same.

How to read this document
-------------------------

There are three threads in this tutorial.  The first and most obvious is a step
by step guide to running several standard ROI analyses.   On the way, there are
two sets of diversions.  These are interface summaries, and technical notes.
 The text for both of these is indented.  If you just want to do the tutorial,
you can skip these diversions, and come back to them later.  The interface
summaries give you more information on the range of things that MarsBaR can do;
the technical notes are more detailed explanations of the workings of MarsBaR,
which can be useful in understanding some of the more obscure parts of the
interface.

Gearing up
----------

To run all the examples in this tutorial you will need to download and install
three packages:

    MarsBaR: this tutorial uses version marsbar-devel-0.41

    the example dataset (version 0.3)

    the AAL ROI library (version 0.2)

All of these are available via links from the MarsBaR web page:
`http://marsbar.sourceforge.net`_

The web page has instructions on downloading and installing MarsBaR.   MarsBaR
needs a version of SPM, so if you don't have SPM, you will need it
(`http://www.fil.ion.ucl.ac.uk/spm`_).  This tutorial assumes you are using
SPM5, but you can run the tutorial with SPM2 or SPM99; the results will be very
similar.

For the example dataset, unpack the archive somewhere suitable.  This will give
you a directory marsbar_example_data-N, where N is the version number of the
example data (currently 0.3).  Finally, unpack the AAL ROI library somewhere;
it will create a new directory, called something like marsbar-aal-0.2. The
library contains ROIs in MarsBaR format that were anatomically defined by hand
on a single brain matched to the MNI / ICBM templates.  The ROI definitions are
described in:

Tzourio-Mazoyer N, Landeau B, Papathanassiou D, Crivello F, Etard O, Delcroix
N, et al. (2002). Automated anatomical labelling of activations in SPM using a
macroscopic anatomical parcellation of the MNI MRI single subject brain.
NeuroImage 15: 273-289.

The example dataset
-------------------

The example data are taken from an experiment described in an HBM2003
conference abstract:

Matthew Brett, Ian Nimmo-Smith, Katja Osswald, Ed Bullmore (2003) `Model
fitting and power in fast event related designs`_. NeuroImage, 19(2) Supplement
1, abstract 791

The data consist of three EPI runs, all from one subject.  In each run the
subject watched a computer screen, and pressed a button when they saw a
flashing checker board.  An “event” in this design is one presentation of the
flashing checker board.

We did this experiment because we were interested to see if events at fast
presentation rates give different activation levels from events that are more
widely spaced. Each run has a different presentation rate. We randomized the
times between events in each run to give an average rate of 1 event every
second in run 1, 1 event every 3 seconds for run 2, and 1 event every 10
seconds for run 3.

Plan of campaign
----------------

We are going to analyse the data to see if there is different activation for
fast and slow presentation rates.  ROI analysis is an obvious choice here,
because we know where the activation is likely to be – in the primary visual
cortex – but we are more interested in how much activation there will be.  So,
we will first need to define an ROI for the visual cortex, and then analyze the
data within the ROI.

In this tutorial we will cover two methods of defining an ROI: first, a
functional definition and second, an anatomical definition.

Defining a functional ROI
-------------------------

A key problem in an ROI analysis is finding the right ROI.  This is easier for
the visual cortex than for almost any other functional area, because the
location of the visual cortex is fairly well predicted by the calcarine sulcus,
in the occipital lobe, which is  easy enough to define on a structural scan.
 However, there is a moderate degree of individual variation in the size and
border of the primary visual cortex.

One approach to this problem is to use the subject's own activation pattern to
define the ROI.  We might ask the subject to do another visual task in the
scanner, and use SPM to detect the activated areas.  We find the subject's
primary visual cortex from the activation map, and use this functional ROI to
analyze other data from the same subject.  This approach has been very fruitful
for areas such as the fusiform face area, which vary a great deal in position
between subjects.

For this dataset, we are most interested in the difference between the fast
presentation rates of run 1, and the slow presentation rates of run 3.  So, we
can use an SPM analysis of run 2 to define the visual cortex, and use this as
an ROI for our analysis of run 1 and run 3.

Functional ROIs usually need independent data
---------------------------------------------

Using the recipe above, we are not using run 2 for the ROI analysis.  Because
we will use run 2 to define the ROI, if we extract data from this ROI for run
2, it will be biased to be more activated than the data from run 1 and run 3.
 Imagine that our experiment had not worked, and there was no real activation
in any of the runs.  We do an SPM analysis on run 2, and drop the threshold to
find some voxels with higher signal than others due to noise.  We define the
ROI using this noise cluster, and extract data from the ROI for this session,
and the other two sessions.  The activation signal from the ROI in run 2 will
probably appear to be higher than for the other sessions, because we selected
these voxels beforehand to have high signal for run 2.  The same argument
applies if we select the ROI from a truly activated area; the exact choice of
voxels will depend to some extent on the noise in this session, and so data
extracted from this ROI, for this session, will be biased to have high signal.

Starting the tutorial
---------------------

First you will need to run some processing on the example dataset.  After you
unpack the dataset archive, you should have four subdirectories in the main
marsbar_example_data directory.  Directories sess1, sess2 and sess3 contain the
slice-time corrected and realigned, undistorted, spatially normalized data for
the three sessions (runs) of the experiment. The rois directory contains
pre-defined regions of interest.

To run the tutorial, find where your marsbar directory is.  You can do this
from the matlab prompt with >> which marsbar . If <marsbar> is the marsbar
directory, then you should be able to see a directory called
<marsbar>/examples/batch. This batch directory contains Matlab program files to
run the preprocessing..  Change directory to  batch , and start Matlab.   From
the Matlab prompt, run the command run_preprocess.  This little script will run
smooth the images by 8mm FWHM, and run SPM models for each run.

Now start MarsBaR. If you have put or linked MarsBaR into your SPM toolbox
directory then you can start MarsBaR from the SPM interface.  Click
Toolboxes... and then marsbar.

Otherwise, make sure the MarsBaR directory is on the Matlab path,  and run the
command marsbar from the Matlab >> prompt.

The MarsBaR / SPM interface
---------------------------

Let's begin by naming the windows used by SPM and MarsBaR.  After you have
started SPM and MarsBaR, you should have the following set of windows:

Figure 1: the MarsBaR window

Then, at the top left of the screen:

Figure 2: the SPM buttons window

Underneath the SPM buttons window, at the bottom left of the screen, is:

Figure 3: the SPM input window

SPM and MarsBaR use this window to get input from you, gentle user, such as
text, numbers, or menu choices.  Usually on the right hand side of the screen,
there is:

Figure 5: the file selection window

Figure 4: the SPM graphics window

which is used to display results and other graphics.  Finally, there is:

Figure 6: the file selection window

which SPM and MarsBaR use to collect file or directory names.

The first step:  defining the ROI
---------------------------------

The preprocessing script has already run an SPM model for run 2 (and run 1 and
run 3).  Now we need to find an activation cluster in the visual cortex.

Go to the MarsBaR window, and click on ROI definition.  You should get a menu
like this:

Figure 7: ROI definition menu

Interface summary: the ROI definition menu

View displays one or ROIs on a structural image.

Draw calls up a Matlab interface for drawing ROIs.

Get SPM cluster(s) uses the SPM results interface to select and save activation
clusters as ROIs.

Build gives an interface to various methods for defining ROIs, using shapes
(boxes, spheres), activation clusters, and  binary images.

Transform offers a GUI for combining ROIs, and for flipping the orientation of
an ROI to the right or left side of the brain.

Import allows you to import all SPM activations as ROIs, or to import ROIs from
cluster images, such as those written by the SPM results interface, or from
images where ROIs are defined by number labels (ROI 1 has value 1, ROI 2 has
value 2, etc.).  Similarly Export writes ROIs as images for use in other
packages, such as MRIcro (www.mricro.com).

Defining a functional ROI
-------------------------

We are going define the functional ROI using the SPM analysis for run 2. Select
“Get SPM cluster(s)...”: from the menu. This runs the standard SPM results
interface.  Use the file selection window that SPM offers to navigate to the
sess2/SPM2_ana directory. Select the SPM.mat file and click Done. Choose the
stim_hrf t contrast from the SPM contrast manager, click Done.  Then accept all
the default answers from the interface, like this:

+-----------------------------+--------+
|Prompt                       |Response|
+-----------------------------+--------+
|mask with other contrasts:   |no      |
+-----------------------------+--------+
|title for comparison         |stim_hrf|
+-----------------------------+--------+
|p value adjustment to control|none    |
+-----------------------------+--------+
|threshold {T or p value}     |0.05    |
+-----------------------------+--------+
|& extent threshold {voxels}  |0       |
+-----------------------------+--------+


Technical note: MarsBaR and SPM designs

For the large majority of tasks, MarsBaR can use SPM designs interchangeably.
 For example, when running with SPM5, you can load SPM99 designs and estimate
them in MarsBaR; you can also estimate SPM5 designs from MarsBaR, even if you
are using  - say - SPM99.  However, MarsBaR uses the standard SPM routines for
the 'Get SPM cluster(s)' routines. This means that if, for example, you are
running SPM5 you can only get clusters from an SPM5 design and you can only get
clusters from an SPM99 design if you are running SPM99.

Now you have run the Get SPM cluster(s) interface, you should have an SPM
activation map in the graphics window:

Figure 8: SPM for run 2

Meanwhile, you may have noticed there is a new menu in the SPM input window:

Figure 9: Write ROI(s) menu

Another thing you may not have noticed is that the matlab working directory has
now changed to the sess2/SPM2_ana.  SPM2 does this to be able to keep track of
where its results files are.

Move the red arrow in the SPM graphics window to the activation cluster in the
visual cortex.  You can do this by dragging the arrow, or right-clicking to the
right of the axial view and choosing goto global maxima.

When the red arrow is in the main cluster, click on the Write ROI(s) menu in
the SPM input window and select Write one cluster.

Interface summary: Write ROI(s)

Write one cluster writes out a single cluster at the selected location; Write
all clusters writes all clusters from the SPM map; MarsBaR will ask for a
directory to save the files, and a root name for the ROI files before saving
each ROI as a separate file.  Rerun results UI restarts the SPM results
interface as if you had clicked on the SPM results button;  Clear clears the
SPM graphics window.

After you have selected Write one cluster, MarsBaR asks for details to save
with the ROI, which are a description, and a label.  Both provide information
about the ROI for statistical output and display.  The label should be 20
characters or so, the description can be longer.  For the moment, accept the
defaults, which derive from the coordinates of the voxel under the red arrow
and the title of the contrast:

+------------------+--------------------------------------+
|Prompt            |Response                              |
+------------------+--------------------------------------+
|Description of ROI|stim_hrf cluster at [-9.0 -93.0 -15.0]|
+------------------+--------------------------------------+
|Label for ROI     |stim_hrf_-9_-93_-15                   |
+------------------+--------------------------------------+


After this, MarsBaR offers a dialog box to give a filename for the ROI.  By
default the offered filename will be stim_hrf_-9_-93_-15_roi.mat in the
sess2/SPM2_ana directory.  For simplicity, why not accept the default name and
click Save to save the ROI.

Technical note: ROIs and filenames

MarsBaR stores each ROI in a separate file.  In fact, the files are in the
Matlab .mat format.   MarsBaR will accept any filename for the ROI, and can
load ROIs from any file that you have saved them to, but it will suggest that
you save the ROI with a filename that ends in _roi.mat.  This is just for
convenience, so that when you are asked to select ROIs, the MarsBaR GUI can
assume that ROI files end with this suffix.  It will probably make your life
easier if you keep to this convention.

Review the ROI
--------------

We can now  review this ROI to check if it is a good definition of the visual
cortex. Click on the ROI definition menu in the MarsBaR window, and select
 View…. Choose the ROI and click Done. Your ROI should be displayed in blue on
an average structural image:

Figure 10: the ROI view interface

Interface summary: the view utility

The view utility allows you to click around the image to review the ROI in the
standard orthogonal views.  You can select multiple ROIs to view on the same
structural.  The list box to the left of the axial view allows you to move to a
particular ROI (if you have more than one).  When the cross-hairs are in the
ROI, the information panel will show details for that ROI,  such as centre of
mass, and volume in mm.  The default structural image is the MNI 152 T1 average
brain; you can choose any image to display ROIs on by clicking on the
Options... menu in the MarsBaR window, then choosing Edit Options..., followed
by Default structural.

Refining the ROI
----------------

Now we have reviewed the ROI, we see that the cluster does include visual
cortex, but there also seems to be some connected activation lateral and
inferior to the primary visual cortex.  The cross-hairs in figure are between
the voxels which seem to be in primary visual cortex and the more lateral
voxels. Ideally we would like to restrict the ROI to voxels in the primary
visual cortex.

We can do this by defining a box ROI that covers the area we are interested in,
and combining this with the activation cluster.

Defining a box ROI
``````````````````

To decide on the box dimensions, click around the ROI in the view interface and
note the coordinates of the cross-hairs that are shown at the top of the bottom
left panel.  This may suggest to you, as it did to us, that it would be good to
restrict the ROI to between -20 and +20mm in X, -66 to -106mm in Y, and -20 to
+7mm in Z.

To define this box ROI, click on ROI definition, and choose Build..., .  You
will see a new menu in the SPM input window:

Figure 11: ROI build menu

From the menu, select Box (ranges XYZ). Answer the prompts like this:

+-------------------+----------------------------------------------+
|Prompt             |Response                                      |
+-------------------+----------------------------------------------+
|[2] Range in X (mm)|-20 20                                        |
+-------------------+----------------------------------------------+
|[2] Range in Y (mm)|-66 -106                                      |
+-------------------+----------------------------------------------+
|[2] Range in Z (mm)|-20 7                                         |
+-------------------+----------------------------------------------+
|Description of ROI |box at -20.0>X<20.0 -106.0>Y<-66.0 -20.0>Z<7.0|
+-------------------+----------------------------------------------+
|Label for ROI      |box_x_-20:20_y_-106:-66_z_-20:7               |
+-------------------+----------------------------------------------+
|Filename           |box_x_-20_20_y_-106_-66_z_-20_7_roi.mat       |
+-------------------+----------------------------------------------+


The last three values here are the defaults.

To check this is as you want it, choose ROI Definition, View, select both of
box_x_-20_20_y_-106_-66_z_-20_7_roi.mat and  stim_hrf_-9_-93_-12_roi.mat, in
that order, and click Done.  You should see the box in blue, with the
activation cluster overlaid in red.

We now need to combine the two ROIs, to select only those voxels that are
shared by the box and the activation cluster.

Combining ROIs
``````````````

Choose ROI Definition, Transform...  A new menu comes up in the SPM input
window.  Choose Combine ROIs;  select both the box and the cluster ROIs, click
on Done.  The prompt now asks for a function with which to combine the ROIs.
 In this function, the first ROI you selected is r1, and the second ROI is r2.
 Here we want to get the overlap, and this is represented by the logical AND
operator, which is “&” in Matlab.  Enter the function “r1 & r2” (without the
quotes).

Technical note: combining ROIs

You can use most mathematical functions to combine ROIs.  If you wanted to
combine two ROIs, so the new ROI has all the voxels in ROI 1 and all the voxels
in ROI2, you could use the function “r1 | r2” (read as “r1 or r2”).  If you
wanted only the voxels in ROI 1 that are not in ROI 2: “r1 & ~ r2”.  Similarly,
you can choose more than two ROIs and combine them.  The function “(r1 & r2) &
~r3” gives all the voxels in ROI 1 and ROI 2, but excluding those that are in
ROI 3.

After this, accept the default description, set the label to something like
“Trimmed stim run 2”, and save the ROI as trim_stim_roi.mat.

Writing the ROI as an image
---------------------------

Just for practice, let us write our new ROI as a binary image.  You might want
to do this so you can review the ROI using another program, such as the
excellent MRIcro (`www.mricro.com`_).  Click on ROI definition, then Export....
 Select image from the new menu in the SPM input window, and choose the new
trim_stim_roi.mat as the ROI to export.  Another menu appears, asking for a
Space for ROI image.  The three options are Base space for ROIs, From image, or
ROI native space.

Technical note: ROIs and image spaces

An ROI can be one of two fundamental types: a shape (such as a box or sphere)
or a list of points (such as an activation cluster or coordinates read in from
an ROI in an image).  Shape ROIs know nothing about such vulgarities as voxels,
they are abstract concepts waiting to be applied.  In order to display shapes,
or write them to images, or combine them with other ROIs, we need to convert
them to point lists in a certain space – with dimensions in X Y and Z, and
voxels with specified sizes.  For example, when MarsBaR combines ROIs, it needs
some default space (dimensions, voxel sizes) in which to define the new point
list ROI.  By default, this is the space of the MNI template; so the Base space
for ROIs in the menu above will be MNI space.  This is a good space to use if
you are working with spatially normalized data, but ROIs are often defined on a
subject's data before spatial normalization.  In this case, it may be more
useful to set the ROI base space to match the subject's own activation images,
using Options, Edit options from the MarsBaR window.

The issue of the ROI space comes up here, because we need to define what
dimensions and voxels we should use when writing the image.  We can either
write the image using the Base space, or we can use some arbitrary space
defined by an image, or we can get the space directly from the ROI.  Here, the
ROI is an activation cluster, and the native ROI space for an activation
cluster uses the minimum dimensions necessary to hold all the voxels in the
ROI.  An ROI image for this cluster using native space uses minimum disk
storage, but does not give a good impression of the ROI location when displayed
in, for example, MRIcro.

In our case, the data are spatially normalized, and so are in the space of the
MNI template.  The MNI template space is the default base space for ROIs, so
select Base space for ROIs, choose a directory to save the image, and accept
the default filename for the image, which should be trim_stim.  You can check
this has worked, by finding the SPM buttons window, selecting Display, and
choosing the new trim_stim.img.

Running the ROI analysis
------------------------

First, let us estimate the activation within the ROI for the first run.  There
are three stages to the analysis.

    Choosing the design

    Extracting the data

    Estimating the design model with the data

The preprocessing for the example data created an SPM model for all three EPI
runs, so we already have a design made for the first run.  We are going to use
this design and the trim_stim ROI to extract ROI data from the functional
scans.  Then we will use the design and the extracted data to estimate the
model.

Stage 1: choosing the design
````````````````````````````

Click on the Design button in the MarsBaR window. You should get a menu like
this:

Figure 12: MarsBaR design menu

Interface summary: the MarsBaR design menu

The design menu offers options for creating, reviewing, estimating and
processing SPM / MarsBaR designs.

Oddly, let us start at the end.  The Set design from file option will ask for a
design file, and load the specified design into MarsBaR.  The loaded design
then becomes the default design.  MarsBaR will from now on assume that you want
to work with this design, unless you tell it otherwise by loading a different
design.

Save design to file will save the current default design to a file.

Set design from estimated; as we will see later, when MarsBaR estimates a
design, it stores the estimated design in memory.  Sometimes it is useful to
take this estimated design and set it to be the default design, in order to be
able to use the various of these menu options to review the design.

PET models, FMRI models, and Basic models will use the SPM design routines to
make a design, and store it in memory as the default design.

Explore runs the SPM interface for reviewing and exploring designs.

Frequencies (event+data) can be useful for FMRI designs.  The option gives a
plot of the frequencies present in ROI data and the design regressors for a
particular FMRI event.  This allows you to choose a high-pass filter that will
not remove much of the frequencies in the design, but will remove low
frequencies in the data, which are usually dominated by noise.

Add images to FMRI design allows you to specify images for an FMRI design that
does not yet contain images.  SPM and MarsBaR can create FMRI designs without
images.  If you want to extract data using the design (see below), you may want
to add images to the design using this menu item.

Add/edit filter for FMRI design gives menu options for specifying high pass and
possibly (SPM99) low-pass filters, as well as autocorrelation options (SPM2).

Check images in the design looks for the images names in a design, and simply
checks if they exist on the disk, printing out a message on the matlab console
window.  A common problem in using saved SPM designs is that the images
specified in the design have since moved or deleted; this option is a useful
check to see it that has occurred.

Change path to images allows you to change the path of the image filenames
saved in the SPM design, to deal with the situation when images have moved
since the design was saved.

Convert to unsmoothed takes the image names in a design, and changes them so
that they refer to the unsmoothed version of the same images – in fact it just
removes the “s” prefix from the filenames.  This can be useful when you want to
use an SPM design that was originally run on smoothed images, but your ROI is
very precise, so you want to avoid running the ROI analysis on smoothed data,
which will blur unwanted signal into your ROI.

If you have been reading the interface summary, welcome back.  Isn't it strange
how time just seems to stop when you are reading about graphical user
interfaces?

Our plan was to choose our design.  Select the Set design from file option in
the design menu and choose the SPM.mat file in the sess1/SPM2_ana directory.
 MarsBaR loads the design into memory and displays the design matrix  in the
SPM graphics window.

Stage 2: extracting the data
````````````````````````````

Before we can run the model, we need to extract the ROI data from the
functional scans.  This brings us to the data menu:

Figure 13: the data menu

We are going to choose Extract ROI data(default), and for simple analyses this
may be all you will ever need. For those with a thirst for knowledge, here is
the

Interface summary: data menu

Extract ROI data (default) takes one or more ROI files and a design, and
extracts the data within the ROI(s) for all the images in the design.  As for
the default design, MarsBaR stores the data in memory for further use.

Extract ROI data (full options) allows you to specify any set of images to
extract data from, and will give you a full range of image scaling options for
extracting the data.

Default region is useful when you have extracted data for more than one ROI.
 In this case you may want to restrict the plotting functions (below) to look
only at one of these regions; you can set which region to use with this option.
 If you do not specify, MarsBaR will assume you want to look at all regions.

Plot data (simple) draws time course plots of the ROI data to the SPM graphics
window.  Plot data (full) has options for filtering the data with the SPM
design filter before plotting, and for other types of plots, such as Frequency
plots  or plots of autocorrelation coefficients.

Import data allows you to import data for analysis from matlab, text files or
spreadsheets.  With Export data you can export data to matlab variables, text
files or spreadsheets.

Split regions into files is useful in the situation where you have extracted
data from more than one ROI, but you want to estimate with the data from only
one of these ROIs.  This can be a good idea for SPM2 designs, because, like
SPM2, MarsBaR will pool the data from all ROIs when calculating
 autocorrelation. This may not be valid, as different brain regions can have
different levels of autocorrelation.  Split regions into files takes the
current set of data and saves the data for each ROI as a separate MarsBaR data
file.  Merge data files reverses the process, by taking a series of ROI data
files and making them into one set of data with many ROIs.

Set data from file will ask for a MarsBaR data file (default suffix
'_mdata.mat') and load it into memory as the current set of data.  Save data to
file will save the current set of data to a MarsBaR data file.

Again, welcome back to our linear readers.  For the tutorial, we want to
extract the data for our ROI, from the images in our design.  Choose Extract
ROI data(default); the GUI will ask you to select one or more ROIs files;
select the trim_stim_roi.mat file.  MarsBaR starts to whirr.  As it whirrs, it
will:

    Take each image in the design (you had already set the default design from
    the design menu);

    Extract all the data within the ROI for each image, to give voxel time
    courses for each voxel in the ROI.

When it has finished, MarsBaR will calculate a new summary time course for each
ROI.  The summary time course has one value per scan, per ROI;  by default,
this new time course is made up of the means of all the voxel values in the
ROI.  For example, if there are only 5 voxels in the ROI, the first value in
the summary time series will be the mean of the 5 voxel values for scan 1, the
second value will be the mean of the 5 voxel values for scan 2, and so on.  
You can change the method of summarizing voxel data using the Statistics, Data
summary function item in the MarsBaR options interface.

Technical note: the summary function

There are many ways to use ROI data, but the simplest approach, used by
MarsBaR, is to treat the voxel values within the region of an image as many
samples of the same signal.  So, for each image, we find the voxels that are
within the ROI, and calculate a single summary value to represent all the
voxels in the ROI.  This gives us one ROI summary value per image, and we can
run the statistical model on this time-course of summary values.

The most obvious way of summarizing the values within the ROI is to take the
mean.  This is the default in MarsBaR.  The mean can be greatly affected by
outliers.  If we suspect there may be outlier voxels in the ROI, the median may
be more robust as a summary function.  The first eigenvector is a more complex
estimate of the typical signal in the ROI, and will almost always be similar to
the mean, for standard ROI data.  It is the default for the volume of interest
utilities in SPM .  The other option offered as a summary function is the
weighted mean.  Usually ROIs are binary – meaning that they contain ones within
the ROI and zeros elsewhere.  In this case the weighted mean will be identical
to the mean.  However, it is possible to define ROIs which contain weighting
values, where high values represent high confidence that this voxel is within
the region of interest, and values near zero represent low confidence. In this
situation, it can be useful to use the ROI values to weight the mean value.

As MarsBaR extracts the data you will see its progress printed to the matlab
console.  When the extraction is done, the data is kept in memory.  You can
save the data to disk if you want using the Save data to file option on the
data menu.

Now we have the design and the data we can estimate the model.

Stage 3: estimating the model
`````````````````````````````

As the sweat pours from your brow, you click on the Results menu in the MarsBaR
window.  Scarcely believing it could be this easy, you choose the first item on
the menu, Estimate results.  It was that easy!  MarsBaR takes the default
design and the extracted data, and runs the model.  There are more progress
reports to the matlab console; finally you see the suggestion that you use the
results section for assessment.

Basic results: the statistic table
----------------------------------

Let us start the assessment by getting some t and F values for the effects in
the design.  Click on the Results button in the MarsBaR window:

Figure 14: MarsBaR results menu

Interface summary: the results menu

Estimate results, as we know, takes the default design, and the ROI data, and
estimates the model.  MarsBaR stores the estimated results in memory as the
estimated design.

Import contrasts gives an interface for you to select contrasts from other
analyses, and import them into the list of contrasts for the current analysis.

Add trial specific F will add F contrasts for each trial, and each session, if
they are not already present.

Default contrast will set one contrast as the default to use for other options
on this menu, such as the MarsBaR SPM graph plotting function.

Default region applies only if the current results are for more than one
region.  It will select one region from the data to use for analysis and plots.

Plot residuals puts up various plots of the residual errors from the model, to
check for violation of assumptions or major outliers.

MarsBaR SPM graph uses the SPM plotting functions to plot contrasts of
parameter estimates, fitted and adjusted responses, estimates of event or block
related response, and so on.

Statistic table shows various statistics for selected contrasts, as we will see
in the tutorial.

% signal change will show an estimate for the percent signal change for a
single event.  There are many assumptions for this analysis; please treat it
like you would treat your children: with a combination of great care and weary
scepticism.

Set results from file  allows you to choose the results you want to review.
 When you estimate a model in  MarsBaR, the program will automatically set the
new results to be current for the results menu.  If you want to analyze some
other set of MarsBaR results, you can use this option to select and load
another analysis file.  The default file suffix for MarsBaR estimated results
is '_mres.mat'.

Save results to file will save the current estimated results, including the
data used for the estimation, to a file on disk.

To continue with our analysis, we next need to specify a contrast.  In our case
the contrast is very simple: just a 1 in the column for the HRF regressor used
to model the visual event.  Usually the contrast will be more complicated, and
you may have already entered it for a previous SPM or MarsBaR analysis.  The
Import contrasts option allows you to get contrasts from a previous analysis.
To show how it works, click on this option.  The SPM file selection window
should appear.  Navigate to the sess1/SPM2_ ana directory, and select the
SPM.mat file there.  The SPM contrast manager comes up, showing all the F and t
contrasts in the SPM.mat file.  Select the stim_hrf t contrast, and click Done.
 MarsBaR will put this contrast into the current estimated design.  Here we
only selected one contrast, but you can select many contrasts by dragging the
mouse, shift clicking etc. (depending on your system).

Now click on the Statistic table option in the MarsBaR results menu.  Select
the stim_hrf contrast and click Done.  The results will print out in a rather
ugly fashion in the Matlab window.  You might want to enlarge your Matlab
window to stop the text wrapping in an annoying way.  Here is the output on my
machine:

Figure 15: statistics table output for t contrast

At the left you see the contrast name.  Under this, and to the right, MarsBaR
has printed the ROI label that you entered a while ago.  The t statistic is
self explanatory, and the uncorrected p value is just the one-tailed p value
for this t statistic given the degrees of freedom for the analysis.  The
corrected p is the uncorrected p value, with a Bonferroni correction for the
number of regions in the analysis.  In this case, we only analyzed one region,
so the corrected p value is the same as the uncorrected p value.  MarsBaR (like
SPM), will not attempt to correct the p value for the number of contrasts,
because the contrasts may not be orthogonal, and this will make a Bonferroni
correction too conservative.

There is also a column called Contrast value.  For a t statistic, as here, this
value is an effect size.  Remember that a t statistic consists of an effect
size, divided by the standard deviation of this effect.  Here our contrast is
very simple, containing only a single 1, so the contrast value is the same as
the value of the first parameter in the model.  The value of this parameter
will be the best-fitting slope of the line relating the height of the HRF
regressor to the FMRI signal.  This effect size measure is the number that SPM
stores for each voxel in the con_0001.img, con_0002.img ... series, and these
are the values that are used for standard second level / random effect
analyses.

Just for practice, let us also run an F contrast.  Click Statistic table again,
choose the effects of interest contrast, click Done:

Figure 16: statistics table output for F contrast

Now the Contrast value has become the Extra SS.   This is a measure of the
variance that would be added to a model that does not contain the effects in
the contrast.   The F statistic is this measure, adjusted for the number of
effects, and divided by the residual variance for the whole model.  There is
 no simple way of using this Extra SS value in second level analyses.

Comparing fast and slow events – the difference between run 1 and run 3
-----------------------------------------------------------------------

Our results so far show that there is indeed a highly significant effect of
visual stimulation on the visual cortex, even for very frequent events.  This
is not a Nature paper so far.  To make things a bit more interesting, we can
compare this effect, from run 1, with the effect in run 3, for which the events
were much less frequent.

Click on Design in the MarsBaR window, then Set design from file.  Choose
SPM.mat from sess3/SPM2_ana.  Now we need to extract the data; select Extract
ROI data (default) from the data menu.  MarsBaR will ask you if you want to
save the previous data.  Why not say 'no' for the moment.  Next choose
 trim_stim_roi.mat again.  When that is done, run Estimate results from the
Results menu.  Again choose 'no' when asked if you want to save the previous
estimated design.

Technical note: directories and saving results

MarsBaR, unlike SPM, does not need a new directory for each new set of results.
 Designs, results and data are kept in memory until you save them, and you can
save them with any filename.  This means you can keep many sets of results in
the same directory.

When the estimation has finished, click on Results, Statistic table.  Next you
need to enter the HRF contrast.  Earlier, we imported the HRF column contrast
from an SPM model.  To save time, why not enter this contrast directly using
the contrast manager; it is just a t statistic with a single 1 in the first
column:

Figure 17: the stim_hrf contrast

In the end, you get a new statistic table:

Figure 18: statistic table for run 3

You can see that the contrast value – which is proportional to the change in
signal for a single event – is greater for run 3 than for run 1.  Despite this,
the t statistic for run 3 is lower than for run 1.  One explanation for this is
that there are many more events in run 1, so the estimate of signal change per
event is more reliable (has less variance).

Using a structural ROI
----------------------

So far we have used a functional ROI.  This has the advantage that it is
usually well tuned to the subject we are analysing.  The disadvantages are that
we have had to use a whole run of data to define the ROI, which we would have
preferred to be able to analyze, and that functional ROIs can be noisy, when
the activation signal is not strong.  An alternative is to use the anatomy of
the brain to estimate the location of functional areas.

Using anatomical ROIs can work well for areas that are naturally defined by
brain structure, such as the subcortical nuclei, or the primary sensory and
motor cortices, where the functional areas are closely linked to the position
of large and relatively invariant sulci.  Outside these areas, it can be
difficult to define functional areas using anatomy alone.  The problems are
compounded when anatomical ROIs are defined on one subject, and applied to
another, because there is  great variability between subject in sulcal anatomy.

In the example experiment, subjects responded with a key-press each time they
saw the flashing checker board.  We might therefore be interested to know the
level of activation in the putamen.   This would be a good candidate for an
anatomical ROI, because the putamen can be accurately defined on a structural
scan, and does not vary much between subjects after spatial normalization.  The
AAL ROI library contains a definition of the left and right putamen for a
single subject after spatial normalization.  The images from our subject have
been spatially normalized, so the AAL definition of the putamen will probably
give a reasonable approximation to the putamen in our data.

Running an analysis using structural ROIs
-----------------------------------------

is exactly the same as running the analysis with the functional ROI.  Select
Design from the MarsBaR menu, and  Set design from file.  Choose
sess1/SPM2_ana/SPM.mat.   Click on Data, Extract ROI data (default).  When you
are asked for ROI file, navigate to the AAL directory, select MNI_
Putamen_L_roi.mat and click Done.  When the data extraction is done, choose
Results, Estimate results and wait till MarsBaR has done its thing.  Select
Results,  Statistic table, enter the stim_hrf contrast, as shown in , above.
 Repeat the same procedure, using the AAL  MNI_ Putamen_R_roi.mat ROI.  You
will now have two tables like these:

Figure 19: statistics table for left putamen, run 1

Figure 20: statistics table for right putamen, run 1

The subject responded with their right hand, so we expected that the right
putamen would have less signal than the left.

Batch mode
==========

You can also run MarsBaR in batch mode.  There is an example batch script in
the <marsbar>example/batch directory, called run_tutorial.m.  You won't be
suprised to hear that this is a batch script that runs most of the steps in
this tutorial, as well as extracting and plotting reconstructed event time
courses.

The end
=======

That is the end of this short guided tour.  We haven't described the options
interface, but then again, it isn't very interesting. As always, we would be
very grateful to hear about any mistakes in this document or bugs in MarsBaR.
You can find us on the MarsBaR mailing list, via the MarsBaR home page.

May your regions always be as interesting as you hoped.

The MarsBaRistas

.. _`model fitting and power in fast event related designs`:
    http://cirl.berkeley.edu/mb312/abstracts/ER/er_analysis.html

.. _`http://www.fil.ion.ucl.ac.uk/spm`:
    http://www.fil.ion.ucl.ac.uk/spm

.. _`http://www.fil.ion.ucl.ac.uk/`:
    http://www.fil.ion.ucl.ac.uk/spm

.. _`http://marsbar.sourceforge.net`:
    http://marsbar.sourceforge.net/

.. _`spm`:
    http://www.fil.ion.ucl.ac.uk/spm

.. _`www.mricro.com`:
    http://www.mricro.com/
