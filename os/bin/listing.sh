#!/usr/bin/env bash

/usr/bin/env DYLD_LIBRARY_PATH="." ./gfind "$@" -maxdepth 1 -mindepth 1 -printf '%y\t%Y\t%M\t%s\t%T@\t%f\t%l\n'