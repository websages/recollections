################################################################################
# This sets up the mod_dav working space so curl -X PUT|DELETE can be used to 
# add/remove content it probably needs ldap authentication added, to control 
# who can add to a repository, but it works...
################################################################################
Alias /working "[% RECOLLECTIONS_ROOT %]/working"
<Directory "[% RECOLLECTIONS_ROOT %]/working/">
    DAV On
    PerlFixupHandler +ApachePerl::AutoMKCOL
    PerlCleanupHandler +ApachePerl::AutoDeleteEmpty
    Options Indexes MultiViews FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
