
Using a structural ROI
----------------------

So far we have used a functional ROI. This has the advantage that it is
usually well tuned to the subject we are analysing. The disadvantages are that
we have had to use a whole run of data to define the ROI, which we would have
preferred to be able to analyze, and that functional ROIs can be noisy, when
the activation signal is not strong. An alternative is to use the anatomy of
the brain to estimate the location of functional areas.

Using anatomical ROIs can work well for areas that are naturally defined by
brain structure, such as the subcortical nuclei, or the primary sensory and
motor cortices, where the functional areas are closely linked to the position
of large and relatively invariant sulci. Outside these areas, it can be
difficult to define functional areas using anatomy alone. The problems are
compounded when anatomical ROIs are defined on one subject, and applied to
another, because there is great variability between subject in sulcal anatomy.

In the example experiment, subjects responded with a key-press each time
they saw the flashing checker board. We might therefore be interested to
know the level of activation in the putamen.  This would be a good
candidate for an anatomical ROI, because the putamen can be accurately
defined on a structural scan, and does not vary much between subjects
after spatial normalization. The AAL ROI library contains a definition
of the left and right putamen for a single subject after spatial
normalization. The images from our subject have been spatially
normalized, so the :ref:`aal-rois` definition of the putamen will
probably give a reasonable approximation to the putamen in our data.

Running an analysis using structural ROIs
-----------------------------------------

is exactly the same as running the analysis with the functional
ROI. Select Design from the MarsBaR menu, and *Set design from
file*. Choose ``sess1/SPM8_ana/SPM.mat``.  Click on Data, *Extract ROI
data (default)*. When you are asked for ROI file, navigate to the
MarsBaR :ref:`example-data` directory, then to the ``rois``
subdirectory, select ``MNI_Putamen_L_roi.mat`` and click Done. This is a
copy of one of the :ref:`aal-rois`.  When the data extraction is done,
choose Results, *Estimate results* and wait till MarsBaR has done its
thing. Select Results, *Statistic table*, enter the ``stim_hrf``
contrast, as shown in the figure above.  Repeat the same procedure,
using the copy of the AAL ``MNI_Putamen_R_roi.mat`` ROI. You will now
have two tables.  

One table for the left putamen:

::

   Contrast name    ROI name: Contrast value:    t statistic:  Uncorrected P:    Corrected P
   -----------------------------------------------------------------------------------------

   stim_hrf
   ---------------------------

                   Putamen_L:           0.09:           0.86:       0.194983:       0.194983

and one for the right putamen:

::

   Contrast name    ROI name: Contrast value:    t statistic:  Uncorrected P:    Corrected P
   -----------------------------------------------------------------------------------------

   stim_hrf
   ---------------------------

                   Putamen_R:           0.05:           0.58:       0.281891:       0.281891

The subject responded with their right hand, so we expected that the right
putamen would have less signal than the left.

Batch mode
----------

You can also run MarsBaR in batch mode. There is an example batch script
in the ``<marsbar>example/batch`` directory, called
``run_tutorial.m``. You won't be suprised to hear that this is a batch
script that runs most of the steps in this tutorial, as well as
extracting and plotting reconstructed event time courses.

The end
-------

That is the end of this short guided tour. We haven't described the options
interface, but then again, it isn't very interesting. As always, we would be
very grateful to hear about any mistakes in this document or bugs in MarsBaR.
You can find us on the MarsBaR mailing list - see :ref:`support`.

May your regions always be as interesting as you hoped.

*The MarsBaRistas*


