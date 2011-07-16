###########################################################
# http://permalink.gmane.org/gmane.comp.apache.ivy.user/3565
#
# This is a PerlFixupHandler that will take any PUT
# requests, determine the path required, and if it doesn't
# exist, creates the whole path. If there is a problem
# creating the path, an error is generated.
#
###########################################################
package ApachePerl::AutoMKCOL;

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
        print STDERR __PACKAGE__ ." \$r=". ref($r)."\n";

        # Create directories if processing a put request.
        if ($r->method() eq "PUT")
        {
                # The full file system path to the file requested is a concat of the request filename and path_info.
                my $fullpath = $r->filename() . $r->path_info();
                my $dirname = dirname($fullpath);

                # If the directory doesn't exist, create it
                if (!(-d $dirname))
                {
                        $r->log->info("Creating directory structure for PUT request: '" .  $dirname . "'.");
                        my @dirlist = mkpath ($dirname);

                        # If at least one directory wasn't created, there was a problem
                        die "Failed to create directory structure: '" . $dirname . "'." unless $#dirlist > -1;
                }
        }

        # Allow next handler to run
        return Apache2::Const::DECLINED;
}
1;
