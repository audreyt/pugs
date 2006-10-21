#XXX - bugs
# Flag handling is currently an utter kludge. not even trying with m and s.
# Match objects arent being created for capture groups which are never reached.
# No lookbehind has been implemented at all.
# More.

package main;
use Regexp::Engine::Reentrant::Backtrack;
$bt = Regexp::Engine::Reentrant::Backtrack::MakeStringSearch->new();

package BacktrackDev;
use Filter::Simple sub {
  s/\bFAIL_IF_FAILED\(([^\)]+)\);/FAIL() if FAILED($1);/g;
  s/\bFAIL\(([^\)]{0,0})\)/return undef/g;
  s/\bFAILED\(([^\)]+)\)/(!defined($1)||(!ref($1)&&($1<=0)))/g;
  s/\bTAILCALL\(([^,\)]+)\);/\@_=(Hacks->noop);goto $1;/g; #no
  s/\bTAILCALL\(([^,\)]+),?([^\)]*)\);/\@_=($2);goto $1;/g;
  $_;
};
1;
package NotMain2;
use Regexp::Parser;
use Data::Dumper;
use Regexp::Engine::Reentrant::Match;
BEGIN { BacktrackDev->import; };
use strict;

if($Regexp::Parser::VERSION <= 0.20) {
  eval <<'END';
#line 1 "Regexp::Parser bug fix/workaround"
    # Regexp::Parser bug fix/workaround
    package Regexp::Parser::anyof_class;
    sub visual {
      my $self = shift;
      if (ref $self->{data}) {
	$self->{data}->visual;
      }
      else {
	# The actual bug is in Handlers.pm init() - the \$how 's.
	#join "", "[", $self->{how}, ($self->{neg} ? '^' : ''),
	#     $self->{type}, $self->{how}, "]";
	join "", "[", ${$self->{how}}, ($self->{neg} ? '^' : ''),
	     $self->{type}, ${$self->{how}}, "]";
      }
    }
END
}

{
  package Hacks;

  my $noop;
  $noop = $main::bt->sub_noop;
  sub noop {
    $noop;
  }
  sub concat {
    my($o,$aref)=@_;
    die "bug $aref" if ref($aref) ne 'ARRAY';
    my @a = @$aref;
    return $o->noop if @a == 0;
    return $a[0]->emit if @a == 1;
    my @fs = map { $_->emit } @a;
    my $code1 = ""; my $code2 = "";
    my $code0 = "my \$f0 = \$fs[0]; ";
    for my $i (reverse(1..$#a)) {
      $code0 .= "my \$f$i = \$fs[$i]; ";
      $code1 .= "sub{\@_=";
      $code2 .= ";goto \&\$f$i}";
    }
    my $code = $code0."
#line 2 \"Hacks concat\"
\n sub{my \$cn = \$_[0]; \@_=".$code1."\$cn".$code2.";goto \&\$f0}\n";
    #print $code;
    eval($code) || die "$@";
  }   
  sub mk_ignore_this_node {
    my($o)=@_;
    $o->noop;
  }

  sub emit {
    my $cls = ref($_[0]);
    die "$cls emit() unimplemented\n";
  }
  sub inf {
    1000**1000**1000 #XXX there has to be a better way. :(
  }
}
{
  package Regexp::Parser::__object__;
  @Regexp::Parser::__object__::ISA=qw(Hacks);
}  
{ package simple_raw;
  sub emit {
    my($o)=@_;
    my $re = $o->raw();
    return $main::bt->sub_eat_regexp($re);
  }
}
{
  # \A ^ \B \b \G \Z \z $
  package Regexp::Parser::anchor;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my $re = $o->raw();
    return sub{
      FAIL() if !($X::pos == 0);
      my $c = $_[0]; TAILCALL(&$c,$noop);
    } if $re eq '\A';
    return sub{
      FAIL() if !($X::pos == 0 || substr($X::str,$X::pos-1,1) eq "\n");
      my $c = $_[0]; TAILCALL(&$c,$noop);
    } if $re eq '^';
    return $main::bt->sub_eat_regexp('\B') if $re eq '\B';
    return $main::bt->sub_eat_regexp('\b') if $re eq '\b';
    # \G
    return $main::bt->sub_eat_regexp('\Z') if $re eq '\Z';
    return sub{
      FAIL() if !($X::pos == (length($X::str)));
      my $c = $_[0]; TAILCALL(&$c,$noop);
    } if $re eq '\z';
    return sub{
      FAIL() if !($X::pos == (length($X::str)) || substr($X::str,$X::pos,1) eq "\n");
      my $c = $_[0]; TAILCALL(&$c,$noop);
    } if $re eq '$';
    return sub{
      FAIL(); #XXX posG not implemented
      FAIL() if !($X::pos == $X::posG);
      my $c = $_[0]; TAILCALL(&$c,$noop);
    };
    die "didn't implement $re"
  }
}
{
  # . \C
  package Regexp::Parser::reg_any;
  sub emit { simple_raw::emit(@_) }
}
{
  # \w \W
  package Regexp::Parser::alnum;
  sub emit { simple_raw::emit(@_) }
}
{
  # \s \S
  package Regexp::Parser::space;
  sub emit { simple_raw::emit(@_) }
}
{
  # \d \D
  package Regexp::Parser::digit;
  sub emit { simple_raw::emit(@_) }
}
{
  package Regexp::Parser::anyof;
  sub emit {
    my($o)=@_;
    my $re = $o->visual();
    if($o->{flags} & $o->{rx}->FLAG_i) {
       $re = "(?i)(?:$re)";
    }
    return $main::bt->sub_eat_regexp($re);
  }
}
{
  package Regexp::Parser::anyof_char;
}
{
  package Regexp::Parser::anyof_range;
}
{
  package Regexp::Parser::anyof_class;
}
{
  package Regexp::Parser::anyof_close;
}
{
  package Regexp::Parser::prop;
}
{
  package Regexp::Parser::clump;
}
{
  # |
  package Regexp::Parser::branch;
  sub emit {
    my($o)=@_;
    my(@fs) = map { $o->concat($_) } @{$o->data};
    $main::bt->sub_alt(\@fs);
  }
}
{
  package Regexp::Parser::exact;
  sub emit{
    my($o)=@_;
    my $noop = $o->noop;
    my $s = join("",$o->data);
    my $len = length($s);
    my $pat = $s;
    $pat =~ s/(\W)/\\$1/g;
    $pat = "(?:(?i)(?:$pat))" if ($o->{flags} & $o->{rx}->FLAG_i);
    $main::bt->sub_eat_regexp($pat);
  }
}
{
  package Regexp::Parser::quant;

  # Needed for regexp_try.pl, but... bad idea for development.
#  no warnings "recursion";

  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my($min,$max)= (@$o{'min','max'});
    $min = 0 if $min eq "";
    $max = $o->inf if $max eq "";
    $min += 0; $max += 0; 
    my $f = $o->data->emit;
    $main::bt->sub_repeat($f,$min,$max);
  }
}
{
  # *? +? {,}? - sort of: have to reach down into quant.
  package Regexp::Parser::minmod;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my($min,$max)= (@{$o->data}{'min','max'});
    $min = 0 if $min eq "";
    $max = $o->inf if $max eq "";
    $min += 0; $max += 0; 
    my $f = $o->data->data->emit; # reach down into quant below.
    $main::bt->sub_repeat($f,$min,$max,1);
  }
}
{
  # ( non-capturing
  package Regexp::Parser::group;
  sub emit {
    my($o)=@_;
    my $f = $o->concat( $o->data );
    return $f;
  }
}
{
  # ( capturing
  package Regexp::Parser::open;
  sub emit {
    my($o)=@_;
    my $f = $o->concat( $o->data );
    my $idx = $o->{'nparen'} -1;
    $main::bt->sub_capture_variant1($idx,$f);
  }
}
{
  # ) closing
  package Regexp::Parser::close;
}
{
  # ) for non-captures
  package Regexp::Parser::tail;
}
{
  # \1 (backrefs)
  package Regexp::Parser::ref;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my $idx = $o->{'nparen'} -1;
    sub {
      my $c = $_[0];
      FAIL() if $idx >= @$X::cap;
      my $m = $X::cap->[$idx];
      my $s = defined($m) ? "$m" : "";
      my $pat = $s;
      $pat =~ s/(\W)/\\$1/g;
      $pat = "(?:(?i)(?:$pat))" if($o->{flags} & $o->{rx}->FLAG_i);
      my $ok = substr($X::str,$X::pos) =~ /\A($pat)/;
      FAIL() if !$ok;
      $X::pos += length($1);
      TAILCALL(&$c,$noop);
    };
  }
}
{
  package Regexp::Parser::assertion;
}
{
  # (?=) (?<=)
  package Regexp::Parser::ifmatch;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my $f = $o->concat( $o->data );
    my $dir = $o->{'dir'};
    if($dir>0) {
      sub {
        my $c = $_[0];
        { local($X::pos)=($X::pos);
          my $v = $f->($noop);
          FAIL_IF_FAILED($v);
        }
        TAILCALL(&$c,$noop);
      }
    } else {
      sub {
        my $c = $_[0];
        FAIL() if not &_is_found_backwards($f);
        TAILCALL(&$c,$noop);
      }
    }
  }
  sub _is_found_backwards {
    my($f)=@_;
    my $pos = $X::pos;
    local $X::pos = $X::pos;
    my $at_pos = sub{ FAIL() if $X::pos != $pos; return 1;};
    for(my $i = $X::pos;$i>=0;$i--) {
      $X::pos = $i;
      my $v = $f->($at_pos);
      return 1 if not FAILED($v);
    }
    return 0;
  }
}
{
  # (?!) (?<!)
  package Regexp::Parser::unlessm;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my $f = $o->concat( $o->data );
    my $dir = $o->{'dir'};
    if($dir>0) {
      sub {
        my $c = $_[0];
        my $v;
        { local($X::pos)=($X::pos);
          $v = $f->($noop);
          FAIL() if not FAILED($v);
        }
        TAILCALL(&$c,$noop);
      };
    } else {
      sub {
        my $c = $_[0];
        FAIL() if &Regexp::Parser::ifmatch::_is_found_backwards($f);
        TAILCALL(&$c,$noop);
      };
    }
  }
}
{
  # (?>)
  package Regexp::Parser::suspend;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my $f = $o->concat( $o->data );
    sub {
      my $c = $_[0];
      my $v = $f->($noop);
      FAIL_IF_FAILED($v);
      TAILCALL(&$c,$noop);
    };
  }
}
{
  # (?(n)t|f)
  package Regexp::Parser::ifthen;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
#    die Data::Dumper::Dumper $o;

    my $f_test = $o->data->[0]->emit;
    my $f_then = $o->data->[1]->data->[0][0]->emit;
    my $crufty = $o->data->[1]->data;
    my $f_else = sub{my $c = $_[0]; TAILCALL(&$c,$noop);};
    $f_else = $o->data->[1]->data->[1][0]->emit if @{$o->data->[1]->data} > 1;
    sub {
      my $c = $_[0];
      my $v;
      { local($X::pos)=($X::pos);
        $v = $f_test->($noop);
      }
      if(not FAILED($v)) {
        TAILCALL(&$f_then,$c);
      } else {
        TAILCALL(&$f_else,$c);
      }
    };
  }
}
{
  # the N in (?(N)t|f) when N is a number
  package Regexp::Parser::groupp;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my $idx = $o->{'nparen'} -1;
    sub {
      my $c = $_[0];
      FAIL() if $idx >= @$X::cap;
      my $m = $X::cap->[$idx];
      FAIL() if !$m;
      TAILCALL(&$c,$noop);
    };
  }
}
{
  # (?{ ... })
  package Regexp::Parser::eval;
  sub emit {
    my($o)=@_;
    my $noop = $o->noop;
    my $embedded_code = join("",$o->data);
    my $code = '
#line 2 "in Regexp::Parser::eval"
sub{my $__c__ = $_[0]; '.$embedded_code.'; @_=$noop; goto &$__c__}';
    eval($code) || die "Error compiling (?{$embedded_code}) :\n$@\n";
  }
}
{
  # (??{ ... })
  package Regexp::Parser::logical;
  sub emit { Regexp::Parser::eval::emit(@_) }
}
{
  package Regexp::Parser::flags;
  sub emit {
    my($o)=@_;
    $o->mk_ignore_this_node();
  }
}

{
package Y;
our %rules;
sub dorule {
  my($c,$name,$args)=@_;
  my $noop = Hacks->noop;

  my $ru = $rules{$name};
  if(!defined $ru) {
    warn "Unknown rule '$name'";
    FAIL();
  }

  my $pos = $X::pos;
  my $cap = $X::cap;
  my $m0 = $X::current_match;
  my $m1 = MatchOne->new;
  $$m1->{'RULE'} ||= $name; #EEEP
  $m1->match_set(1,"",[],{},$pos,undef);

  my $rest = sub{
    my $cn = $_[0];
    $$m1->{'match_array'} = $X::cap; #EEEP
    $$m1->{'match_to'} = $X::pos; #EEEP
    $$m1->{'match_string'} = substr($X::str,$pos,$X::pos-$pos);
    local $m0->{$name} = [@{$m0->{$name}||[]}];
    push(@{$m0->{$name}},$m1); #see below
    $X::cap = $cap;
    $X::current_match = $m0;
    TAILCALL(&$cn,$c);
  };

  my $v;
  { local $X::current_match = $m1;
    local $X::cap = [];
    $v = $ru->($rest);
  }
  FAIL_IF_FAILED($v);
  unshift(@{$m0->{$name}},$m1);# sigh,
  #  twice: once for inline code, once for the final Match tree.
  return $v;
}
}
package NotMain;

sub def_rule {
  my($name,$re)=@_;
  my $r = ref($re) ? $re : compile($re);
  die if !defined $r;
  $Y::rules{$name} = $r;
}

sub mk_Match_appender {
  my($f,$name)=@_;
  sub {
    my $c = $_[0];
    my $pos = $X::pos;
    my $cap = $X::cap;
    my $m0 = $X::current_match;
    my $m1 = MatchOne->new;
    $$m1->{'RULE'} ||= $name; #EEEP
    $m1->match_set(1,"",[],{},$pos,undef);

    my $rest = sub{
      my $cn = $_[0];
      $$m1->{'match_array'} = $X::cap; #EEEP
      $$m1->{'match_to'} = $X::pos; #EEEP
      $$m1->{'match_string'} = substr($X::str,$pos,$X::pos-$pos);
      $X::cap = $cap;
      $X::current_match = $m0;
      push(@{$X::cap},$m1);
      TAILCALL(&$cn,$c);
    };

    my $v;
    { local $X::current_match = $m1;
      local $X::cap = [];
      $v = $f->($rest);
    }
    FAIL_IF_FAILED($v);
    unshift(@{$m0},$m1);# sigh, prevents mutation.
    # why twice: once for inline code, once for the final Match tree.
    return $v;
  }
}

my $noop = Hacks->noop;
sub compile {
  my($re)=@_;
  $re = '(?:)' if $re eq ''; #Regexp::Parser bug workaround.
  #print STDERR "COMPILING \"$re\" ",length($re),"\n";
  $re =~ s/<(\w+)([^\>]*)>/(?{\@_=(\$__c__,'$1','$2');goto \&Y::dorule;})/g;
  my $parser = Regexp::Parser->new($re);
  my $n = eval{ $parser->root };
  Carp::confess "compile \"$re\" failed: $@" if !defined $n;
  #print Dumper $n;
  my $r = Hacks->concat($n);
  my $nparens = $parser->nparen;
  return wantarray ? ($r,$nparens) : $r;
}
sub match {
  my($r,$s,$nparen,$beginat,$minlen)=@_;
  my $len = length($s);
  $beginat = 0 if !defined($beginat);
  my $atend = $noop;
  if(defined $minlen) {
    my $min_end = $minlen + $beginat;
    $atend = sub{return undef if $X::pos < $min_end;return 1;}
  }
  for my $start ($beginat..$len) {
    local $X::str = $s;
    local $X::pos = $start;
    local $X::cap = [];
    my $m = MatchOne->new();
    local $X::current_match = $m;
    my $ok = $r->($atend);
    if(not FAILED($ok)) {
      my $a = $X::cap;
      if(defined($nparen) && $nparen > @$a) {
	for my $i (@$a..$nparen) {
          push(@$a,MatchOne->new()->match_set_as_failed);
        }
      }
      for my $am (@$a) {
        $am = MatchOne->new()->match_set_as_failed() if !defined($am);
      }
      $m->match_set(1,substr($X::str,$start,$X::pos-$start),
              $a,\%{$m},$start,$X::pos);
      return $m;
    }
  }
  return MatchOne->new()->match_set_as_failed;
}
sub match_re {
  my($re,$s)=@_;
  my($r,$np) = compile($re);
  my $m = match($r,$s,$np);
  return $m;
}

sub test_target {
  sub{my($mods,$re)=@_;
    $re = "(?$mods)(?:$re)" if $mods;
    my $r = compile($re); sub{my($s)=@_;match($r,$s)}
  };
}

if(@ARGV && $ARGV[0] eq '--test') {
  require './re_tests_match.pl';
  Pkg_re_tests::test(&test_target);
  exit;
}
1;
__END__
