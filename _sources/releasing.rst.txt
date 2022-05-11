##############
How to release
##############

* Download and unpack the marsbar example data to some directory, e.g.
  ``~/data/marbar_example_data-0.3``.
* Set the environment variable with something like::

    export MARSBAR_EG_DATAPATH=$HOME/data/marsbar_example_data-0.3

* Change directory to the marsbar git repository root directory (containing
  ``test.m`` file);
* Make sure you have the ``testing`` submodule updated with ``git submodule
  update --init``.
* Start Matlab with SPM on the path (marsbar gets appended automatically);
* Run tests with::

    >> test
    >> data_test

  The second of these will ask for the location of the data directory above if
  you have not set it with the environment variable ``MARSBAR_EG_DATAPATH``.
  ``data_test`` runs the preprocessing batch scripts and checks the results
  estimated in SPM against the results estimated in marsbar;
* Do this for as many versions of Matlab and SPM as possible;
* Review the documentation;
* Review and update the release notes.  Review and update the :file:`Changelog`
  file.  Get a partial list of contributors with something like::

      git log v0.42.. | grep '^Author' | cut -d' ' -f 2- | sort | uniq

  where ``v0.42`` was the last release tag name.

  Then manually go over the *git log* to make sure the release notes are
  as complete as possible and that every contributor was recognized.
* Bump the version number in ``marsbar.m`` and ``doc/source/conf.py``; commit;
* Run the pre release script in ``<marsbar>/marsbar/release/pre_release.m``::

    mkdir dist
    cd dist
    matlab
    >> addpath ../marsbar
    >> addpath ../marsbar/release
    >> pre_release

  This creates the marsbar code archives (``.tar.gz``, ``.zip``) in the current
  working directory (by default);
* Check you have a copy of the `m2html
  <http://www.artefact.tk/software/matlab/m2html>`_ scripts on your default
  Matlab path;
* Run the doc scripts to build the documentation (these depend on ``m2html``)::

    cd doc
    make clean
    make doc-release

* Do the full Monty with::

    make clean
    make github-pages

  This should upload the web documentation;
* Upload source code to the file release directories;
* Tag the release commit;
* Announce.
