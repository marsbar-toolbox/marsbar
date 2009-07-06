=====================================
 MarsBaR anonymous subversion access
=====================================

This document gives a brief overview of how to access the MarsBaR code
using anonymous (readonly) subversion.  If you want write access, please
do contact us and let us know.

If you just want to browse the code, try the SourceForge `MarsBaR SVN interface`_.


If you're already familiar with subversion
++++++++++++++++++++++++++++++++++++++++++

::

   svn co https://marsbar.svn.sourceforge.net/svnroot/marsbar/trunk/marsbar

to check out the marsbar development code, and::

   svn co https://marsbar.svn.sourceforge.net/svnroot/marsbar

to checkout everything, including example data directories and
various branches. 

If you are new to subversion
++++++++++++++++++++++++++++

Please check out the `Subversion book <http://svnbook.red-bean.com>`_.
In particular you might like to pick up the basic usage and quickstart
guidelines.  See the `subversion home page
<http://subversion.tigris.org>`_ for links to download subversion
clients for your platform.  `Tortoise SVN <http://tortoisesvn.net>`_ is
popular on Windows. Finally, you may want to look at the sourceforge
`SVN client configuration instructions`_.

Once you have a svn client program, you can check out the current
development code. To do this, use the svn command *checkout* or its
abbreviation *co*:: 

   svn co https://svn.sourceforge.net/svnroot/marsbar/trunk/marsbar
   
Once you've checked out the code you can easily update it from time
to time. Go to the newly created directory and type:: 

   svn update
   
All information about the repository, login, module and branch is
stored by subversion in the subdirectories``.svn`` so that you don't
have to care about this any more. You can move the checked out source
around, you can even move it to another machine without loosing the
ability to do a ``svn update``. 

.. _`Subversion guided tour`: http://svnbook.red-bean.com/en/1.1/ch03.html
.. _`appropriate SVN client for your platform`: /docs/B01/en/#svn_client
.. _`SVN client configuration instructions`: https://sourceforge.net/apps/trac/sourceforge/wiki/Subversion%20client%20instructions

.. include:: ../links_names.txt
