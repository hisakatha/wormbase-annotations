#!/bin/bash
FILE=$1
cat $FILE | sed -e "s/MtDNA/M/" -e "s/CHROMOSOME_/chr/" > $FILE.ucsc_chr
