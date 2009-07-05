============================================
 MarsBaR region of interest toolbox for SPM
============================================

MarsBaR (MARSeille Boîte À Région d'Intérêt) is a toolbox for
`SPM`_ which provides routines for region of interest analysis.
Features include region of interest definition, combination of
regions of interest with simple algebra, extraction of data for
regions with and without SPM preprocessing (scaling, filtering), and
statistical analyses of ROI data using the SPM statistics machinery.

Reference
~~~~~~~~~
We presented an abstract to the Human Brain Mapping conference for
2002; this may be useful as a reference: `Region of interest analysis
using an SPM toolbox`_. It should apparently be cited as:
 Matthew Brett, Jean-Luc Anton, Romain Valabregue, Jean-Baptiste
Poline. Region of interest analysis using an SPM toolbox [abstract]
Presented at the 8th International Conference on Functional Mapping
of the Human Brain, June 2-6, 2002, Sendai, Japan. Available on
CD-ROM in NeuroImage, Vol 16, No 2.


MarsBaR versions
~~~~~~~~~~~~~~~~

MarsBaR releases come in two flavours: stable and development. As the
names imply, the development versions will usually be more recent,
and have more bugs. If you are starting with MarsBaR, start with the
stable version.

The current stable version is 0.41. 0.41 works with SPM99, SPM2 and
SPM5.


Download and install
~~~~~~~~~~~~~~~~~~~~

All MarsBaR releases are available via the `MarsBaR project download
page`_. For the current stable release, look for the marsbar package;
marsbar-devel is the development release. Releases consist of an
archive which will unpack in a directory named after the MarsBaR
version - for example "marsbar-0.41". You then have two options for
using MarsBaR within SPM.



1. You can add the new MarsBaR directory to your matlab path. To use
   MarsBaR, start it from the matlab prompt with the command
   "marsbar", or...

2. You could set up MarsBaR to run as an SPM toolbox. To do this, the
   contents of the new MarsBaR directory needs to be in a
   subdirectory "marsbar" of the SPM toolbox directory.
    Here is a worked example for Unix. Imagine SPM2 was in
   "/usr/local/spm/spm2", and you had just unpacked the MarsBaR
   distribution, giving you a directory "/home/myhome/marsbar-0.41".
   You could then create the marsbar SPM toolbox directory with:
   
   
   
   ::
   
   
            mkdir /usr/local/spm/spm2/toolbox/marsbar      mkdir /usr/local/spm/spm2/toolbox/marsbar
                  
      
   
   and copy the MarsBaR distribution into this directory with:
   
   ::
   
   
            cp -r /home/myhome/marsbar-0.41/* /usr/local/spm/spm2/toolbox/marsbar      cp -r /home/myhome/marsbar-0.41/* /usr/local/spm/spm2/toolbox/marsbar
                  
      
   
   Alternatively, you could do the same job by making a symbolic link
   between the directories with something like:
   
   
   
   ::
   
   
            ln -s /home/myhome/marsbar-0.41 /usr/local/spm/spm2/toolbox/marsbar      ln -s /home/myhome/marsbar-0.41 /usr/local/spm/spm2/toolbox/marsbar
                  
      
   
   


Either way, the next time you start spm you should be able to start
the toolbox by selecting 'marsbar' from the toolbox button on the SPM
interface.

For those who need the very very latest code and edits, there is also
a SourceForge `MarsBaR SVN interface`_, and instructions for using
`anonymous SVN from the command line`_.

For writing credits and some little jokes, see the marsbar.m file in
the MarsBaR release.


Documentation and help
~~~~~~~~~~~~~~~~~~~~~~
Try the MarsBaR tutorial for an introduction to the interface:
 `MarsBaR tutorial in OpenOffice format`_ 

`MarsBaR tutorial in PDF format`_ 

There is a separate tutorial for the *development version*:

`MarsBaR-devel tutorial in OpenOffice format`_ 

`MarsBaR-devel tutorial in PDF format`_ 

There is also a `MarsBaR FAQ`_.

The MarsBaR code is reasonably well documented; we export this
documentation as web pages using Guillaume Flandin's excellent
`m2html`_. This is available in the *doc* subdirectory in the main
*marsbar* directory for the devel and stable versions. It is also
available in `the doc-stable/latest`_ directory of the website, for
the stable version, and `the doc-devel/latest`_ for the development
version.

We hope it is clear how to use MarsBaR, but please let us know if you
have problems. In particular, we would be very glad to hear of any
bugs or inconsistencies.

There is a mailing list for MarsBaR; list archives and instructions
for posting are available via the `MarsBaR users mailing list`_ page.
There is also a `MarsBaR mailing list archive`_. `Gmane`_ also
provides a nice interface to `more recent MarsBaR emails`_.

Thanks,

The MarsBaR team

|SourceForge.net Logo|_ 

Last Refreshed: Thu Jul 3 00:11:28 BST 2008 





.. _`SPM`: http://www.fil.ion.ucl.ac.uk/spm
.. _`Region of interest analysis using an SPM toolbox`: http://www.mrc-cbu.cam.ac.uk/~matthew.brett/abstracts/Marsbar/marsbar_abs.html
.. _`MarsBaR project download page`: https://sourceforge.net/project/showfiles.php?group_id=76381
.. _`MarsBaR SVN interface`: http://marsbar.svn.sourceforge.net/viewvc/marsbar/trunk/marsbar
.. _`anonymous SVN from the command line`: svn.html
.. _`MarsBaR tutorial in OpenOffice format`: marsbar_tutorial.sxw
.. _`MarsBaR tutorial in PDF format`: marsbar_tutorial.pdf
.. _`MarsBaR-devel tutorial in OpenOffice format`: marsbar_devel_tutorial.sxw
.. _`MarsBaR-devel tutorial in PDF format`: marsbar_devel_tutorial.pdf
.. _`MarsBaR FAQ`: faq.html
.. _`m2html`: http://www.artefact.tk/software/matlab/m2html/
.. _`the doc-stable/latest`: http://marsbar.sourceforge.net/doc-stable/latest/
.. _`the doc-devel/latest`: http://marsbar.sourceforge.net/doc-devel/latest/
.. _`MarsBaR users mailing list`: https://lists.sourceforge.net/lists/listinfo/marsbar-users
.. _`MarsBaR mailing list archive`: https://sourceforge.net/mailarchive/forum.php?forum_id=32777
.. _`Gmane`: http://gmane.org/
.. _`more recent MarsBaR emails`: http://blog.gmane.org/gmane.comp.graphics.spm.marsbar
.. _`SourceForge.net Logo`: http://sourceforge.net
.. |SourceForge.net Logo| image:: http://sourceforge.net/sflogo.php?group_id=76381&type=2
