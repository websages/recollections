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

use File::Path;
use File::Basename;

# Compile constants
use Apache2::Const -compile => qw(DECLINED);

sub handler {
        my $r = shift;

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
        # Allow next handler to run
        return Apache2::Const::DECLINED;
}
1;
