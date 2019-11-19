#!/bin/bash
## Convert WormBase transcript names into gene symbols

DICT="/glusterfs/hisakatha/wormbase/c_elegans.PRJNA13758.WS267.xrefs.txt.gz"

declare -A geneName

while read LINE
do
    arr=($LINE)
    name=${arr[3]}
    #symbol=${arr[2]}
    gene=${arr[0]}
    if [[ ${geneName[$name]+isDefined} ]]; then
        #echo "Found duplicates"
        if [[ "${geneName[$name]}" != "$gene" ]]; then
            echo "Invalid mapping for $name: old -> ${geneName[$name]}, new -> $gene"
            exit 1
        fi
    else
        geneName[$name]=$gene
    fi
done < <(zcat $DICT | grep -v '^/')

INPUT="$1"
cat $INPUT | while read LINE
do
    if [[ -n $LINE ]]; then
        #echo ${geneName[$LINE]:-_NA_} $LINE
        GENE_IFANY=${geneName[$LINE]:-.}
        if [[ $GENE_IFANY == "." ]]; then
            echo "Cannot find a gene corresponding to $LINE"
            exit 1
        else
            echo $GENE_IFANY
        fi
    else
        echo
    fi
done #| sort -V | uniq > $INPUT.symbol.uniq
