use v6-alpha;

use Test;

# L<S29/Str/"=item split">

# XXX - this needs to be updated when Str.split(Str) works again
# this test really wants is_deeply()
plan 145;

# split on an empty string

my %ords = (
  1 => 'first',
  2 => 'second',
  3 => 'third',
  4 => 'fourth',
  5 => 'fifth',
  6 => 'sixth',
  7 => 'seventh',
  8 => 'eighth',
  9 => 'ninth',
);

sub split_test(@splitted, @expected, Str $desc, $todo = 0) {
  is +@splitted, +@expected,
     "split created the correct value amount for: $desc", :todo($todo);
  is @splitted[$_], @expected[$_],
     "the %ords{$_ + 1} value matched for: $desc", :todo($todo)
    for 0 .. @splitted.end;
  is_deeply [~<< @splitted], [~<< @expected], "values match", :todo($todo); 
}

split_test split("", "forty-two"),
           qw/f o r t y - t w o/,
           q{split "", Str};

split_test "forty-two".comb(/./),
           qw/f o r t y - t w o/,
           q{Str.comb(/./)};

split_test "forty two".comb(/./),
           (qw/f o r t y/, ' ', qw/t w o/),
           q{Str.comb(/./)};

# split on a space
split_test split(' ', 'split this string'),
           qw/split this string/,
           q{split ' ', Str};

split_test 'split this string'.comb,
           <split this string>,
           q{Str.comb};

# split on a single character delimiter
split_test split('$', 'try$this$string'),
           qw/try this string/,
           q{split '$', Str};

# split on a multi-character delimiter
split_test split(', ', "comma, separated, values"),
           qw/comma separated values/,
           q{split ', ', Str};

# split on a variable delimiter

my $delimiter = '::';
split_test split($delimiter, "Perl6::Pugs::Test"),
           qw/Perl6 Pugs Test/,
           q{split $delimiter, Str};

# split with a reg-exp
split_test split(rx:Perl5 {,}, "split,me"),
           qw/split me/,
           q/split rx:Perl5 {,}, Str/;

# split on multiple space characters
split_test split(rx:Perl5 {\s+}, "Hello World    Goodbye   Mars"),
           qw/Hello World Goodbye Mars/,
           q/split rx:Perl5 {\s+}, Str/;

split_test split(rx:Perl5 {(\s+)}, "Hello test"),
           ('Hello', ("Hello test" ~~ rx:Perl5 {(\s+)}), 'test'),
           q/split rx:Perl5 {(\s+)}, Str/;

split_test "to be || ! to be".split(' '),
           qw/to be || ! to be/,
           q/Str.split(' ')/;

split_test "this will be split".split(rx:Perl5 { }),
           qw/this will be split/,
           q/Str.split(rx:Perl5 { })/;

# split on multiple space characters
diag "here";
split_test split(rx:Perl5 {\s+}, "Hello World    Goodbye   Mars", 3),
           ( qw/Hello World/, "Goodbye   Mars" ),
           q/split rx:Perl5 {\s+}, Str, limit/;

split_test split(" ", "Hello World    Goodbye   Mars", 3),
           ( qw/Hello World/, "   Goodbye   Mars" ),
           q/split " ", Str, limit/;

split_test  "Hello World    Goodbye   Mars".split(rx:Perl5 {\s+}, 3),
           ( qw/Hello World/, "Goodbye   Mars" ),
           q/Str.split(rx:Perl5 {\s+}, limit)/;

split_test  "Hello World    Goodbye   Mars".split(" ", 3),
           ( qw/Hello World/, "   Goodbye   Mars" ),
           q/Str.split(" ", limit)/;

split_test  "Word".split("", 3), qw/W o rd/,
           q/Str.split("", limit)/;

# XXX: Here Pugs emulates p5 default awk field splitting behaviour.
split_test  "  abc  def  ".split(), qw/abc def/,
           q/Str.split()/;
# ... yet how do you do this with p6 function form of split?
# Note that split(' ', $x) special casing of ' ' pattern (a la p5)
# is not implemented in Pugs. Should it be?

# This one returns an empty list
split_test  "".split(), (),
           q/"".split()/;

# ... yet this one does not (different to p5).
# blessed by $Larry at Message-ID: <20060118191046.GB32562@wall.org>
split_test  "".split(':'), (""),
           q/"".split(':')/;

# using /.../
split_test "a.b".split(/\./), <a b>,
           q{"a.b".split(/\./)};

split_test "abcd".split(/<null>/), <a b c d>,
           q{"abcd".split(/<null>/)};

{
  ' ' ~~ /(\s)/;
  
  if $0 eq ' ' {
    split_test "foo bar baz".split(/<prior>/), <foo bar baz>,
             q{"foo bar baz".split(/<prior>/)};
  } else {
    skip q{' ' ~~ /\s/ did not result in ' '};
  }
}
