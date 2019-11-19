#!/bin/bash
## Convert WormBase transcript names into gene symbols

DICT="/glusterfs/hisakatha/wormbase/c_elegans.PRJNA13758.WS267.xrefs.txt.gz"

declare -A geneName

while read LINE
do
    arr=($LINE)
    name=${arr[3]}
    symbol=${arr[2]}
    if [[ ${geneName[$name]+isDefined} ]]; then
        #echo "Found duplicates"
        if [[ "${geneName[$name]}" != "$symbol" ]]; then
            echo "Invalid mapping for $name: old -> ${geneName[$name]}, new -> $symbol"
            exit 1
        fi
    else
        geneName[$name]=$symbol
    fi
done < <(zcat $DICT | grep -v '^/')

INPUT="$1"
cat "$INPUT" | while read LINE
do
    if [[ -n $LINE ]]; then
        #echo ${geneName[$LINE]:-_NA_} $LINE
        SYMBOL_IFANY=${geneName[$LINE]:-.}
        if [[ $SYMBOL_IFANY == "." ]]; then
            echo $LINE
        else
            echo $SYMBOL_IFANY
        fi
    else
        echo
    fi
done #> $INPUT.symbol

#cat $INPUT.symbol | sort -V | uniq > $INPUT.symbol.uniq
