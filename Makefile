## Makefile for building alignment tsvs
## Please consult README.md

# ----------------------------------------
# CONSTANTS
# ----------------------------------------

# ----------------------------------------
# TOP LEVEL TARGET
# ----------------------------------------
all: align_all summarize_all
setup: 
clean:
	rm target/*.tsv
realclean: clean

OBOs = ro uo agro envo obi pato po to uberon chebi mondo oba

align_all: $(patsubst %, target/obomatch-agrovoc-%.sssom.tsv, $(OBOs))
summarize_all: $(patsubst %, target/obomatch-agrovoc-%.crosstab.tsv, $(OBOs))

# ----------------------------------------
# Downloads
# ----------------------------------------

AGVOC_VERSION = 2020-10-01

download/agrovoc.nt.zip:
	curl -L -s http://agrovoc.uniroma2.it/agrovocReleases/agrovoc_$(AGVOC_VERSION)_lod.nt.zip > $@

# ----------------------------------------
# Alignment
# ----------------------------------------

target/agrovoc-curated-mappings.sssom.tsv: download/agrovoc_mappings_april2020_revKK.txt
	./util/tsv2sssom.pl $< > $@

target/agrovoc-curated-mappings.sssom.ttl: target/agrovoc-curated-mappings.sssom.tsv
	sssom convert -i $< -o $@

UC_WILDCARD = $(shell echo '$*' | tr '[:lower:]' '[:upper:]')

target/obomatch-agrovoc-%.sssom.tsv: download/agrovoc_lod.nt
	obomatch -T -d rdf_matcher \
	  -g remove_non_english_literals \
	  -p agrovoc \
	  --match_prefix $(UC_WILDCARD) \
	  -w conf/weights.pro \
	  -m agrovoc=http://aims.fao.org/aos/agrovoc/ \
	  -i target/agrovoc-curated-mappings.sssom.ttl \
	  -i $< \
	  -i $* \
	  -i conf/envo-bridge.ttl \
	 > $@.tmp && mv $@.tmp $@
.PRECIOUS: target/obomatch-agrovoc-%.sssom.tsv

target/%.crosstab.tsv: target/%.sssom.tsv
	sssom crosstab -o $@ $<

#align_all: $(patsubst %,align-sweet-obo-%.tsv,$(ONTS))

CONF = -c conf.yaml -X curated.csv

# use ontobio-lexmap
# filter results for ontology of interest
align-sweet-obo-%.tsv: sweet.json
	ontobio-lexmap.py $(VERBOSE) $(CONF) -u unmapped-$*.tsv $< $*  > $@.tmp && mv $@.tmp $@

align-sweet-obo-ALL.tsv: sweet.json
	ontobio-lexmap.py $(VERBOSE) $(CONF) -u unmapped-ALL.tsv $< $(ONTS) > $@.tmp && mv $@.tmp $@ && grep sweetontology.net unmapped-ALL.tsv | sort -u > sweet-unmatched.tsv

align-sweet-obo-%.obo: sweet.json
	ontobio-lexmap.py $(VERBOSE) $(CONF) -t obo $< $*  > $@.tmp && mv $@.tmp $@

owltools:
	curl -L http://build.berkeleybop.org/userContent/owltools/owltools -o $@ && chmod +x $@

align-sweet-odm.tsv:
	rdfmatch -f tsv -l -G $@.rdf  -A ~/repos/onto-mirror/void.ttl -i obo_prefixes -i sweet -i odm new_match > $@

# ----------------------------------------
# kBOOM
# ----------------------------------------
ptable.csv: align-sweet-obo-ALL.tsv
	cat $< | p.df  'df[["left", "right","pr_subClassOf","pr_superClassOf","pr_equivalentTo","pr_other"]]' -o csv -i tsv | grep -v '^"left' > $@
ptable.tsv: ptable.csv
	csv2tsv.py $< $@

all-%.obo:
	ogr --resources sweet.json $* -t obo % > $@
all-%.owl: all-%.obo
	owltools $< -o $@
#all.owl: $(OBOS)
#	owltools $^ --merge-support-ontologies -o $@

axioms-%.owl: ptable.tsv all-%.owl 
	kboom --experimental  --splitSize 50 --max 9 -m linked-$*-rpt.md -j linked-$*-rpt.json -n -o $@ -t $^

