use Bio::KBase::probe_match::probe_matchImpl;
use Data::Dumper;
use Bio::KBase::CDMI::Client;
use strict;

open(P,"bsub.probes") or die;

my @probes;

while(<P>) {
    chomp;
    my ($seq, $x, $y) = split "\t";
    my $id = $x."_".$y;
    push @probes, { "probe_id" => $id, "probe_seq" => $seq, "x" => $x, "y" => $y };
}

my $impl = new Bio::KBase::probe_match::probe_matchImpl;
my $result = $impl->match_probes_to_genome(\@probes,"kb|g.422");

my @features;
my %features;
foreach my $match (@$result) {
    push @features, $match->{'feature_id'};
    push @{$features{$match->{'feature_id'}}}, $match->{'probe_id'};
}

my $cdmi = new Bio::KBase::CDMI::Client("http://kbase.us/services/cdmi_api");
my $seed = $cdmi->get_entity_Feature(\@features, ['source_id']);

foreach my $peg (keys %$seed) {
    foreach my $probe (@{$features{$peg}}) {
	print $probe, "\t", $seed->{$peg}->{'source_id'}, "\n";
    }
}
