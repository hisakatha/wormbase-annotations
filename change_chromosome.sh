#!/bin/bash

FILE=$1
cat $FILE | sed -E 's/^([^#])/CHROMOSOME_\1/'
