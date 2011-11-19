#!/usr/bin/env python

import os
import sys
import re


def get_version(release_dir):
    ver_re = re.compile(" *MBver = '([0-9.]+)';")
    fname = os.path.join(release_dir, 'marsbar.m')
    for line in open(fname):
        m = ver_re.match(line)
        if m:
            return m.groups()[0]
    raise RuntimeError('Did not find version')


if __name__ == '__main__':
    try:
        release_dir = sys.argv[1]
    except IndexError:
        raise OSError('Expecting directory as argument')
    print get_version(release_dir)
