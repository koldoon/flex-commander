#!/usr/bin/env bash

echo "mkdir $*" >> /tmp/cmd.log
/bin/mkdir "$@"