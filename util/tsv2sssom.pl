#!/usr/bin/perl

print "#curie_map:\n";
print "#  AGRO: \"http://purl.obolibrary.org/obo/AGRO_\"\n";
print "#  agrovoc: \"http://aims.fao.org/aos/agrovoc/\"\n";
print "#  skos: \"http://www.w3.org/2004/02/skos/core#\"\n";

my $hdr = <>;
my @cols =
    qw(subject_id subject_label
    predicate_id
    object_id object_label
    confidence
    comments);

print join("\t", @cols)."\n";
while(<>) {
    chomp;
    my ($ix,
        $subject_id,
        $subject_label,
        $subject_def,
        $object_id,
        $object_label,
        $kk,
        $comments,
        $sugg_uri) = split(/\t/,$_);
    my $pred = 'skos:exactMatch';
    if ($kk eq 'Yes') {
    }
    elsif ($kk eq 'No') {
        # todo: need a skos relation like distantMatch
        $pred = 'skos:relatedMatch';
    }
    else {
        print STDERR "SKIP: $_\n";
    }
    print join("\t",
               ($subject_id,
                $subject_label,
                $pred,
                $object_id,
                $object_label,
                '0.9',
                $comments))."\n";
}
