
use v6-alpha;

# See also: parrot/compilers/pge/PGE/Match.pir

# XXX - class name - fix MiniPerl6::Emitter::Token to emit 'MiniPerl6::Runtime::Match' instead
class MiniPerl6::Perl5::Match {
    has $.str;
    has $.array;
    has $.hash;
    has $.result_object;
    has $.from;
    has $.to;
    has $.bool;

    method scalar {
        if $.bool {
            return undef;
        };
        if defined( $.result_object ) {
            return $.result_object;
        };
        return substr( $.str, $.from, ( $.to - $.from ) + 1 );
    };

    method __get_bool {
        return $.bool;
    };
    method __get_int {
        return 0 + self.scalar;
    };
    method __get_number {
        return 0 + self.scalar;
    };
    method __get_string {
        return self.scalar;
    };

# TODO
#use overload (
#    '@{}'    => \&array,
#    '%{}'    => \&hash,
#    '${}'    => \&scalar,
#);
#

}
