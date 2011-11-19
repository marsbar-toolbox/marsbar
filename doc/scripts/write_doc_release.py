#!/bin/env/python
""" Write documentation archive for release """

import os
from os.path import abspath
import sys
import re
from functools import partial
import subprocess

caller = partial(subprocess.call, shell=True)


def get_version(code_dir):
    ver_re = re.compile(" *MBver = '([0-9.]+)';")
    fname = os.path.join(code_dir, 'marsbar.m')
    for line in open(fname):
        m = ver_re.match(line)
        if m:
            return m.groups()[0]
    raise RuntimeError('Did not find version')


if __name__ == '__main__':
    try:
        release_dir = sys.argv[1]
    except IndexError:
        raise OSError('Expecting built doc directory as first argument')
    release_dir = abspath(release_dir)
    try:
        code_dir = sys.argv[2]
    except IndexError:
        raise OSError('Expecting code directory as second argument')
    code_dir = abspath(code_dir)
    try:
        archive_dir = sys.argv[3]
    except IndexError:
        pass
    else:
        os.chdir(archive_dir)
    ver = get_version(code_dir)
    froot = 'marsbar-doc-%s' % ver
    caller('ln -s %s %s' % (release_dir, froot))
    caller('zip -r %s.zip %s' % (froot, froot))
    os.unlink(froot)
