package PugsConfig;
use strict;
use warnings;
use Config;
use File::Spec;

sub pugs_install_libs {
    my $config = set_pugs_config_values();
    +{
        archlib => $config->{archlib},
        privlib => $config->{privlib},
        sitearch => $config->{sitearch},
        sitelib => $config->{sitelib},
    };
}

sub set_pugs_config_values {
    my $config = {
        perl_revision   => '6',
        perl_version    => '0',
        perl_subversion => '0',

        osname    => $Config{osname},
        pager     => $Config{pager},
        prefix    => $Config{prefix},
        archname  => $Config{archname},
        exe_ext   => $Config{exe_ext},

        scriptdir => $Config{scriptdir},
        bin       => $Config{bin},
        sitebin   => $Config{sitebin},

        installscript  => $Config{installscript},
        installbin     => $Config{installbin},
        installsitebin => $Config{installsitebin},
    };

    add_path(archlib         => $config); 
    add_path(privlib         => $config); 
    add_path(sitearch        => $config); 
    add_path(sitelib         => $config); 

    add_path(installarchlib  => $config); 
    add_path(installprivlib  => $config); 
    add_path(installsitearch => $config); 
    add_path(installsitelib  => $config); 

    $config->{pugspath} =
      File::Spec->catfile($config->{bin}, "pugs$config->{exe_ext}");

    return $config;
}

sub add_path {
    my ($name, $config) = @_;
    my $path = $Config{$name} || '';
    $path =~ s/([\/\\])[^\/\\]*(perl)[^\/\\]*([\/\\]?)/$1${2}6$3/i;
    $path =~ s/\/\d+\.\d+\.\d+//g;
    $config->{$name} = $path;
}

sub write_config_module {
    my $config = set_pugs_config_values();
    my $template = do { local $/; <DATA> };

    my $all_fields = join ",\n    ", map {
        "config_$_";
    } sort keys %$config;
    $template =~ s/#all_fields#/$all_fields/;

    my $all_definitions = join '', map {
        my $name = $_;
        my $value = $config->{$name};
	$value =~ s{\\}{\\\\}g;
        qq{config_$name = "$value"\n};
    } sort keys %$config;
    $template =~ s/#all_definitions#/$all_definitions/;

    print $template;
}

1;

__DATA__
{-# OPTIONS -fglasgow-exts #-}

{-
    Pugs System Configuration.

    Alive without breath;
    as cold as death;
    never thirsting, ever drinking;
    clad in mail, never clinking.
-}

{-
    *** NOTE ***
    DO NOT EDIT THIS FILE.
    This module is generated by util/generate_config.
-}

module Config (
    #all_fields#
) where

#all_definitions#
