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

sub handler : FilterConnectionHandler {
    my($f, $bb, $mode, $block, $readbytes) = @_;

    my $c = $filter->c;
    my $r = $filter->r;

    my $rv = $filter->next->get_brigade($bb, $mode, $block, $readbytes);
    return $rv unless $rv == APR::Const::SUCCESS;

    for (my $b = $bb->first; $b; $b = $bb->next($b)) {
          $b->read(my $data);
          warn("data: $data\n");
  
          if ($data and $data =~ s|FUCK|SHIT|) {
              my $nb = APR::Bucket->new($bb->bucket_alloc, $data);
              $b->insert_after($nb);
              $b->remove; # no longer needed
              #$f->ctx(1); # flag that that we have done the job
              last;
          }
      }

    return Apache2::Const::OK;
}
1;
