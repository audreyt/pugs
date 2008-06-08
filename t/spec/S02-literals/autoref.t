use v6;
use Test;

# L<S02/"Literals"/"In scalar context, though, the implied parentheses are not removed">

=begin description

 Tests testing that automatical referentiation (e.g. $arrayref = @array)
 works. To be more detalled, things tested are:
 * Implicit & explicit referentiation of arrays & hashes in assignment
 * Implicit & explicit referentiation of arrays & hashes in assignment to an
   array & hash element
 * Implicit & explicit referentiation of array&hashes&array literals&arrayref
   literals&hashref literals in pair creation with key => ... and :key(...)
   and ... => key.

=end description

plan 57;

# Implicit referentiation of arrays in assignment
{
    my @array = <a b c>;
    my $ref   = @array;

    is ~$ref, "a b c", '$arrayref = @array works (1)';
    is +$ref,       3, '$arrayref = @array works (2)';
}

# Explicit referentiation of arrays in assignment
#?rakudo skip "prefix:<\\> not implemented"
{
    my @array = <a b c>;
    my $ref   = \@array;

    is ~$ref, "a b c", '$arrayref = \@array works (1)';
    is +$ref,       3, '$arrayref = \@array works (2)';
}

# Implicit referentiation of hashes in assignment
{
    my %hash = (a => 1, b => 2, c => 3);
    my $ref  = %hash;

    is ~$ref.values.sort, "1 2 3", '$hashref = %hash works (1)';
    is +$ref.values,            3, '$hashref = %hash works (2)';
}

# Explicit referentiation of hashes in assignment
#?rakudo skip "prefix:<\\> not implemented"
{
    my %hash = (a => 1, b => 2, c => 3);
    my $ref  = \%hash;

    is ~$ref.values.sort, "1 2 3", '$hashref = \%hash works (1)';
    is +$ref.values,            3, '$hashref = \%hash works (2)';
}

# Implicit referentiation of arrays in assignment to an array element
{
    my @array = <a b c>;
    my @other;
    @other[1] = @array;

    is ~@other,    " a b c", '@other[$idx] = @array works (1)';
    is +@other,           2, '@other[$idx] = @array works (2)';
    is +@other[1],        3, '@other[$idx] = @array works (3)';
}

# Explicit referentiation of arrays in assignment to an array element
#?rakudo skip "prefix:<\\> not implemented"
{
    my @array = <a b c>;
    my @other;
    @other[1] = \@array;

    is ~@other, " a b c", '@other[$idx] = \@array works (1)';
    is +@other,        2, '@other[$idx] = \@array works (2)';
    is +@other[1],     3, '@other[$idx] = \@array works (3)';
}

# Implicit referentiation of hashes in assignment to an array element
{
    my %hash = (a => 1, b => 2, c => 3);
    my @other;
    @other[1] = %hash;

    is +@other,    2, '@other[$idx] = %hash works (1)';
    is +@other[1], 3, '@other[$idx] = %hash works (2)';
}

# Explicit referentiation of hashes in assignment to an array element
#?rakudo skip "prefix:<\> not implemented"
{
    my %hash = (a => 1, b => 2, c => 3);
    my @other;
    @other[1] = \%hash;

    is +@other,    2, '@other[$idx] = \%hash works (1)';
    is +@other[1], 3, '@other[$idx] = \%hash works (2)';
}

# Implicit referentiation of arrays in assignment to a hash element
{
    my @array = <a b c>;
    my %other;
    %other<a> = @array;

    is +%other,    1, '%other[$key] = @array works (1)';
    is +%other<a>, 3, '%other[$key] = @array works (2)';
}

# Explicit referentiation of arrays in assignment to a hash element
#?rakudo skip "prefix:<\\> not implemented"
{
    my @array = <a b c>;
    my %other;
    %other<a> = \@array;

    is +%other,    1, '%other[$key] = \@array works (1)';
    is +%other<a>, 3, '%other[$key] = \@array works (2)';
}

# Implicit referentiation of hashes in assignment to a hash element
{
    my %hash = (a => 1, b => 2, c => 3);
    my %other;
    %other<a> = %hash;

    is +%other,    1, '%other[$key] = %hash works (1)';
    is +%other<a>, 3, '%other[$key] = %hash works (2)';
}

# Explicit referentiation of hashes in assignment to a hash element
#?rakudo skip "prefix:<\\> not implemented"
{
    my %hash = (a => 1, b => 2, c => 3);
    my %other;
    %other<a> = \%hash;

    is +%other,    1, '%other[$key] = \%hash works (1)';
    is +%other<a>, 3, '%other[$key] = \%hash works (2)';
}

# Implicit referentiation of arrays in pair creation with key => ...
{
    my @array = <a b c>;
    my $pair  = (key => @array);

    is ~$pair.value, "a b c", '(key => @array) works (1)';
    is +$pair.value,       3, '(key => @array) works (2)';
}

# Explicit referentiation of arrays in pair creation with key => ...
#?rakudo skip "prefix:<\\> not implemented"
{
    my @array = <a b c>;
    my $pair  = (key => \@array);

    is ~$pair.value, "a b c", '(key => \@array) works (1)';
    is +$pair.value,       3, '(key => \@array) works (2)';
}

# Implicit referentiation of hashes in pair creation with key => ...
{
    my %hash = (a => 1, b => 2, c => 3);
    my $pair = (key => %hash);

    is ~$pair.value.values.sort, "1 2 3", '(key => %hash) works (1)';
    is +$pair.value.values,            3, '(key => %hash) works (2)';
}

# Explicit referentiation of hashes in pair creation with key => ...
#?rakudo skip "prefix:<\\> not implemented"
{
    my %hash = (a => 1, b => 2, c => 3);
    my $pair = (key => \%hash);

    is ~$pair.value.values.sort, "1 2 3", '(key => \%hash) works (1)';
    is +$pair.value.values,            3, '(key => \%hash) works (2)';
}

# Implicit referentiation of arrays in pair creation with :key(...)
{
    my @array = <a b c>;
    my $pair  = (:key(@array));

    is ~$pair.value, "a b c", '(:key(@array)) works (1)';
    is +$pair.value,       3, '(:key(@array)) works (2)';
}

# Explicit referentiation of arrays in pair creation with :key(...)
#?rakudo skip "prefix:<\\> not implemented"
{
    my @array = <a b c>;
    my $pair  = (:key(\@array));

    is ~$pair.value, "a b c", '(:key(\@array)) works (1)';
    is +$pair.value,       3, '(:key(\@array)) works (2)';
}

# Implicit referentiation of hashes in pair creation with :key(...)
{
    my %hash = (a => 1, b => 2, c => 3);
    my $pair = (:key(%hash));

    is ~$pair.value.values.sort, "1 2 3", '(:key(%hash)) works (1)';
    is +$pair.value.values,            3, '(:key(%hash)) works (2)';
}

# Explicit referentiation of hashes in pair creation with :key(...)
#?rakudo skip "prefix:<\\> not implemented"
{
    my %hash = (a => 1, b => 2, c => 3);
    my $pair = (:key(\%hash));

    is ~$pair.value.values.sort, "1 2 3", '(:key(\%hash)) works (1)';
    is +$pair.value.values,            3, '(:key(\%hash)) works (2)';
}

# Implicit referentiation of array literals in pair creation with key => ...
{
    my $pair  = (key => <a b c>);

    is ~$pair.value, "a b c", '(key => <...>) works (1)';
    is +$pair.value,       3, '(key => <...>) works (2)';
}

# Arrayref literals in pair creation with key => ...
{
    my $pair  = (key => [<a b c>]);

    is ~$pair.value, "a b c", '(key => [<...>]) works (1)';
    is +$pair.value,       3, '(key => [<...>]) works (2)';
}

# Hashref literals in pair creation with key => ...
#?rakudo skip '{} hash composer not implemented'
{
    my $pair  = (key => { a => 1, b => 2 });

    is +$pair.value, 2, '(key => {...}) works';
}

# Implicit referentiation of array literals in pair creation with :key(...)
{
    my $pair  = (:key(<a b c>));

    is ~$pair.value, "a b c", '(:key(<...>)) works (1)';
    is +$pair.value,       3, '(:key(<...>)) works (2)';
}

# Arrayref literals in pair creation with :key(...)
{
    my $pair  = (:key([<a b c>]));

    is ~$pair.value, "a b c", '(:key([<...>])) works (1)';
    is +$pair.value,       3, '(:key([<...>])) works (2)';
}

# Hashref literals in pair creation with :key(...)
#?rakudo skip '{} hash composer not implemented'
{
    my $pair  = (:key({ a => 1, b => 2 }));

    is +$pair.value, 2, '(:key({...})) works';
}

# Implicit referentiation of array literals in pair creation with ... => "value"
{
    my $pair  = (<a b c> => "value");

    is ~$pair.key, "a b c", '(<...> => "value") works (1)';
    is +$pair.key,       3, '(<...> => "value") works (2)';
}

# Arrayref literals in pair creation with ... => "value"
{
    my $pair  = ([<a b c>] => "value");

    is ~$pair.key, "a b c", '([<...>] => "value") works (1)';
    is +$pair.key,       3, '([<...>] => "value") works (2)';
}

# Hashref literals in pair creation with ... => "value"
#?rakudo skip '{} hash composer not implemented'
{
    my $pair  = ({ a => 1, b => 2 } => "value");

    is +$pair.key, 2, '({...} => "value") works';
}
