#!/bin/bash

cat "$@" | awk -F "\t" '$3 == "CDS"'
