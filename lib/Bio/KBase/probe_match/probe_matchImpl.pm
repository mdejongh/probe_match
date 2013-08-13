package Bio::KBase::probe_match::probe_matchImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

probe_match

=head1 DESCRIPTION



=cut

#BEGIN_HEADER
use SeedUtils;
use gjoseqlib;
use Data::Dumper;
use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;

sub matches_in_contigs {
    my($seq,$contigs,$strand, $idx) = @_;
    my @hits;

    if (%$idx)
    {
	my $hits = $idx->{$seq};
	if ($hits)
	{
	    for my $hit (@$hits)
	    {
		my($ctg, $loc) = @$hit;
		push(@hits, [$ctg, $loc + 1, $loc + length($seq), $strand]);
	    }
	}
	return @hits;
    }
    foreach my $idC (keys %$contigs)
    {
	my $seqC = $contigs->{$idC};
	my $off = 0;
	while (($_ = index($seqC,$seq,$off)) >= 0)
	{
	    push(@hits,[$idC,$_+1,$_+length($seq),$strand]);
	    $off = $_ + 1;
	}
    }
    return @hits;
}
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 match_probes_to_genome

  $matches = $obj->match_probes_to_genome($probes, $genome_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$probes is a reference to a list where each element is a Probe
$genome_id is a string
$matches is a reference to a list where each element is a ProbeMatch
Probe is a reference to a hash where the following keys are defined:
	probe_id has a value which is a string
	probe_seq has a value which is a string
	x has a value which is an int
	y has a value which is an int
ProbeMatch is a reference to a hash where the following keys are defined:
	feature_id has a value which is a string
	probe_id has a value which is a string

</pre>

=end html

=begin text

$probes is a reference to a list where each element is a Probe
$genome_id is a string
$matches is a reference to a list where each element is a ProbeMatch
Probe is a reference to a hash where the following keys are defined:
	probe_id has a value which is a string
	probe_seq has a value which is a string
	x has a value which is an int
	y has a value which is an int
ProbeMatch is a reference to a hash where the following keys are defined:
	feature_id has a value which is a string
	probe_id has a value which is a string


=end text



=item Description

input a list of probes, match them to the genome

=back

=cut

sub match_probes_to_genome
{
    my $self = shift;
    my($probes, $genome_id) = @_;

    my @_bad_arguments;
    (ref($probes) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"probes\" (value was \"$probes\")");
    (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument \"genome_id\" (value was \"$genome_id\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to match_probes_to_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'match_probes_to_genome');
    }

    my $ctx = $Bio::KBase::probe_match::Service::CallContext;
    my($matches);
    #BEGIN match_probes_to_genome

    # get the contigs for the genome
    my $csO = Bio::KBase::CDMI::CDMIClient->new_for_script();

    my $contig_hash_ref = $csO->genomes_to_contigs([$genome_id]);
    my $contigsHash = $csO->contigs_to_sequences($contig_hash_ref->{$genome_id}); 
    my %contigs = map { $_ => lc $contigsHash->{$_} } keys %$contigsHash;

    my %probelens;
    foreach my $probe (@$probes) {
	$probelens{length($probe->{"probe_seq"})}++;
    }

    my %contig_index;
    my $probe_size;

#
# If we have a single probe length, create an index of the contigs
# and use for later lookups.
#
    if (keys %probelens == 1)
    {
	$probe_size = (keys %probelens)[0];
	for my $id (keys %contigs)
	{
	    my $seq = $contigs{$id};
	    for (my $i = 0; $i < length($seq) - $probe_size + 1; $i++)
	    {
		my $s = substr($seq, $i, $probe_size);
		push(@{$contig_index{$s}}, [$id, $i]);
	    }
	}
    }

    my @pegs;

    my $fidData = $csO->genomes_to_fids([$genome_id],[]);
    my $locationData = $csO->fids_to_locations($fidData->{$genome_id});

    foreach my $fid (keys %$locationData) {
	# grab first location
	my $location = $locationData->{$fid}->[0];
	my ($lcontig, $begin, $strand, $len) = @$location;
	my $end = ($strand eq '+') ? ($begin+$len) : ($begin-$len);
	push(@pegs,[$fid,[$lcontig,$begin,$end]]);
    }

    my %multiple;
    my @all_hits = ();
    foreach my $probe (@$probes)
    {
	my $probe_id = $probe->{"probe_id"};
	my $seq = lc $probe->{"probe_seq"};
	my $seqR = lc &SeedUtils::rev_comp($seq);
	my @matches = &matches_in_contigs($seq,\%contigs,'+', \%contig_index);
	push(@matches,&matches_in_contigs($seqR,\%contigs,'-', \%contig_index));
	if (@matches == 0)
	{
#	    print STDERR "$probe_id does not occur\n";
	}
	elsif (@matches > 1)
	{
	    $multiple{$probe_id} = scalar @matches;
#	    print STDERR "$probe_id occurs ",scalar @matches," times: ",join(",",map {join(":",@$_) } @matches),"\n";
	}
	push(@all_hits,map { [$probe_id,$_] } @matches);
    }
    @all_hits = sort { ($a->[1]->[0] cmp $b->[1]->[0]) or ($a->[1]->[1] <=> $b->[1]->[1]) } @all_hits;
    @pegs     = sort { ($a->[1]->[0] cmp $b->[1]->[0]) or 
			   (&min($a->[1]->[1],$a->[1]->[2]) <=> &min($b->[1]->[1],$b->[1]->[2])) } @pegs;
    
    my @corr = ();
    foreach my $hit_tuple (@all_hits)
    {
	my($probe_id,$hit)            = @$hit_tuple;
	my($contigH,$bH,$eH,$strandH) = @$hit;
	my $found_corr = 0;
	foreach my $peg_tuple (@pegs)
	{
	    my($peg,$loc)        = @$peg_tuple;
	    my($contigP,$bP,$eP) = @$loc;
	    if ($contigH eq $contigP && &SeedUtils::between($bP,$bH,$eP))
	    {
		my $n;
		if ((($bP < $eP) && (($bH - $bP) > 3)) ||
		    (($bP > $eP) && (($bH - $eP) > 3)))
		{
		    $n = $multiple{$probe_id} ? $multiple{$probe_id} : 0;
		}
		my $strandP;
		if ($bP > $eP)
		{
		    ($bP,$eP) = ($eP,$bP);
		    $strandP = '-';
		}
		else
		{
		    $strandP = '+';
		}
		push(@corr,[$peg,$probe_id,$n,$strandP,$strandH,$contigH,$bH,$eH]);
		$found_corr = 1;
	    }
	}
	if ($found_corr == 0) {
#	    print STDERR "Didn't find a peg for $probe_id and @$hit\n";
	}
    }

    my @probes_in_peg;
    foreach my $x (sort { &SeedUtils::by_fig_id($a->[0],$b->[0]) or ($a->[1] cmp $b->[1]) } @corr)
    {
	my($peg,$probe,$n,$strandH,$strandP,$contigH,$bH,$eH) = @$x;
	if ($strandH eq $strandP)
	{
	    push @probes_in_peg, { "feature_id" => $peg, "probe_id" => $probe };
	}
    }

    return \@probes_in_peg;

    #END match_probes_to_genome
    my @_bad_returns;
    (ref($matches) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"matches\" (value was \"$matches\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to match_probes_to_genome:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'match_probes_to_genome');
    }
    return($matches);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 Probe

=over 4



=item Description

a probe has a DNA sequence, and an x and y location on the microarray


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
probe_id has a value which is a string
probe_seq has a value which is a string
x has a value which is an int
y has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
probe_id has a value which is a string
probe_seq has a value which is a string
x has a value which is an int
y has a value which is an int


=end text

=back



=head2 ProbeMatch

=over 4



=item Description

a match identifies the probe and the feature it matches


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
feature_id has a value which is a string
probe_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
feature_id has a value which is a string
probe_id has a value which is a string


=end text

=back



=cut

1;
