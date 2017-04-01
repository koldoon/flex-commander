#!/usr/bin/env bash

echo "cp $*" >> /tmp/cmd.log
/bin/cp "$@"