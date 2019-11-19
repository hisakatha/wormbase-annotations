#!/bin/bash
FILE=$1
NAME=$2
cat $FILE | awk 'BEGIN{id=0} $0!~/^#/{id++; print $0 ";ID=" id}' | sed -e "s/MtDNA/M/" -e "s/CHROMOSOME_/chr/" -e "1i\track name=$NAME description=$NAME" > $FILE.ucsc
