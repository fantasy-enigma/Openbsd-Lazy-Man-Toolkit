#! /bin/sh

cat key.txt | xargs -n 1 -J % rm -fv %
