use Bio::KBase::probe_match::probe_matchImpl;

use Bio::KBase::probe_match::Service;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::probe_match::probe_matchImpl->new;
    push(@dispatch, 'probe_match' => $obj);
}


my $server = Bio::KBase::probe_match::Service->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
