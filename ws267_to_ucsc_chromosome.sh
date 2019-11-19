#!/bin/bash
FILE=$1
cat $FILE | sed -e "s/^MtDNA/M/" | sed -E 's/^([^#])/chr\1/'
