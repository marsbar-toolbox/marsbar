=================
 Getting started
=================

How to read the tutorial
------------------------

There are three threads in this tutorial. The first and most obvious is
a step by step guide to running several standard ROI analyses.  On the
way, there are two sets of diversions. These are *interface summaries*,
and *technical notes*. Interface summaries look like this:

.. admonition:: An interface summary
   :class: interfacenote note

   with some interface description

and technical notes look like this:

.. admonition:: A technical note
   :class: technote note

   with some technical notes

If you just want to do the step-by-step tutorial, you can skip these
diversions, and come back to them later. The interface summaries give
you information on the range of things that MarsBaR can do; the
technical notes are detailed explanations of the workings of MarsBaR,
which can be useful in understanding the obscure parts of the
interface.

Gearing up
----------

To run all the examples in this tutorial you will need to download and install
two packages:

#. MarsBaR: this tutorial uses version marsbar-0.42
#. the example dataset (version 0.3)

To install these packages, see :ref:`download-install`

This tutorial assumes you are using SPM8, but you can run the tutorial
with SPM versions 99, 2 or 5; the results will be very similar.


Plan of campaign
----------------

The :ref:`example-data` is from an experiment with three EPI runs of
flashing checkerboard events.  The first run was at a high presentation
rate (average 1 per second), run 2 was at a medium rate (average 1 every
3 seconds) and run 3 was slow (1 every 10 seconds on average).

We are going to analyse the data to see if there is different activation for
fast and slow presentation rates. ROI analysis is an obvious choice here,
because we know where the activation is likely to be – in the primary visual
cortex – but we are more interested in how much activation there will be. So,
we will first need to define an ROI for the visual cortex, and then analyze the
data within the ROI.

In this tutorial we will cover two methods of defining an ROI: first, a
functional definition and second, an anatomical definition.

Defining a functional ROI
-------------------------

A key problem in an ROI analysis is finding the right ROI. This is easier for
the visual cortex than for almost any other functional area, because the
location of the visual cortex is fairly well predicted by the calcarine sulcus,
in the occipital lobe, which is easy enough to define on a structural scan.
However, there is a moderate degree of individual variation in the size and
border of the primary visual cortex.

One approach to this problem is to use the subject's own activation pattern to
define the ROI. We might ask the subject to do another visual task in the
scanner, and use SPM to detect the activated areas. We find the subject's
primary visual cortex from the activation map, and use this functional ROI to
analyze other data from the same subject. This approach has been very fruitful
for areas such as the fusiform face area, which vary a great deal in position
between subjects.

For this dataset, we are most interested in the difference between the fast
presentation rates of run 1, and the slow presentation rates of run 3. So, we
can use an SPM analysis of run 2 to define the visual cortex, and use this as
an ROI for our analysis of run 1 and run 3.

Functional ROIs usually need independent data
---------------------------------------------

Using the recipe above, we are not using run 2 for the ROI analysis. Because
we will use run 2 to define the ROI, if we extract data from this ROI for run
2, it will be biased to be more activated than the data from run 1 and run 3.
Imagine that our experiment had not worked, and there was no real activation
in any of the runs. We do an SPM analysis on run 2, and drop the threshold to
find some voxels with higher signal than others due to noise. We define the
ROI using this noise cluster, and extract data from the ROI for this session,
and the other two sessions. The activation signal from the ROI in run 2 will
probably appear to be higher than for the other sessions, because we selected
these voxels beforehand to have high signal for run 2. The same argument
applies if we select the ROI from a truly activated area; the exact choice of
voxels will depend to some extent on the noise in this session, and so data
extracted from this ROI, for this session, will be biased to have high signal.

.. _tutorial-processing:

Starting the tutorial
---------------------

First you will need to run some processing on the example dataset. After
you unpack the dataset archive, you should have four subdirectories in
the main ``marsbar_example_data`` directory. Directories ``sess1``,
``sess2`` and ``sess3`` contain the slice-time corrected and realigned,
undistorted, spatially normalized data for the three sessions (runs) of
the experiment. The ``rois`` directory contains pre-defined regions of
interest.

To run the tutorial, find where your marsbar directory is. You can do
this from the matlab prompt with ``>> which marsbar`` . If ``<marsbar>``
is the marsbar directory, then you should be able to see a directory
called ``<marsbar>/examples/batch``. This ``batch`` subdirectory contains
Matlab program files to run the preprocessing. Change directory to
``batch``, and start Matlab.  From the Matlab prompt, run the command
``run_preprocess``. This little script will smooth the images by 8mm
FWHM, and run SPM models for each run.

Now start MarsBaR. If you have put or linked MarsBaR into your SPM toolbox
directory then you can start MarsBaR from the SPM interface. Click
Toolboxes... and then marsbar.

Otherwise, make sure the MarsBaR directory is on the Matlab path, and run the
command marsbar from the Matlab ``>>`` prompt.

.. include:: ../links_names.txt
