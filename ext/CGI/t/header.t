use v6-alpha;
use Test;

plan 13;

=pod

More tests for CGI header() function

=cut

use CGI; pass "(dummy instead of broken use_ok)";

my $q = CGI.new;

is($q.header, 
   "Status: 200 OK
Content-Type: text/html

", 'got the header we expected');

# check with positional parameters

is($q.header('text/html', '404 Not Found'), 
   "Status: 404 Not Found
Content-Type: text/html

", 'got the header we expected (using positional args)');

is($q.header('text/xml', '404 Not Found'), 
   "Status: 404 Not Found
Content-Type: text/xml

", 'got the header we expected (using positional args)');

is($q.header('text/xml', '404 Not Found', 'Latin'), 
   "Status: 404 Not Found
Content-Type: text/xml; charset=Latin

", 'got the header we expected (using positional args)');

# test it with named args

is($q.header(charset => 'Latin'), 
   "Status: 200 OK
Content-Type: text/html; charset=Latin

", 'got the header we expected (using named args)');

is($q.header(charset => 'Arabic', status => '500 Internal Server Error'), 
   "Status: 500 Internal Server Error
Content-Type: text/html; charset=Arabic

", 'got the header we expected (using named args)');

is($q.header(type => 'text/xml', charset => 'Chinese', status => '500 Internal Server Error'), 
   "Status: 500 Internal Server Error
Content-Type: text/xml; charset=Chinese

", 'got the header we expected (using named args)');

is $q.header(cookies => "Foo"),
    "Status: 200 OK
Content-Type: text/html
Set-Cookie: Foo

", "single cookie";
is $q.header(cookies => ["Foo", "Bar"]),
    "Status: 200 OK
Content-Type: text/html
Set-Cookie: Foo
Set-Cookie: Bar

", "two cookies";
is $q.header(cookies => ["Foo", "Bar", "Baz"]),
    "Status: 200 OK
Content-Type: text/html
Set-Cookie: Foo
Set-Cookie: Bar
Set-Cookie: Baz

", "three cookies";

is $q.header(cost => "Three smackeroos"),
    "Status: 200 OK
Content-Type: text/html
Cost: Three smackeroos

", 'extra params';

is $q.header(cost => "Three smackeroos", tax_deductible => "Yes"),
    "Status: 200 OK
Content-Type: text/html
Cost: Three smackeroos
Tax-Deductible: Yes

", 'extra params (hyphenation)';
