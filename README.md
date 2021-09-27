# Marsbar

This is the Marsbar repository.

Please see: <http://matthew-brett.github.io/marsbar> for documentation,
and <http://github.com/matthew-brett/marsbar> for the code.

## Tests

To run the tests from the development repository, don\'t forget:

    git submodule init
    git submodule update

to get the testing code.

Then make sure:

*   SPM is on the Matlab path
*   `/path/to/marsbar-repo/testing` is on the Matlab path

Finally, in Matlab:

```
run_tests tests
```

from the repository home directory (the directory containing sub-directories
`testing` and `marsbar` and `marsbar_example_data`).

## Data

There is a `marsbar_example_data` sub-directory, but this is only to store
a few smaller files that will go into the Marsbar data package. To reconstruct
the Marsbar example data, download and unpack the current Marsbar example data
somewhere (outside the repository working tree), copy the
`marsbar_example_data` files into this tree, bump the version number in the
directory name of the example data, and re-release.
