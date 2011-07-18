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
use APR::Table ( );
use Digest::SHA;

sub handler {
    my($f, $bb, $mode, $block, $readbytes) = @_;
    my $c = $f->c;
    my $r = $f->r;
    my $notes = $r->notes();

    # only process PUTs
    return Apache2::Const::DECLINED unless ($r->method() eq "PUT");

    my $ctx = $f->ctx || {}; # set up our context to save our hasher
    unless($ctx->{'sha1'}){
        $ctx->{'sha1'} = Digest::SHA->new('sha1sum');
        $notes->add("sha1sum", '');
    }
    if($ctx->{'chunk'}){ $ctx->{'chunk'}++; }else{ $ctx->{'chunk'}=1; }
    my $rv = $f->next->get_brigade($bb, $mode, $block, $readbytes);
    unless($rv == APR::Const::SUCCESS){
        $f->ctx($ctx);
        return $rv;
    }
    for (my $b = $bb->first; $b; $b = $bb->next($b)) {
        $b->read(my $data);
        if($ctx->{'bytes'}){ $ctx->{'bytes'}+=length($data); }else{ $ctx->{'bytes'}=length($data); }
        if($data){
            #warn("data: [$data]\n");
            $ctx->{'sha1'}->add($data);
            print STDERR "seen_eos: ". $f->seen_eos ."\n" if($f->seen_eos);
            my $clone = $ctx->{'sha1'}->clone();
            print STDERR "hash: ".$clone->hexdigest."\n";
            $notes->set("sha1sum", $clone->hexdigest); # update the APR::Table
        }
    }
    $f->ctx($ctx);
    print STDERR "chunk $ctx->{'chunk'}: bytes $ctx->{'bytes'} / $readbytes\n";
    return Apache2::Const::OK;
}
1;
