###########################################################
#
# This is a PerlCleanupHandler that will, after any DELETE
# requests, traverse the path for the file deleted
# backwards and delete any empty directories 
#
###########################################################
package ApachePerl::AutoDeleteEmpty;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::ServerRec ();
use Apache2::Log ();
use APR::Table ( );

use File::Path;
use File::Basename;

# Compile constants
use Apache2::Const -compile => qw(DECLINED);

sub handler {
        my $r = shift;
        my $reco_root = $r->dir_config("Recollections");
        my $reco_root = "/opt/local/recollections";

        # Create directories if processing a put request.
        if ($r->method() eq "DELETE")
        {
                # The full file system path to the file requested is a concat of the request filename and path_info.
                my $fullpath = $r->filename() . $r->path_info();
                my $dirname = dirname($fullpath);
                opendir(my $dh, $dirname) || warn "can't opendir $dirname: $!";
                my @files = grep { /^[^\.]+/ && -f "$dirname/$_" } readdir($dh);
                closedir($dh);
                if($#files < 0){ rmdir $dirname || warn "cannot remove $dirname $!!"; }
                my @dirparts=split('/',$dirname);

                while(pop(@dirparts)){
                    $dirname=join('/',@dirparts);
                    opendir(my $dh, $dirname) || warn "can't opendir $dirname: $!";
                    my @files = grep { /^[^\.]+/ } readdir($dh);
                    closedir($dh);
                    if($#files < 0){
                        rmdir $dirname || warn "cannot remove $dirname $!!";
                    }else{
                        # no point in continuing if this directory is not empty
                        return Apache2::Const::DECLINED;
                    }
                }
        }
        if ($r->method() eq "PUT")
        {
             my $notes = $r->notes();
             my $sha1sum = $notes->get("sha1sum");
             if($sha1sum ne ''){
                 print STDERR "sha1sum is [$sha1sum]\n";
                 my $fullpath = $r->filename() . $r->path_info();
                 # $link it to it's content.
                 print STDERR "Linking $reco_root/data/cas/$sha1sum -> $fullpath\n";
                 link($fullpath,"$reco_root/data/cas/$sha1sum") unless(-f "$reco_root/data/cas/$sha1sum");
                 # now remove that link so we can fill it with it's hash
                 print STDERR "Removing $fullpath\n";
                 unlink($fullpath);
                 # fill it with it's hash
                 print STDERR "Putting '$sha1sum' into $fullpath\n";
                 open(FILE,">$fullpath");
                 print FILE $sha1sum;
                 close(FILE);
             }
        }
        # Allow next handler to run
        return Apache2::Const::DECLINED;
}
1;
