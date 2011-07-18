################################################################################
# This sets up the mod_dav working space so curl -X PUT|DELETE can be used to 
# add/remove content it probably needs ldap authentication added, to control 
# who can add to a repository, but it works...
################################################################################

PerlTransHandler +ApachePerl::CASRewrite
Alias /working "[% RECOLLECTIONS_ROOT %]/working"
<Directory "[% RECOLLECTIONS_ROOT %]/working/">
    DAV On
    PerlFixupHandler +ApachePerl::AutoMKCOL
    PerlInputFilterHandler +ApachePerl::Checksum
    PerlCleanupHandler +ApachePerl::AutoDeleteEmpty
    Options Indexes MultiViews FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>

Alias /idx "[% RECOLLECTIONS_ROOT %]/data/idx"
<Directory "[% RECOLLECTIONS_ROOT %]/data/idx">
    Options Indexes MultiViews FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>

Alias /cas "[% RECOLLECTIONS_ROOT %]/data/cas"
<Directory "[% RECOLLECTIONS_ROOT %]/data/cas">
    Options Indexes MultiViews FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
