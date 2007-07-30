use v6-alpha;

use Test;

=pod

 Hyper operators L<S03/"Hyper operators">

=cut

plan 56;

# L<S03/Hyper operators>
{ # binary infix
        my @r;
        @r = (1, 2, 3) »+« (2, 4, 6);
        my @e = (3, 6, 9);
        is(~@r, ~@e, "hyper-sum two arrays");

        @r = (1, 2, 3) »-« (2, 4, 6);
        @e = (-1, -2, -3);
        is(~@r, ~@e, "hyper-subtract two arrays");

        @r = (1, 2, 3) >>+<< (2, 4, 6);
        @e = (3, 6, 9);
        is(~@r, ~@e, "hyper-sum two arrays ASCII notation");

        @r = (1, 2, 3) >>-<< (2, 4, 6);
        @e = (-1, -2, -3);
        is(~@r, ~@e, "hyper-subtract two arrays ASCII notation");

        @r = (1, 2, 3) »*« (2, 4, 6);
        @e = (2, 8, 18);
        is(~@r, ~@e, "hyper-multiply two arrays");

        @r = (1, 2, 3) >>*<< (2, 4, 6);
        @e = (2, 8, 18);
        is(~@r, ~@e, "hyper-multiply two arrays ASCII notation");

        @r = (1, 2, 3) »x« (3, 2, 1);
        @e = ('111', '22', '3');
        is(~@r, ~@e, "hyper-x two arrays");

        @r = (1, 2, 3) >>x<< (3, 2, 1);
        @e = ('111', '22', '3');
        is(~@r, ~@e, "hyper-x two arrays ASCII notation");

        @r = (1, 2, 3) »xx« (3, 2, 1);
        @e = ((1,1,1), (2,2), (3));
        is(~@r, ~@e, "hyper-xx two arrays");

        @r = (1, 2, 3) >>xx<< (3, 2, 1);
        @e = ((1,1,1), (2,2), (3));
        is(~@r, ~@e, "hyper-xx two arrays ASCII notation");

        @r = (20, 40, 60) »/« (2, 5, 10);
        @e = (10, 8, 6);
        is(~@r, ~@e, "hyper-divide two arrays");

        @r = (20, 40, 60) >>/<< (2, 5, 10);
        @e = (10, 8, 6);
        is(~@r, ~@e, "hyper-divide two arrays ASCII notation");

        @r = (1, 2, 3) »+« (10, 20, 30) »*« (2, 3, 4);
        @e = (21, 62, 123);
        is(~@r, ~@e, "precedence - »+« vs »*«");

        @r = (1, 2, 3) >>+<< (10, 20, 30) >>*<< (2, 3, 4);
        @e = (21, 62, 123);
        is(~@r, ~@e, "precedence - >>+<< vs >>*<< ASCII notation");
};

{ # unary postfix
        my @r = (1, 2, 3);
        try { @r »++ };
        my @e = (2, 3, 4);
        is(~@r, ~@e, "hyper auto increment an array", :todo);

        @r = (1, 2, 3);
        try { @r >>++ };
        @e = (2, 3, 4);
        is(~@r, ~@e, "hyper auto increment an array ASCII notation", :todo);
};

{ # unary prefix
        my @r;
        @r = -« (3, 2, 1);
        my @e = (-3, -2, -1);
        is(~@r, ~@e, "hyper op on assignment/pipeline");

        @r = -<< (3, 2, 1);
        @e = (-3, -2, -1);
        is(~@r, ~@e, "hyper op on assignment/pipeline ASCII notation");
};

{ # dimension upgrade
        my @r;
        @r = (1, 2, 3) »+« 1;
        my @e = (2, 3, 4);
        is(~@r, ~@e, "auto dimension upgrade on rhs");

        @r = (1, 2, 3) >>+<< 1;
        @e = (2, 3, 4);
        is(~@r, ~@e, "auto dimension upgrade on rhs ASCII notation");

        @r = 2 »*« (10, 20, 30);
        @e = (20, 40, 60);
        is(~@r, ~@e, "auto dimension upgrade on lhs");

        @r = 2 >>*<< (10, 20, 30);
        @e = (20, 40, 60);
        is(~@r, ~@e, "auto dimension upgrade on lhs ASCII notation");

        @r = (1,2,3,4) »+« (1,2);
        @e = (2,4,3,4);
        is(~@r, ~@e, "list-level element extension on rhs");
        
        @r = (1,2,3,4) >>+<< (1,2);
        @e = (2,4,3,4);
        is(~@r, ~@e, "list-level element extension on rhs ASCII notation");
        
        @r = (1,2) »+« (1,2,3,4);
        @e = (2,4,3,4);
        is(~@r, ~@e, "list-level element extension on lhs");
        
        @r = (1,2) >>+<< (1,2,3,4);
        @e = (2,4,3,4);
        is(~@r, ~@e, "list-level element extension on lhs ASCII notation");
  
        @r = (1,2,3,4) »+« (1,);
        @e = (2,2,3,4);
        is(~@r, ~@e, "list-level element extension on rhs");
        
        @r = (1,2,3,4) >>+<< (1,);
        @e = (2,2,3,4);
        is(~@r, ~@e, "list-level element extension on rhs ASCII notation");
        
        @r = (1,) »+« (1,2,3,4);
        @e = (2,2,3,4);
        is(~@r, ~@e, "list-level element extension on lhs");
        
        @r = (1,) >>+<< (1,2,3,4);
        @e = (2,2,3,4);
        is(~@r, ~@e, "list-level element extension on lhs ASCII notation");
};

{ # unary postfix with integers
        my @r;
        eval '@r = (1, 4, 9)».sqrt';
        my @e = (1, 2, 3);
        is(~@r, ~@e, "method call on integer list elements");

        my @r;
	eval '@r = (1, 4, 9)>>.sqrt';
        my @e = (1, 2, 3);
        is(~@r, ~@e, "method call on integer list elements (ASCII)");
};

{ # unary postfix again, but with a twist
        my @r;
        eval '@r = ("f", "oo", "bar")».chars';
        my @e = (1, 2, 3);
        is(~@r, ~@e, "method call on list elements");

        eval '@r = ("f", "oo", "bar")>>.chars';
        @e = (1, 2, 3);
        is(~@r, ~@e, "method call on list elements (ASCII)");
};

{ # unary postfix on a user-defined object
	my $t;
	eval 'class FooTest { method bar { 42 } }; $t = FooTest.new.bar';
	is($t, 42, 'plain method call works OK');

        my @r;
	eval 'class FooTest { method bar { 42 } }; @r = (FooTest.new)>>.bar';
	my @e = (42);
	is(~@r, ~@e, "hyper-method-call on list of user-defined objects" :todo);
};

{ # distribution for unary prefix
        my @r;
        @r = -« ([1, 2], [3, [4, 5]]);
        my @e = ([-1, -2], [-3, [-4, -5]]);
        is_deeply(~@r, ~@e, "distribution for unary prefix");

        @r = -<< ([1, 2], [3, [4, 5]]);
        @e = ([-1, -2], [-3, [-4, -5]]);
        is_deeply(~@r, ~@e, "distribution for unary prefix, ASCII");
};

{ # distribution for unary postfix autoincrement
        my @r;
        @r = ([1, 2], [3, [4, 5]]);
        try { @r »++ };
        my @e = ([2, 3], [4, [5, 6]]);
        is_deeply(~@r, ~@e, "distribution for unary postfix autoincr", :todo);

        @r = ([1, 2], [3, [4, 5]]);
        try { @r >>++ };
        @e = ([2, 3], [4, [5, 6]]);
        is_deeply(~@r, ~@e, "distribution for unary postfix autoincr, ASCII", :todo);
};

{ # distribution for binary infix
        my @r;
        @r = (1, 2, [3, 4]) »+« (4, 5, [6, 7]);
        my @e = (5, 7, [9, 11]);
        is_deeply(~@r, ~@e,
                  "distribution for binary infix, same shape");

				
        @r = (1, 2, [3, 4]) >>+<< (4, 5, [6, 7]);
        @e = (5, 7, [9, 11]);
        is_deeply(~@r, ~@e,
                  "distribution for binary infix, same shape, ASCII",
                 );

        @r = (1, 2, [3, 4]) »+« (5, 6, 7);
        @e = (6, 8, [10, 11]);
        is_deeply(~@r, ~@e,
                  "distribution for binary infix, dimension upgrade",
                 );

        @r = (1, 2, [3, 4]) >>+<< (5, 6, 7);
        @e = (6, 8, [10, 11]);
        is_deeply(~@r, ~@e,
                  "distribution for binary infix, dimension upgrade, ASCII",
                 );

        @r = ([1, 2], 3) »+« (4, [5, 6]);
        @e = ([5, 6], [8, 9]);
        is_deeply(~@r, ~@e,
                  "distribution for binary infix, S03 cross-upgrade",
                 );

        @r = ([1, 2], 3) >>+<< (4, [5, 6]);
        @e = ([5, 6], [8, 9]);
        is_deeply(~@r, ~@e,
                  "distribution for binary infix, S03 cross-upgrade, ASCII",
                 );
};

{ # regression test, ensure that hyper works on arrays
        my @r1;
        my @r2;
        my @e1 = (2, 4, 6);
        my @e2 = (2, 3, 4);
        my @a = (1, 2, 3);
        @r1 = @a >>+<< @a;
        @r2 = @a >>+<< 1;
        is(~@r1, ~@e1, "hyper op works on variables, too.");
        is(~@r2, ~@e2, "hyper op and correctly promotes scalars");
};


# mixed hyper and reduce metaops -
# this unveils a spec bug as << recurses into arrays and [+] never gets applied,
# so we disable the entire chunk for now.
=todo unspecced

    is ~([+]<< ([1,2,3], [4,5,6])), "6 15", "mixed hyper and reduce metaop ([+]<<) works";
    ## XXX: Test for [+]<<<< - This is unspecced, commenting it out
    #is ~([+]<<<< ([[1,2],[3,4]],[[5,6],[7,8]])), "3 7 11 15",
    #  "mixed double hyper and reduce metaop ([+]<<<<) works";

    is ~([+]« [1,2,3], [4,5,6]), "6 15",
      "mixed Unicode hyper and reduce metaop ([+]«) works";

=cut

{ # hyper dereferencing
    my @array = (
        { key => 'val' },
        { key => 'val' },
        { key => 'val' }
    );

    my $full = join '', eval '@array>>.<key>';
    is($full, 'valvalval', 'hyper-dereference an array',:todo);

    my $part = join '', eval '@array[0,1]>>.<key>';
    is($part, 'valval', 'hyper-dereference an array slice',:todo);
}

{ # junction hyper -- regression?
    my @a = 1..3;
    my @b = 4..6;
    ok eval('@a »|« @b; 1'), '»|« hyperjunction evals', :todo<feature>;
    ok eval('@a >>|<< @b; 1'), '>>|<< hyperjunction evals, ASCII',
        :todo<feature>;
    ok eval('@a »&« @b; 1'), '»&« hyperjunction evals', :todo<feature>;
    ok eval('@a >>&<< @b; 1'), '»&« hyperjunction evals, ASCII',
        :todo<feature>;
    is eval('(@a »|« @b).perl'), (1|4,2|5,3|6).perl,
        '»|« returns correct values', :todo<feature>;
    is eval('(@a »&« @b).perl'), (1&4,2&5,3&6).perl,
        '»&« returns correct values', :todo<feature>;
}
