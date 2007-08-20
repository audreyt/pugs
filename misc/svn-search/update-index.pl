#!/usr/bin/perl
use warnings;
use strict;

use SVN::Log::Index;
use Data::Dumper;
use POSIX qw(nice);

nice 19;

my $index_file = 'svn_index';

my $idx = SVN::Log::Index->new({ index_path => $index_file });

if (!-e $index_file){
	$idx->create({
			repo_url 		=> 'http://svn.pugscode.org/pugs/',
			analyzer_class 	=> 'KinoSearch::Analysis::PolyAnalyzer',
			analyzer_opts   => [ language => 'en' ],
			overwrite       => 1,
			});
};

$idx->open();

$idx->add({
		start_rev	=> $idx->get_last_indexed_rev,
		end_rev		=> 'HEAD',
		});
