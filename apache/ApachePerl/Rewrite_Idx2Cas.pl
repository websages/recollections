#!/usr/bin/perl 
################################################################################
# This is a simple mod_rewrite external handler. It rewrites the file requested
# with the contents of the file contained in the text file requested.
# if the file requested was data_idx/foo, and contained the text 
# "aa785adca3fcdfe1884ae840e13c6d294a2414e8", then the contents of the file:
# data/cas/aa785adca3fcdfe1884ae840e13c6d294a2414e8 would be shipped.
# 
# It allows you to browse the (human readable) indexes of a content-addressable
# storage system, but still get the data out of it. Typically I put the data_idx
# in a git repository.
################################################################################

$| = 1;
$DEBUG=1;
print STDERR "Starting rewrite engine\n" if $DEBUG;
my $cfg = { 'basedir'=> "/software/data/factory" };
while (<>) {
    my $output="";
    chomp();
    print STDERR "input: $_\n" if $DEBUG;
    if( $_ eq '' ){
        $output = "data_idx/$_\n";
    }elsif( ! -f "$cfg->{'basedir'}/data_idx/$_" ){
        print STDERR "$cfg->{'basedir'}/data_idx/$_ does not exist...\n" if $DEBUG;
        $output = "data_idx/$_\n";
    }else{
        print STDERR "$cfg->{'basedir'}/data_idx/$_ found!\n" if $DEBUG;
        open(KEYFILE, "$cfg->{'basedir'}/data_idx/$_") || die "cannot open file for reading @!";
        my $line=<KEYFILE>;
        close(KEYFILE);
        if($line=~m/^(([0-9a-f]{4,4})([0-9a-f]{4,4})([0-9a-f]{4,4})([0-9a-f]+))/){
            $output = "data_cas/$2/$3/$4/$1\n";
        }else{
            #s|^.*|mediacas/incoming/test/test2.jpg|;
            $output = "data_idx/$_\n";
        }
    }
    print STDERR "mod_rewrite: $output";
    print "$output";
}
