In this directory, you can generate WormBase annotation files for various regions using GNU make:
    `make -f c_elegans.PRJNA13758.WS267.makefile`

You have to overwrite `genome` in the makefile to indicate the path
to the reference fasta index file (.fai, typically created with `samtools faidx`)
