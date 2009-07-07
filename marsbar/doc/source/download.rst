.. _download-install:

Download and install
~~~~~~~~~~~~~~~~~~~~

All MarsBaR releases are available via the `MarsBaR project download
page`_. For the current stable release, look for the marsbar package;
marsbar-devel is the development release. Releases consist of an archive
which will unpack in a directory named after the MarsBaR version - for
example ``marsbar-0.41``. You then have two options for using MarsBaR
within SPM.


1. You can add the new MarsBaR directory to your matlab path. To use
   MarsBaR, start it from the matlab prompt with the command
   "marsbar", or...

2. You could set up MarsBaR to run as an SPM toolbox. To do this, the
   contents of the new MarsBaR directory needs to be in a subdirectory
   "marsbar" of the SPM toolbox directory.  Here is a worked example for
   Unix. Imagine SPM2 was in ``/usr/local/spm/spm2``, and you had just
   unpacked the MarsBaR distribution, giving you a directory
   ``/home/myhome/marsbar-0.41``.  You could then create the marsbar SPM
   toolbox directory with::
            
      mkdir /usr/local/spm/spm2/toolbox/marsbar
   
   and copy the MarsBaR distribution into this directory with::
   
      cp -r /home/myhome/marsbar-0.41/* /usr/local/spm/spm2/toolbox/marsbar
   
   Alternatively, you could do the same job by making a symbolic link
   between the directories with something like::

      ln -s /home/myhome/marsbar-0.41 /usr/local/spm/spm2/toolbox/marsbar


Either way, the next time you start spm you should be able to start
the toolbox by selecting 'marsbar' from the toolbox button on the SPM
interface.

.. include:: links_names.txt
