my $p6meta = ::p6opaque.^!CREATE;
$p6meta.^!how() = ::PurePrototypeHow;
$p6meta.^!methods.postcircumfix:<{ }>("add_method") = sub {
    $OUT.print("add_method not implemented yet\n");
};
$p6meta.add_method('HOW',sub {
});
