use Bio::KBase::probe_match::probe_matchImpl;
use strict;
use Data::Dumper;

open(P,"small_ecoli_probes.txt") or die;

my @probes;

while(<P>) {
    chomp;
    my ($id, $seq) = split "\t";
    my ($x,$y) = split "_", $id;
    push @probes, { "probe_id" => $id, "probe_seq" => $seq, "x" => $x, "y" => $y };
}

my $impl = new Bio::KBase::probe_match::probe_matchImpl;
my $result = $impl->match_probes_to_genome(\@probes,"kb|g.0");
print "Got back ", scalar @$result, " probe matches\n";
print &Dumper($result);
