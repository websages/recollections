package ApachePerl::CASRewrite;
use Apache::Constants qw( :common REDIRECT );
# PerlTransHandler RewriteModule
$| = 1; 
my $source_url = 'http://127.0.0.1';  # have this reflect your private IP

sub handler {
    my $r = shift;
    return &parse_uri($r);
}

sub parse_uri {
    my $r = shift;
    my $hostname = $r->hostname;
    my $uri = $r->uri;
    my $query = $r->args;
   
    # RewriteCond %{REQUEST_URI} ^/cgi-bin/show_page.pl$
    # RewriteCond %{QUERY_STRING} ^(.+)$
    if ($uri =~ /^\/cgi-bin\/show_page.pl$/ && $query =~ /^(.+)$/){
        $r->headers_out->set('Location' => "http://www.adamovsky.com/show/$1");
        $r->status(REDIRECT);
        $r->send_http_header;
        return DECLINED;
    }
    
    # RewriteRule ^(.+)$ /show/$1                               [R]   # (rewrite)
    # RewriteRule ^/show/(.+)$ http://10.15.1.5/long/folder/$1  [P,L] # (proxy, last)
    if ($uri =~ /^\/data_cas\/(.+)/){
        return DECLINED if $r->proxyreq;
        $r->proxyreq(1);   # this is equivalent to [P]
        $r->args($query);  # this sets the query string
        $r->uri("http://$source_url/long/folder/$1");
        $r->filename( "proxy:http://$source_url/long/folder/$1" );
        $r->handler('proxy-server');
        return OK;
    }

    return DECLINED;  # in case neither if()'s validate
}

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
