#! /bin/bash

# match all .emacs files
ls -a|perl -ne 'print if /^\.emacs/'|xargs -I % ln -s `pwd`/% ~/
