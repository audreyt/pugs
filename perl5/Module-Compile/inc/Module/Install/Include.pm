#line 1 "inc/Module/Install/Include.pm - /Users/ingy/local/lib/perl5/site_perl/5.8.6/Module/Install/Include.pm"
package Module::Install::Include;
use Module::Install::Base; @ISA = qw(Module::Install::Base);

sub include { +shift->admin->include(@_) };
sub include_deps { +shift->admin->include_deps(@_) };
sub auto_include { +shift->admin->auto_include(@_) };
sub auto_include_deps { +shift->admin->auto_include_deps(@_) };
sub auto_include_dependent_dists { +shift->admin->auto_include_dependent_dists(@_) }
1;
