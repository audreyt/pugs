my $perldoc_data = <<'END_PERLDOC';
=table
    The Shoveller   Eddie Stevens     King Arthur's singing shovel   
    Blue Raja       Geoffrey Smith    Master of cutlery              
    Mr Furious      Roy Orson         Ticking time bomb of fury      
    The Bowler      Carol Pinnsler    Haunted bowling ball

END_PERLDOC

my $expected_structure = <<'END_EXPECTED';
errors: []

tree: !!perl/hash:Perl6::Perldoc::Document 
  content: 
    - !!perl/hash:Perl6::Perldoc::Block::pod 
      content: 
        - !!perl/hash:Perl6::Perldoc::Block::table 
          content: 
            - "    The Shoveller   Eddie Stevens     King Arthur's singing shovel   \n    Blue Raja       Geoffrey Smith    Master of cutlery              \n    Mr Furious      Roy Orson         Ticking time bomb of fury      \n    The Bowler      Carol Pinnsler    Haunted bowling ball\n"
          rows: 
            - !!perl/hash:Perl6::Perldoc::Block::table::Row 
              cells: 
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - The Shoveller
                  left: ''
                  right: ''
                  top: ''
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Eddie Stevens
                  header: ''
                  left: ''
                  right: ''
                  top: ''
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - King Arthur's singing shovel
                  header: ''
                  left: ''
                  right: ''
                  top: ''
            - !!perl/hash:Perl6::Perldoc::Block::table::Row 
              cells: 
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Blue Raja
                  header: ''
                  left: ''
                  right: ''
                  top: ''
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Geoffrey Smith
                  header: ''
                  left: ''
                  right: ''
                  top: ''
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Master of cutlery
                  header: ''
                  left: ''
                  right: ''
                  top: ''
            - !!perl/hash:Perl6::Perldoc::Block::table::Row 
              cells: 
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Mr Furious
                  header: ''
                  left: ''
                  right: ''
                  top: ''
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Roy Orson
                  header: ''
                  left: ''
                  right: ''
                  top: ''
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Ticking time bomb of fury
                  header: ''
                  left: ''
                  right: ''
                  top: ''
            - !!perl/hash:Perl6::Perldoc::Block::table::Row 
              cells: 
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - The Bowler
                  header: ''
                  left: ''
                  right: ''
                  top: ''
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Carol Pinnsler
                  header: ''
                  left: ''
                  right: ''
                  top: ''
                - !!perl/hash:Perl6::Perldoc::Block::table::Cell 
                  bottom: ''
                  content: 
                    - !!perl/hash:Perl6::Perldoc::Block::pod 
                      content: 
                        - !!perl/hash:Perl6::Perldoc::Block::para 
                          content: 
                            - Haunted bowling ball
                  header: ''
                  left: ''
                  right: ''
                  top: ''
          typename: table
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
