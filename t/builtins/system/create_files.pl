# This script needs a comment explaining it's purpose in the test suite
# or may be moved or deleted. It doesn't seem to be used by the other
# "*.t" files in this directory. 

use strict;
use File::Path;
use File::Copy;
use Config;
use Cwd;

$| = 1;

my $cwd = cwd();

rmtree($testdir);
mkdir($testdir);
die "Could not create '$testdir':$!" unless $testdir~~:d;

open(my $F, ">$testdir/$exename.c")
    or die "Can't create $testdir/$exename.c: $!";
print $F <<'EOT';
#include <stdio.h>
#ifdef __BORLANDC__
#include <windows.h>
#endif
int
main(int ac, char **av)
{
    int i;
#ifdef __BORLANDC__
    char *s = GetCommandLine();
    int j=0;
    av[0] = s;
    if (s[0]=='"') {
    for(;s[++j]!='"';)
      ;
    av[0]++;
    }
    else {
    for(;s[++j]!=' ';)
      ;
    }
    s[j]=0;
#endif
    for (i = 0; i < ac; i++)
    printf("[%s]", av[i]);
    printf("\n");
    return 0;
}
EOT

open($F, ">$testdir/$plxname.bat")
    or die "Can't create $testdir/$plxname.bat: $!";
print $F <<'EOT';
@rem = @rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
EOT

print $F <<EOT;
"$^X" -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
"$^X" -x -S %0 %*
EOT
print $F <<'EOT';
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl
#line 15
print "[$_]" for ($0, @ARGV);
print "\n";
__END__
:endofperl
EOT

close $F;

# build the executable
chdir($testdir);
END {
    #chdir($cwd) && rmtree("$cwd/$testdir") if "$cwd/$testdir"~~:d;
}
if (open(my $EIN, "$cwd/win32/${exename}_exe.uu")) {
    print "# Unpacking $exename.exe\n";
    my $e;
    {
    local $/;
    $e = unpack "u", <$EIN>;
    close $EIN;
    }
    open my $EOUT, ">$exename.exe" or die "Can't write $exename.exe: $!";
    binmode $EOUT;
    print $EOUT $e;
    close $EOUT;
}
else {
    my $minus_o = '';
    if ($Config{cc} eq 'gcc')
     {
      $minus_o = "-o $exename.exe";
     }
    print "# Compiling $exename.c\n# $Config{cc} $Config{ccflags} $exename.c\n";
    if (system("$Config{cc} $Config{ccflags} $minus_o $exename.c >log 2>&1") != 0) {
    print "# Could not compile $exename.c, status $?\n"
         ."# Where is your C compiler?\n"
         ."1..0 # skipped: can't build test executable\n";
    exit(0);
    }
    unless ("$exename.exe"~~:f) {
    if (open(LOG,'log'))
         {
          while(<LOG>) {
         print "# ",$_;
          }
         }
        else {
      warn "Cannot open log (in $testdir):$!";
        }
    }
}
copy("$plxname.bat","$plxname.cmd");
chdir($cwd);
unless ("$testdir/$exename.exe"~~:x) {
    print "# Could not build $exename.exe\n"
     ."1..0 # skipped: can't build test executable\n";
    exit(0);
}

return 1;
