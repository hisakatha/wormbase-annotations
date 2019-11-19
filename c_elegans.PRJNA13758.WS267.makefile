annot_orig := c_elegans.PRJNA13758.WS267.annotations.gff3.gz
annot := $(annot_orig).ucsc_chr

regions := $(annot).intron $(annot).exon $(annot).ncrna $(annot).three_prime_utr $(annot).five_prime_utr $(annot).pseudogene $(annot).pseudogene_exon $(annot).promoter $(annot).enhancer \
		  $(annot).gene_structures $(annot).gene $(annot).gene_structures_all $(annot).tandem_repeat
sorted = $(annot).intron.sorted $(annot).exon.sorted $(annot).ncrna.sorted $(annot).three_prime_utr.sorted $(annot).five_prime_utr.sorted $(annot).pseudogene.sorted $(annot).pseudogene_exon.sorted \
		 $(annot).promoter.sorted $(annot).enhancer.sorted $(annot).tandem_repeat.sorted \
		 $(tss_up500).sorted $(tss_down500).sorted $(tts_up500).sorted $(tts_down500).sorted
gff := $(annot).intron.gff $(annot).exon.gff $(annot).ncrna.gff $(annot).three_prime_utr.gff $(annot).five_prime_utr.gff $(annot).pseudogene.gff $(annot).pseudogene_exon.gff \
	  $(annot).promoter.gff $(annot).enhancer.gff $(annot).gene_structures.gff $(annot).gene_structures_all.gff $(annot).tandem_repeat.gff
gff_sorted_gz := $(gff:=.sorted.gz)
gff_tbi := $(gff_sorted_gz:=.tbi)
merged = $(annot).intron.sorted.merged $(annot).exon.sorted.merged $(annot).ncrna.sorted.merged $(annot).three_prime_utr.sorted.merged $(annot).five_prime_utr.sorted.merged \
		 $(annot).pseudogene.sorted.merged $(annot).pseudogene_exon.sorted.merged $(annot).promoter.sorted.merged $(annot).enhancer.sorted.merged \
		 $(tss_up500).sorted.merged $(tss_down500).sorted.merged $(tts_up500).sorted.merged $(tts_down500).sorted.merged
merged_without_strand := $(annot).tandem_repeat.sorted.merged
names := $(annot).intron.sorted.names $(annot).exon.sorted.names $(annot).ncrna.sorted.names $(annot).three_prime_utr.sorted.names $(annot).five_prime_utr.sorted.names
names2 := $(annot).promoter.sorted.names $(annot).enhancer.sorted.names
symbol := $(annot).intron.sorted.names.symbol $(annot).exon.sorted.names.symbol $(annot).ncrna.sorted.names.symbol $(annot).three_prime_utr.sorted.names.symbol $(annot).five_prime_utr.sorted.names.symbol
gene := $(annot).intron.sorted.names.gene $(annot).exon.sorted.names.gene $(annot).ncrna.sorted.names.gene $(annot).three_prime_utr.sorted.names.gene $(annot).five_prime_utr.sorted.names.gene
gene_pseudo := $(annot).pseudogene.sorted.names.gene
gene_pseudo_exon := $(annot).pseudogene_exon.sorted.names.gene
tss_up500 := $(annot).tss_up500
tss_down500 := $(annot).tss_down500
tts_up500 := $(annot).tts_up500
tts_down500 := $(annot).tts_down500
flanks := $(tss_up500) $(tss_down500) $(tts_up500) $(tts_down500)
uniq_genes := $(annot).uniq_genes.intron_exon_tts_down500
tr_stats := $(annot).tandem_repeat.stats.pdf

genome := /glusterfs/hisakatha/ce11rel606/ce11rel606.fa.fai
genome_bed := ce11rel606.bed

targets := $(annot) $(regions) $(sorted) $(gff) $(merged) $(merged_without_strand) $(annot).intron_outside_exon $(names) $(names2) $(symbol) $(gene) $(gene_pseudo) $(gene_pseudo_exon) $(flanks) $(uniq_genes) $(gff_tbi) $(genome_bed) $(tr_stats)

all: $(targets)

.DELETE_ON_ERROR:

$(genome_bed): $(genome)
	cat $< | awk -v OFS="\t" '{print $$1,0,$$2}' > $@

$(annot_orig):
	wget ftp://ftp.wormbase.org/pub/wormbase/releases/WS267/species/c_elegans/PRJNA13758/c_elegans.PRJNA13758.WS267.annotations.gff3.gz

$(annot): $(annot_orig)
	zcat $< | ./ws267_to_ucsc_chromosome.sh > $@

$(annot).intron: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 == "intron"' > $@

$(annot).exon: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 == "exon"' | grep -v Pseudogene > $@

$(annot).pseudogene: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 == "gene"' | grep "biotype=pseudogene" > $@

$(annot).gene: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 == "gene"' > $@

$(annot).pseudogene_exon: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 == "exon"' | grep Pseudogene > $@

$(annot).ncrna: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 == "ncRNA"' > $@

$(annot).three_prime_utr: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 == "three_prime_UTR"' > $@

$(annot).five_prime_utr: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 == "five_prime_UTR"' > $@

$(annot).promoter: $(annot)
	cat $< | awk '$$2 == "promoter" && $$3 == "promoter"' > $@

$(annot).enhancer: $(annot)
	cat $< | awk '$$2 == "enhancer" && $$3 == "enhancer"' > $@

$(annot).gene_structures: $(annot)
	cat $< | awk '$$2 == "WormBase" && $$3 != "gene"' > $@

$(annot).gene_structures_all: $(annot)
	cat $< | awk '$$2 == "WormBase"' > $@

$(annot).tandem_repeat: $(annot)
	cat $< | grep tandem_repeat > $@

$(annot).tandem_repeat.stats.csv: $(annot).tandem_repeat
	cat $< | sed -E -e "1i\num_copies,k" -e "s/.*Note=([0-9]+) copies of ([0-9]+)mer.*/\1,\2/" > $@

$(tr_stats): $(annot).tandem_repeat.stats.csv
	Rscript plot_tandem_repeat_stats.R $< $@

#$(annot).intron.sorted: $(annot).intron
#$(annot).exon.sorted: $(annot).exon
#$(annot).ncrna.sorted: $(annot).ncrna

$(sorted): %.sorted: %
	bedtools sort -i $< > $@

$(gff): %.gff: %
	sed -e '1i\##gff-version 3' $< > $@

$(gff_sorted_gz): %.sorted.gz: %
	(grep ^"#" $<; grep -v ^"#" $< | grep -v "^$$" | grep "\t" | sort -k1,1 -k4,4n) | bgzip -c > $@

$(gff_tbi): %.tbi: %
	tabix -p gff $<

$(merged): %.merged: %
	bedtools merge -s -c 9,6,7 -o distinct -i $< > $@

$(merged_without_strand): %.merged: %
	bedtools merge -c 9,6,7 -o distinct,first,distinct -i $< > $@

$(annot).intron_outside_exon: $(annot).intron.sorted.merged $(annot).exon.sorted.merged
	bedtools subtract -s -a $(annot).intron.sorted.merged -b $(annot).exon.sorted.merged > $@

$(names): %.names: %
	#cat $? | sed -E "s/.*Parent=Transcript:([-_.0-9a-zA-Z]+).*/\1/" | sort -V | uniq > $@
	cat $? | sed -E "s/.*=Transcript:([-_.0-9a-zA-Z]+).*/\1/" | sort -V | uniq > $@

$(names2): %.names: %
	cat $? | sed -E "s/.*Name=([-_\.0-9a-zA-Z]+).*/\1/" | sort -V | uniq > $@

$(gene_pseudo_exon): %.names.gene: %
	cat $? | sed -E "s/.*Parent=Pseudogene:([-_\.0-9a-zA-Z]+).*/\1/" | sort -V | uniq > $@

$(gene_pseudo): %.names.gene: %
	cat $? | sed -E "s/.*sequence_name=([-_\.0-9a-zA-Z]+).*/\1/" | sort -V | uniq > $@

$(tss_up500): $(annot).five_prime_utr.sorted
	bedtools flank -g $(genome) -s -l 500 -r 0 -i $? | bedtools slop -s -l 0 -r 1 -g $(genome) | awk -v OFS="\t" '{$$3 = "TSS [-500, 0]"; print $$0}' > $@

$(tss_down500): $(annot).five_prime_utr.sorted
	@# This is wrong!
	@#bedtools flank -g $(genome) -s -l 0 -r 500 -i $? | bedtools slop -s -l 1 -r 0 -g $(genome) | awk -v OFS="\t" '{$$3 = "TSS [0, 500]"; print $$0}' > $@
	@# Note that the input is GFF
	cat $< | awk -v OFS="\t" '{if($$7 == "+"){$$5 = $$4; print $$0}else if($$7 == "-"){$$4 = $$5; print $$0}else{print "Unexpected strand at Line " NR; exit 1}}' | \
		bedtools slop -s -l 0 -r 500 -g $(genome) > $@

$(tts_up500): $(annot).three_prime_utr.sorted
	@# This is wrong!
	@#bedtools flank -g $(genome) -s -l 500 -r 0 -i $? | bedtools slop -s -l 0 -r 1 -g $(genome) | awk -v OFS="\t" '{$$3 = "TTS [-500, 0]"; print $$0}' > $@
	@# Note that the input is GFF
	cat $< | awk -v OFS="\t" '{if($$7 == "+"){$$4 = $$5; print $$0}else if($$7 == "-"){$$5 = $$4; print $$0}else{print "Unexpected strand at Line " NR; exit 1}}' | \
		bedtools slop -s -l 500 -r 0 -g $(genome) > $@

$(tts_down500): $(annot).three_prime_utr.sorted
	bedtools flank -g $(genome) -s -l 0 -r 500 -i $? | bedtools slop -s -l 1 -r 0 -g $(genome) | awk -v OFS="\t" '{$$3 = "TTS [0, 500]"; print $$0}' > $@

name2symbol = ./c_elegans.PRJNA13758.WS267.xrefs.name2symbol.sh
$(symbol): %.symbol: %
	$(name2symbol) $? | sort -V | uniq > $@

name2gene = ./c_elegans.PRJNA13758.WS267.xrefs.name2gene.sh
$(gene): %.gene: %
	$(name2gene) $? | sort -V | uniq > $@

$(uniq_genes): $(annot).intron.sorted.names.gene $(annot).exon.sorted.names.gene $(annot).three_prime_utr.sorted.names.gene
	cat $^ | sort -V | uniq > $@

clean:
	$(RM) -vf $(targets)
