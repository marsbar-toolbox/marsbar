.. _download-install:

Download and install
~~~~~~~~~~~~~~~~~~~~

All MarsBaR file releases are available via the `MarsBaR project download
page`_. 

Installing MarsBaR
++++++++++++++++++

MarsBaR needs a version of SPM_, so if you don't have SPM, please
download and install that first.  MarsBaR works with SPM versions 99, 2,
5, and 8.

For the current stable release of MarsBaR, look for the marsbar package;
marsbar-devel is the development release. Releases consist of an archive
which will unpack in a directory named after the MarsBaR version - for
example ``marsbar-0.42``. You then have two options for using MarsBaR
within SPM.


1. You can add the new MarsBaR directory to your matlab path. To use
   MarsBaR, start it from the matlab prompt with the command
   "marsbar", or...

2. You could set up MarsBaR to run as an SPM toolbox. To do this, the
   contents of the new MarsBaR directory needs to be in a subdirectory
   "marsbar" of the SPM toolbox directory.  Here is a worked example for
   Unix. Imagine SPM8 was in ``/usr/local/spm/spm8``, and you had just
   unpacked the MarsBaR distribution, giving you a directory
   ``/home/myhome/marsbar-0.42``.  You could then create the marsbar SPM
   toolbox directory with::
            
      mkdir /usr/local/spm/spm8/toolbox/marsbar
   
   and copy the MarsBaR distribution into this directory with::
   
      cp -r /home/myhome/marsbar-0.42/* /usr/local/spm/spm8/toolbox/marsbar
   
   Alternatively, you could do the same job by making a symbolic link
   between the directories with something like::

      ln -s /home/myhome/marsbar-0.42 /usr/local/spm/spm8/toolbox/marsbar


Either way, the next time you start spm you should be able to start
the toolbox by selecting 'marsbar' from the toolbox button on the SPM
interface.

Other MarsBaR downloads
+++++++++++++++++++++++

.. _example-data:

Example dataset
```````````````
You may want the example dataset to try out MarsBaR, or to run the :ref:`tutorial`.

Download the dataset from the `MarsBaR project download page`_.

To install, unpack the archive in a directory you can write to. This
will give you a subdirectory like ``marsbar_example_data-0.3``, where
0.3 is the version number of the example data.

The example data are taken from an experiment described in an HBM2003
conference abstract:

  Matthew Brett, Ian Nimmo-Smith, Katja Osswald, Ed Bullmore (2003) `Model
  fitting and power in fast event related designs
  <http://cirl.berkeley.edu/mb312/abstracts/ER/er_analysis.html>`_. NeuroImage,
  19(2) Supplement 1, abstract 791

The data consist of three EPI runs, all from one subject. In each run the
subject watched a computer screen, and pressed a button when they saw a
flashing checker board. An “event” in this design is one presentation of the
flashing checker board.

We did this experiment because we were interested to see if events at fast
presentation rates give different activation levels from events that are more
widely spaced. Each run has a different presentation rate. We randomized the
times between events in each run to give an average rate of 1 event every
second in run 1, 1 event every 3 seconds for run 2, and 1 event every 10
seconds for run 3.

There are some automated pre-processing scripts for this dataset in the
MarsBaR distribution, see :ref:`tutorial-processing` for more details.

.. _aal-rois:

AAL structural ROIs
```````````````````````````
These ROIs can be useful as a standard set of anatomical definitions.

To install, download the AAL ROI archive file from the `MarsBaR project
download page`_. Unpack the archive somewhere; it will create a new
directory, called something like ``marsbar-aal-0.2``. 

The AAL ROI library contains ROIs in MarsBaR format that were
anatomically defined by hand on a single brain matched to the MNI / ICBM
templates. The ROI definitions are described in:

  Tzourio-Mazoyer N, Landeau B, Papathanassiou D, Crivello F, Etard O, Delcroix
  N, et al. (2002). Automated anatomical labelling of activations in SPM using a
  macroscopic anatomical parcellation of the MNI MRI single subject brain.
  NeuroImage 15: 273-289.

.. include:: links_names.txt
