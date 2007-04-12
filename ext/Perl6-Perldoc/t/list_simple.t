my $perldoc_data = <<'END_PERLDOC';
The seven suspects are:

=item  Happy
=item  Dopey
=item  Sleepy
=item  Bashful
=item  Sneezy
=item  Grumpy
=item  Keyser Soze

END_PERLDOC

my $expected_structure = <<'END_EXPECTED';
errors: []

tree: !!perl/hash:Perl6::Perldoc::Document 
  content: 
    - !!perl/hash:Perl6::Perldoc::Block::pod 
      content: 
        - !!perl/hash:Perl6::Perldoc::Block::para 
            - "The seven suspects are:\n"
        - !!perl/hash:Perl6::Perldoc::Block::list 
          content: 
            - !!perl/hash:Perl6::Perldoc::Block::item 
              content: 
                - "Happy\n"
              style: abbreviated
              typename: item
            - !!perl/hash:Perl6::Perldoc::Block::item 
              content: 
                - "Dopey\n"
              style: abbreviated
              typename: item
            - !!perl/hash:Perl6::Perldoc::Block::item 
              content: 
                - "Sleepy\n"
              style: abbreviated
              typename: item
            - !!perl/hash:Perl6::Perldoc::Block::item 
              content: 
                - "Bashful\n"
              style: abbreviated
              typename: item
            - !!perl/hash:Perl6::Perldoc::Block::item 
              content: 
                - "Sneezy\n"
              style: abbreviated
              typename: item
            - !!perl/hash:Perl6::Perldoc::Block::item 
              content: 
                - "Grumpy\n"
              style: abbreviated
              typename: item
            - !!perl/hash:Perl6::Perldoc::Block::item 
              content: 
                - "Keyser Soze\n"
              style: abbreviated
              typename: item
          level: 1
          style: implicit
          typename: list
      typename: pod
  typename: (document)
warnings: []


END_EXPECTED

use Perl6::Perldoc::Parser;
use Test::More 'no_plan';

sub is_subset {
    my ($found, $expected) = @_;
    my @found    = split /\n/, $found;
    my @expected = split /\n/, $expected;

    while (@found && @expected) {
        if ($found[0] eq $expected[0]) {
            is $found[0], $expected[0], $expected[0];
            shift @found;
            shift @expected;
        }
        else {
            shift @found;
        }
    }
    
    for my $expected (@expected) {
        ok 0, "Missing '$expected'";
    }
}

open my $fh, '<', \$perldoc_data
    or die "Could not open file on test data";

my $representation = Perl6::Perldoc::Parser->parse($fh ,{all_pod=>1});

use YAML::Syck 'Dump';
is_subset Dump($representation), $expected_structure;
