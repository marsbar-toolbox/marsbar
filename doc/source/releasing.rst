##############
How to release
##############

* Download and unpack the marsbar example data to some directory, e.g.
  ``~/data/marbar_example_data-0.3``.
* Change directory in marsbar git repository
* Start matlab with SPM on the path
* Run tests with::

    >> test
    >> data_test

  The second of these will ask for the location of the data directory above
* Do this for as many versions of matlab and SPM as possible.
* Review the documentation
* Review and update the release notes.  Review and update the :file:`Changelog`
  file.  Get a partial list of contributors with something like::

      git log v0.42.. | grep '^Author' | cut -d' ' -f 2- | sort | uniq

  where ``v0.42`` was the last release tag name.

  Then manually go over the *git log* to make sure the release notes are
  as complete as possible and that every contributor was recognized.
* Bump the version number in marsbar.m and ``doc/source/conf.py``; commit
* Run the pre release script in ``<marsbar>/marsbar/release/pre_release.m``.

    >> pre_release

  This is the code archive
* Run the doc scripts::

    cd doc
    make dist
    make release-doc

* Upload to the file release directories
* Upload the web documentation
* Tag the release commit
* Announce


