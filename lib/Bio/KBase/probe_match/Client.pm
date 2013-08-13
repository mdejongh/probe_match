package Bio::KBase::probe_match::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::probe_match::Client

=head1 DESCRIPTION





=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::probe_match::Client::RpcClient->new,
	url => $url,
    };


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function match_probes_to_genome (received $n, expecting 2)");
    }
    {
	my($probes, $genome_id) = @args;

	my @_bad_arguments;
        (ref($probes) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"probes\" (value was \"$probes\")");
        (!ref($genome_id)) or push(@_bad_arguments, "Invalid type for argument 2 \"genome_id\" (value was \"$genome_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to match_probes_to_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'match_probes_to_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "probe_match.match_probes_to_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'match_probes_to_genome',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method match_probes_to_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'match_probes_to_genome',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "probe_match.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'match_probes_to_genome',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method match_probes_to_genome",
            status_line => $self->{client}->status_line,
            method_name => 'match_probes_to_genome',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::probe_match::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::probe_match::Client version is $svr_version. API subject to change.\n";
    }
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

package Bio::KBase::probe_match::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
