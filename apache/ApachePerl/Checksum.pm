package ApachePerl::Checksum;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::ServerRec ();
use Apache2::Log ();
use Apache2::Filter ( );
use APR::Const     -compile => ':common'; # SUCCESS
use Apache2::Const -compile => qw(OK DECLINED);
use APR::Brigade ( );
use APR::Bucket ( );

use Digest::SHA;

sub handler {
    my($f, $bb, $mode, $block, $readbytes) = @_;
    my $c = $f->c;
    my $r = $f->r;

    # only process PUTs
    return Apache2::Const::DECLINED unless ($r->method() eq "PUT");

    my $ctx = $f->ctx || {}; # set up our context to save our hasher
    $ctx->{'sha1'} = Digest::SHA->new('sha1sum') unless($ctx->{'sha1'});

    my $rv = $f->next->get_brigade($bb, $mode, $block, $readbytes);
    unless($rv == APR::Const::SUCCESS){
        $f->ctx($ctx);
        return $rv;
    }
    for (my $b = $bb->first; $b; $b = $bb->next($b)) {
          $b->read(my $data);
          $ctx->{'sha1'}->add($data) if $data;
    }
    # prin to stderr for now, but we need to save this in the request
    #if ($f->seen_eos) {
        print STDERR "digest: ".$ctx->{'sha1'}->hexdigest;
    #}
    $f->ctx($ctx);
    return Apache2::Const::OK;
}
1;
