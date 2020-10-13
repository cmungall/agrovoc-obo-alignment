# Agrovoc-to-OBO mappings

In progress

## Inputs

See [downloads](downloads)

 * agrovoc - ntriples
 * curated mappings - these are used to boost matches

## Methods

We use rdfmatch

Rules are in conf/

See Makefile

We currently only run over a subset of OBOs. Most relevant ones:

 - AGRO
 - ENVO
 - CHEBI
 - MONDO

## Outputs

 * SSSOM mapping files. https://github.com/OBOFoundry/SSSOM/
 * Summary crosstab files

Note that we include even low confidence matches, but every match has a confidence score

## TODO

User boomer to refine mappings
