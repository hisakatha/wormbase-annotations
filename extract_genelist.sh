#!/bin/bash

cat "$@" | awk '$3 == "gene"' | sed -n -E "s/.*ID=Gene:([-_a-zA-Z0-9\.]+).*/\1/p"
