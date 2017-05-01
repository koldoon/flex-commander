#!/bin/bash

commands=( mv rm mkdir rmdir cp du ls rsync test open stat )

for cmd in "${commands[@]}"
do
    ln -s `whereis $cmd` $cmd
done