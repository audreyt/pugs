use v6;
use Test;

# L<S29/"Array"/"=item push">

=begin description 

Push tests

=end description 

plan 42;

# basic push tests
{
    my @push = ();

    is(+@push, 0, 'we have an empty array');

    push(@push, 1);
    is(+@push, 1, 'we have 1 element in the array');
    is(@push[0], 1, 'we found the right element');

    push(@push, 2);
    is(+@push, 2, 'we have 2 elements in the array');
    is(@push[1], 2, 'we found the right element');

    push(@push, 3);
    is(+@push, 3, 'we have 3 element in the array');
    is(@push[2], 3, 'we found the right element');

    push(@push, 4);
    is(+@push, 4, 'we have 4 element in the array');
    is(@push[3], 4, 'we found the right element');
}

# try other variations on calling push()
{
    my @push = ();

    my $val = 100;

    push @push, $val;
    is(+@push, 1, 'we have 1 element in the array');
    is(@push[0], $val, 'push @array, $val worked');

    @push.push(200);
    is(+@push, 2, 'we have 2 elements in the array');
    is(@push[1], 200, '@push.push(200) works');

    @push.push(400);
    is(+@push, 3, 'we have 3 elements in the array');
    is(@push[2], 400, '@push.push(400) works');
}

# try pushing more than one element
{
    my @push = ();

    push @push, (1, 2, 3);
    is(+@push, 3, 'we have 3 elements in the array');
    is(@push[0], 1, 'got the expected element');
    is(@push[1], 2, 'got the expected element');
    is(@push[2], 3, 'got the expected element');

    my @val2 = (4, 5);
    push @push, @val2;  
    is(+@push, 5, 'we have 5 elements in the array');
    is(@push[3], 4, 'got the expected element');
    is(@push[4], 5, 'got the expected element');
    
    push @push, 6, 7, 8;  # push() should be slurpy
    is(+@push, 8, 'we have 8 elements in the array');
    is(@push[5], 6, 'got the expected element');
    is(@push[6], 7, 'got the expected element');    
    is(@push[7], 8, 'got the expected element');        
}

# now for the push() on an uninitialized array issue
{
    my @push;

    push @push, 42;
    is(+@push, 1, 'we have 1 element in the array');
    is(@push[0], 42, 'got the element expected');

    @push.push(2000);
    is(+@push, 2, 'we have 1 element in the array');
    is(@push[0], 42, 'got the element expected');
    is(@push[1], 2000, 'got the element expected');
}

# testing some edge cases
{
    my @push = 0 .. 5;
    is(+@push, 6, 'starting length is 6');
    
    push(@push);
    is(+@push, 6, 'length is still 6');
    
    @push.push();
    is(+@push, 6, 'length is still 6');
}

# testing some error cases
{
    dies_ok({ push()     }, 'push() requires arguments (1)');
    # This one is okay, as push will push 0 elems to a rw arrayref.
    lives_ok({ push([])  }, 'push() requires arguments (2)');
    dies_ok({ 42.push(3) }, '.push should not work on scalars');
    dies_ok({ my @r; @r.push<hi>;  }, '.push<hi> should emit error.');
}

# Push with Inf arrays (waiting on answers to perl6-compiler email)
# {
#     my @push = 1 .. Inf;
#     # best not to uncomment this it just go on forever
#     todo_throws_ok { 'push @push, 10' }, '?? what should this error message be ??', 'cannot push onto a Inf array';
# }

# nested arrayref
{
    my @push;
    push @push, [ 21 .. 25 ];

    is(@push.elems,     1, 'nested arrayref, array length is 1');
    is(@push[0].elems,  5, 'nested arrayref, arrayref length is 5');
    is(@push[0][0],    21, 'nested arrayref, first value is 21');
	#?rakudo skip 'whatever star not implemented'
    is(@push[0][*-1],  25, 'nested arrayref, last value is 25');
}

# vim: syn=perl6
