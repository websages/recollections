package ApachePerl::Checksum;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::ServerRec ();
use Apache2::Log ();

use File::Path;
use File::Basename;

# Compile constants
use Apache2::Filter ( );
use APR::Const     -compile => ':common'; # SUCCESS
use Apache2::Const -compile => qw(OK DECLINED);
use APR::Brigade ( );
use APR::Bucket ( );

sub handler {
    my($filter, $bb, $mode, $block, $readbytes) = @_;

    my $c = $filter->c;
    my $r = $filter->r;
    my $bb_ctx = APR::Brigade->new($r->pool, $c->bucket_alloc);
    my $rv = $filter->next->get_brigade($bb, $mode, $block, $readbytes);
    return $rv unless $rv == APR::Const::SUCCESS;

    while (!$bb_ctx->empty) {
        my $b = $bb_ctx->first;
        $b->remove;
        if ($b->is_eos) {
            $bb->insert_tail($b);
            last;
        }
        my $data;
        my $status = $b->read($data);
        return $status unless $status == APR::Const::SUCCESS;

        if ($data and $data =~ s|^FUCK|SHIT|) {
            my $bn = APR::Bucket->new($data);
            $b->insert_after($bn);
            $b->remove; # no longer needed
            last;
        }
    }

    return Apache2::Const::OK;
}
1;
