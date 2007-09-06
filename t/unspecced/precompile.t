use v6-alpha;

use Test;

=pod

Tests to see whether precompiled modules are used correctly:
1. They should observe @*INC
2. They should only be used if there's a corresponding source
   module and it is older than the precompiled module

=cut

# XXX - needs porting, only works on Unixen today
BEGIN {

plan 14;

if $*OS eq any <MSWin32 mingw msys cygwin browser> {
    skip_rest "tests need to be ported to work on $*OS";
    exit;
};
unless try({ eval("1", :lang<perl5>) }) {
    skip_rest "tests require Perl 5 support";
    exit;
}

}

use File::Spec;

# XXX - This should be replaced with something Perl 6-native
use perl5:File::Temp <tempdir>;

# XXX - Also, CLEANUP does not seem to work, so tempfiles will
#       remain after test if we do:
# our &tempdir := File::Temp.can('tempdir').assuming(:CLEANUP(1));
#       So we laboriously work around:
my (@files_created, @dirs_created);

sub mktempdir () {
    my $dir = tempdir()
        orelse fail;
    @dirs_created.push($dir);
    return $dir;
}
sub open_new (Str $filename) {
    my $fh = open($filename, :w)
        orelse fail;
    @files_created.push($filename);
    return $fh;
}
# XXX - See END block below, remove it and calls to open_new() below if removing

sub precompile (Str $pmfile, Str $destdir) {
    die "No such file or directory" unless $pmfile ~~ :e && $destdir ~~ :d;
    # XXX - correct for win32?
    my $out = catpath('', $destdir, (splitpath($pmfile))[2] ~ ".yml");
    @files_created.push($out);
    # XXX - does this work under win32?
    system($*EXECUTABLE_NAME ~ " -CParse-YAML $pmfile > $out");
}

sub generate_class (Str $classname, $value) {
    # Must use a sub, not a method, for yaml parsing to work
    return "class $classname \{\n  sub value \{ $value.perl() \}\n\}\n";
}

sub write_class ($destdir, Str $classname, Num $value, Bool :$precompile = 0) {
    my $filename = catpath('', $destdir, "{$classname}.pm");
    my $fh = open_new($filename)
        orelse die "Couldn't open $filename: $!";
    $fh.say(generate_class(:$classname, :$value));
    $fh.close
        orelse die "Couldn't close $filename: $!";
    if $precompile {
        precompile($filename, $destdir);
    }
    return $filename;
}

sub make_old (Str $filename) {
    $filename ~~ :e orelse fail;
    # XXX - not portable, please fix for win32
    system(«touch -t 200001010000 $filename»);
}

# XXX - Wrapping in try so we can cleanup; this can go once File::Temp
#       is native.
try {
    my $lib1 = mktempdir();
    my $lib2 = mktempdir();
    diag "Created tempdirs {($lib1, $lib2)}";

    my @libdirs = ($lib1, $lib2);

    die "# @libdirs[]: Missing directory(/ies) required by test"
        unless all(@libdirs) ~~ :d;

    @*INC.unshift($lib1, $lib2);

    # sanity -- can we write and then use?
    {
        write_class($lib1, 'PMSanity', 42);
        use_ok 'PMSanity';
        is PMSanity::value, 42, 'Sanity check -- can get a value';
    }

    # sanity -- are same-named .pm's earlier in @*INC preferred?
    {
        write_class($lib1, 'PMSanity2', "earlier");
        write_class($lib2, 'PMSanity2', "later");
        use_ok 'PMSanity2';
        is PMSanity2::value, "earlier",
            q"Sanity check -- .pm's earlier in @*INC path are preferred";
    }

    # sanity -- can we use a .yml precompile?
    {
        my $pmfile = write_class($lib1, 'PMSanityYML', "yaml",
                                 :precompile);
        write_class($lib1, 'PMSanityYML', "pmfile");
        make_old($pmfile);
        use_ok 'PMSanityYML';
        is PMSanityYML::value, "yaml", 'Sanity check -- can use .yml';
    }

    # End of sanity tests, real tests start here

    # are new .pm's preferred over old .yml's?
    {
        write_class($lib1, 'YAMLbyAge', "old", :precompile);
        sleep 2;
        write_class($lib1, 'YAMLbyAge', "new");
        use_ok 'YAMLbyAge';
        is YAMLbyAge::value, "new", "New .pm's are preferred to old .yml's";
    }

    # are .pm's earlier in @*INC preferred to .yml's later?
    {
        write_class($lib1, 'YAMLorPMbyINC', "earlier");
        write_class($lib2, 'YAMLorPMbyINC', "later", :precompile);
        use_ok 'YAMLorPMbyINC';
        is YAMLorPMbyINC::value, "earlier",
            q".pm's earlier in @*INC are preferred to .yml's later";
    }

    # are .yml's earlier in @*INC preferred to .yml's later?
    {
        write_class($lib1, 'YAMLbyINC', "earlier", :precompile);
        my $pmfile = write_class($lib2, 'YAMLbyINC', "later", :precompile);
        use_ok 'YAMLbyINC';
        is YAMLbyINC::value, "earlier",
            q".yml's earlier in @*INC are preferred to .yml's later";
    }

    # are .yml's with no matching .pm skipped?
    {
        my $pmfile  = write_class($lib1, 'MissingYAML', "wrong");
        my $ymlfile = precompile(:$pmfile, :destdir($lib1));
        write_class($lib2, 'MissingYAML', "right");
        $pmfile.unlink;
        use_ok 'MissingYAML';
        is MissingYAML::value, "right",
            q".yml's with no matching .pm are skipped";
    }
} # try

diag "Error: $!" if $!;

# XXX - More tempdir workaround
for @files_created { .unlink orelse diag "Couldn't unlink $_" }
for @dirs_created { .rmdir orelse diag "Couldn't rmdir $_" }
