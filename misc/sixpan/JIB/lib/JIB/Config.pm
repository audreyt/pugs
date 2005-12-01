package JIB::Config;

use strict;
use warnings;
use Path::Class;
use base 'Exporter';

use vars qw(
        $Meta
        $Control
        $Available
        $RegisteredAlternatives
        $Alternatives

        $MetaExt
        $MetaFile

        $ArchiveData
        $ArchiveControl
        $ArchiveExt

        $Preinst
        $Postinst
        $Prerm
        $Postrm

		@EXPORT_OK
);

@EXPORT_OK = qw(
		$Meta
		$Control
		$Available
		$RegisteredAlternatives
		$Alternatives

		$MetaExt
		$MetaFile

		$ArchiveData
		$ArchiveControl
		$ArchiveExt

		$Preinst
		$Postinst
		$Prerm
		$Postrm
);

$EXPORT_TAGS{all} = \@EXPORT_OK;

$Meta = dir('meta');
$Control = $Meta->dir('control');
$Available = $Meta->file('available');
$RegisteredAlternatives = $Meta->file('registered-alternatives');
$Alternatives = $Meta->dir('alternatives');

$MetaExt = '.info';
$MetaFile = 'META'.$MetaExt;

$ArchiveData = 'data.tar.gz';
$ArchiveControl = 'control.tar.gz';
$ArchiveExt = '.jib';

$Preinst = 'PREINST.pl';
$Postinst = 'POSTINST.pl';
$Prerm = 'PRERM.pl';
$Postrm = 'POSTRM.pl';

1;

# Local variables:
# c-indentation-style: bsd
# c-basic-offset: 4
# indent-tabs-mode: nil
# End:
# vim: expandtab shiftwidth=4:
