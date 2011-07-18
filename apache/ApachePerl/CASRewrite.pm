package ApachePerl::CASRewrite;
# PerlTransHandler +ApachePerl::CASRewrite
use strict;
use warnings;
use Apache2::RequestRec();
use APR::Const     -compile => ':common'; # SUCCESS
use Apache2::Const -compile => qw(OK DECLINED);
use File::MimeInfo();
use File::Type();
use Data::Dumper;
$| = 1; 

sub handler {
    my $r = shift;
    my $reco_root = $r->dir_config("Recollections");
    if( ($r->method() eq "GET") ||($r->method() eq "HEAD") ){
        my $hash;
        if( $r->uri =~ m|^/working/(.*)|){
            my ($idx_file) = ($1);
            if( -f "$reco_root/working/$idx_file"){
                open(my $fh, "$reco_root/working/$idx_file");
                if($fh){
                    $hash=<$fh>;
                    close ($fh); 
                    ############################################################                    
                    # It's awesomes that this is necessary
                    # File::Type returns image/jpeg as application/octet-stream
                    # File::MimeInfo returns ascii text as application/octet-stream
                    # so if one returns application/octet-stream, use the other.
                    # ugh.
                    ############################################################                    
                    my $ft = File::Type->new();
                    my $fmi = File::MimeInfo->new();
                    my $content_type = $ft->checktype_filename("$reco_root/data/cas/$hash");
                    if($content_type){
                        if($content_type eq "application/octet-stream"){
                            $content_type = $fmi->mimetype("$reco_root/data/cas/$hash");
                        }
                    }else{
                        $content_type = $fmi->mimetype("$reco_root/data/cas/$hash");
                    }
                    #print STDERR "[$content_type]\n";
                    $r->content_type( $content_type ) if($content_type);
                    $r->uri("/cas/$hash");
                }else{
                    $r->uri("/working");
                }
            }
            return Apache2::Const::DECLINED;
        }elsif( $r->uri =~ m|^/cas/(.*)|){
            my ($cas_file) = ($1);
            my $ft = File::Type->new();
            my $fmi = File::MimeInfo->new();
            my $content_type = $ft->checktype_filename("$reco_root/data/cas/$cas_file");
            if($content_type){
                if($content_type eq "application/octet-stream"){
                    $content_type = $fmi->mimetype("$reco_root/data/cas/$cas_file");
                } 
            }else{
                $content_type = $fmi->mimetype("$reco_root/data/cas/$cas_file");
            }
            #print STDERR "[$content_type]\n";
            $r->content_type( $content_type ) if($content_type);
        }
    }
    return Apache2::Const::DECLINED;
}

#sub parse_uri {
#    my $r = shift;
#    my $hostname = $r->hostname;
#    my $uri = $r->uri;
#    my $query = $r->args;
#   
#    # RewriteCond %{REQUEST_URI} ^/cgi-bin/show_page.pl$
#    # RewriteCond %{QUERY_STRING} ^(.+)$
#    if ($uri =~ /^\/working\/(.+)/){
#        print STDERR "GET ==> /working/$1\n";
#        #$r->headers_out->set('Location' => "http:///show/$1");
#        #$r->status(REDIRECT);
#        #$r->send_http_header;
#        return OK;
#        #return DECLINED;
#    }
#    
#    # RewriteRule ^(.+)$ /show/$1                               [R]   # (rewrite)
#    # RewriteRule ^/show/(.+)$ http://10.15.1.5/long/folder/$1  [P,L] # (proxy, last)
#    if ($uri =~ /^\/cas\/(.+)/){
#        return DECLINED if $r->proxyreq;
##        $r->proxyreq(1);   # this is equivalent to [P]
##        $r->args($query);  # this sets the query string
##        $r->uri("http://$source_url/long/folder/$1");
##        $r->filename( "proxy:http://$source_url/long/folder/$1" );
##        $r->handler('proxy-server');
#        return OK;
#    }
#
#    return DECLINED;  # in case neither if()'s validate
#}
#
1;

#$| = 1;
#$DEBUG=1;
#print STDERR "Starting rewrite engine\n" if $DEBUG;
#my $cfg = { 'basedir'=> "/software/data/factory/product" };
#while (<>) {
#    my $output="";
#    chomp();
#    print STDERR "input: $_\n" if $DEBUG;
#    if( $_ eq '' ){
#        $output = "data_idx/$_\n";
#    }elsif( ! -f "$cfg->{'basedir'}/data_idx/$_" ){
#        print STDERR "$cfg->{'basedir'}/data_idx/$_ does not exist...\n" if $DEBUG;
#        $output = "data_idx/$_\n";
#    }else{
#        print STDERR "$cfg->{'basedir'}/data_idx/$_ found!\n" if $DEBUG;
#        open(KEYFILE, "$cfg->{'basedir'}/data_idx/$_") || die "cannot open file for reading @!";
#        my $line=<KEYFILE>;
#        close(KEYFILE);
#        if($line=~m/^(([0-9a-f]{2,2})([0-9a-f]{4,4})([0-9a-f]{4,4})([0-9a-f]+))/){
#            $output = "data_cas/$2/$1\n";
#        }else{
#            #s|^.*|mediacas/incoming/test/test2.jpg|;
#            $output = "data_idx/$_\n";
#        }
#    }
#    print STDERR "mod_rewrite: $output";
#    print "$output";
#}
