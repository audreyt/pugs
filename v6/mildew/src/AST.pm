use utf8;
{
package AST;
my $id=0;
sub unique_id {
    '$id'.$id++;
}
my $lab = 0;
sub unique_label {
    'lab'.$lab++;
}
sub indent {
    my $x = shift;
    my $i = shift || 1;
    my $s = '    ' x $i;
    $x =~ s/^/$s/mg;
    $x;
}
}
package AST::Base;
use Moose;
sub emit {
    my $self = shift;
    my $id = AST::unique_id;
    $AST::CODE .= do {local $AST::CODE='';$AST::CODE . $self->m0ld($id)};
    return $id;

}
sub emit_ {
    local $AST::CODE = '';
    my ($self,$ret) = @_;
    my $mold = $self->m0ld($ret);
    $AST::CODE . $mold;
}
sub pretty {
    use YAML::XS;
    my $yaml = Dump($_[0]);
    $yaml;
}

package AST::If;
use Moose;
extends 'AST::Base';
has 'cond' => (is => 'ro');
has 'then' => (is => 'ro');
has 'else' => (is => 'ro');
has 'elsif' => (is => 'ro');
sub m0ld {
    my ($self) = @_;
    my $id_cond = AST::unique_id;
    my $id_then = AST::unique_id;
    my $id_else = AST::unique_id;
    my $label_then = AST::unique_label;
    my $label_else = AST::unique_label;
    my $label_endif = AST::unique_label;
    my $cond = $self->cond->m0ld($id_cond);
    my $then = $self->then->m0ld($id_then);
    my $else = 'noop;';
    if ($self->else) {
        $else = $self->else->m0ld($id_else);
    }
    my $elsifs = '';
    if ($self->elsif) {
        foreach my $part (@{$self->{elsif}}) {
            my $id_elsif_cond = AST::unique_id;
            my $id_elsif_then = AST::unique_id;
            my $label_elsif_then = AST::unique_label;
            my $label_elsif_else = AST::unique_label;
            my $elsif_cond = $part->cond->m0ld($id_elsif_cond);
            my $elsif_then = $part->then->m0ld($id_elsif_then);
            $elsifs .= $elsif_cond."\n".
              'my '.$id_elsif_cond.'_val = '.$id_elsif_cond.'."FETCH"();'."\n".
              'my '.$id_elsif_cond.'_bool = '.$id_elsif_cond.'_val."true"();'."\n".
              'if '.$id_elsif_cond.'_bool { goto '.$label_elsif_then.' } else { goto '.$label_elsif_else.' };'."\n".
              $label_elsif_then.':'."\n".
              $elsif_then."\n".
              'goto '.$label_endif.';'."\n".
              $label_elsif_else.': noop;'."\n"
        }
    }

    $cond."\n".
    'my '.$id_cond.'_val = '.$id_cond.'."FETCH"();'."\n".
    'my '.$id_cond.'_bool = '.$id_cond.'_val."true"();'."\n".
    'if '.$id_cond.'_bool { goto '.$label_then.' } else { goto '.$label_else.' };'."\n".
    $label_then.':'."\n".
    $then."\n".
    'goto '.$label_endif.';'."\n".
    $label_else.':'."\n".
    $elsifs.
    $else."\n".
    $label_endif.': noop;'."\n"
}
sub pretty {
    my ($self) = @_;
    'if ' . $self->cond->pretty . " {\n"
        . AST::indent($self->then->pretty) . "\n"
    . "}\n"
}

package AST::Block;
use Moose;
extends 'AST::Base';
has 'stmts' => (is=>'ro');
has 'regs' => (is=>'ro',default=>sub {[]});
sub m0ld {
    my ($self,$ret) = @_;
    "my $ret = mold {\n"
        . join('',map {'my $'.$_.";\n"} @{$self->regs})
        . join("",map { $_->emit_('$void') } @{$self->stmts})
    . "};\n";
}
sub terminate_stmt {
    my $stmt = shift;
    return $stmt . ";\n" unless $stmt =~ /(\n|;|})$/;
    return $stmt;
}
sub pretty {
    use Data::Dump::Streamer;
    my $self = shift;
    "mold \{\n". AST::indent(
        join('',map {'my $'.$_.";\n"} @{$self->regs})
        . join("",map { terminate_stmt $_->pretty } @{$self->stmts})
    ) . "\}"
}

package AST::Comment;
use Moose;
extends 'AST::Base';
has 'comment' => (is=>'ro');
sub m0ld {
    my ($self,$ret) = @_;
    join("",map {"#".$_."\n"} split(/\n/,$self->comment));
}

package AST::Label;
use Moose;
extends 'AST::Base';
has 'identifier';
has 'stmt';

package AST::Named;
use Moose;
extends 'AST::Base';
has 'key' => (is=>'ro');
has 'value' => (is=>'ro');

sub emit {
    my $self = shift;
    return ":".$self->key->emit."(".$self->value->emit.")";
}
sub m0ld {
    die "method m0ld is not supported on AST::Named\n"
}

sub pretty {
    my $self = shift;
    $self->key->pretty . " => " . $self->value->pretty;
}

package AST::Call;
use Moose;
extends 'AST::Base';
has 'capture' => (is=>'ro');
has 'identifier' => (is=>'ro');
sub arguments {
    my $self = shift;
    my @args = @{$self->capture->positional};
    my @named = @{$self->capture->named};
    while (@named) {
        push (@args,AST::Named->new(key=>shift @named,value=>shift @named));
    }
    @args;
}
sub m0ld {
    my ($self,$ret) = @_;
    if ($self->capture->isa("AST::Capture")) {
        "my $ret = "
        . $self->capture->invocant->emit
        . "." . $self->identifier->emit
        . "(" . join(',', map {$_->emit} $self->arguments) . ")" . ";\n";
    } else {
        die 'unimplemented';
    }
}
sub pretty {
    my $self = shift;

    my $identifier;
    if ($self->identifier->isa("AST::StringConstant")) {
        $identifier = $self->identifier->value;
    } else {
        $identifier = $self->identifier->pretty;
    }

    my $arguments = '';
    if (my @arguments = $self->arguments) {
        $arguments = "(" . join(',',map {$_->pretty} $self->arguments) . ")";
    }

    if ($self->capture->isa("AST::Capture")) {
        $self->capture->invocant->pretty . "." . $identifier .  $arguments;
    } else {
        $self->SUPER::pretty;
    }

}

package AST::MetaCall;
use Moose;
extends 'AST::Call';

sub m0ld {
    my ($self, $ret) = @_;

    if ($self->capture->isa("AST::Capture")) {
        my $id_inv = $self->capture->invocant->emit;
        my $id_how = AST::unique_id;

        'my '.$id_how.'_cont = '.$id_inv.'."^!how"();'."\n".
        'my '.$id_how.' = '.$id_how.'_cont."FETCH"();'."\n".
        'my '.$ret.' = '.$id_how.'.'.$self->identifier->emit.
         '(' . join(',', $id_inv, map {$_->emit} $self->arguments) . ');'."\n";
    } else {
        die 'unimplemented';
    }
}

package AST::Package;
use Moose;
has 'name'  => (is=>'ro');
has 'sym'   => (is=>'ro');
has 'block' => (is=>'ro');
extends 'AST::Base';

sub m0ld {
    my $self = shift;
    my $id_package_scope = AST::unique_id;
    my $id_package_val = AST::unique_id;
    my $id_proto_val = AST::unique_id;
    my $id_mold = AST::unique_id;
    my $id_how = AST::unique_id;
    my $id_type_sub = AST::unique_id;

    my $how_type = '';
    if ($self->sym eq 'knowhow') {
        $how_type = 'PurePrototypeHow';
    } elsif ($self->sym eq 'class') {
        $how_type = 'ClassHOW';
    } else {
        die 'unimplemented';
    }

    'my '.$id_how.'_cont = $scope."lookup"("'.$how_type.'");'."\n".
    'my '.$id_how.' = '.$id_how.'_cont."FETCH"();'."\n".

    # initialize the package
    'my '.$id_package_val.'_proto_cont = $scope."lookup"("Package");'."\n".
    'my '.$id_package_val.'_proto = '.$id_package_val.'_proto_cont."FETCH"();'."\n".
    'my '.$id_package_val.' = '.$id_package_val.'_proto."new"();'."\n".
    'my '.$id_package_val.'_name_cont = '.$id_package_val.'."name"();'."\n".
    '$void = '.$id_package_val.'_name_cont."STORE"("'.$self->name.'");'."\n".

    # initialize the protoobject
    'my '.$id_proto_val.'_proto_cont = $scope."lookup"("p6opaque");'."\n".
    'my '.$id_proto_val.'_proto = '.$id_proto_val.'_proto_cont."FETCH"();'."\n".
    'my '.$id_proto_val.' = '.$id_proto_val.'_proto."^!CREATE"();'."\n".

    # store this protoobject in the current scope using its name
    'my '.$id_package_scope.'_outer_p = $scope."postcircumfix:{ }"("'.$self->name.'");'."\n".
    '$void = '.$id_package_scope.'_outer_p."STORE"('.$id_proto_val.');'."\n".

    # creates the package lexical scope and make it an inner scope
    'my '.$id_package_scope.' = ¢SMOP__S1P__LexicalScope."new"();'."\n".
    'my '.$id_package_scope.'_outer = '.$id_package_scope.'."outer"();'."\n".
    '$void = '.$id_package_scope.'_outer."STORE"($scope);'."\n".

    # store the package in $?PACKAGE
    'my '.$id_package_val.'_pp = '.$id_package_scope.'."postcircumfix:{ }"("$?PACKAGE");'."\n".
    '$void = '.$id_package_val.'_pp."STORE"('.$id_package_val.');'."\n".

    # store the protoobject in $?CLASS
    'my '.$id_package_scope.'_p = '.$id_package_scope.'."postcircumfix:{ }"("$?CLASS");'."\n".
    '$void = '.$id_package_scope.'_p."STORE"('.$id_proto_val.');'."\n".

    # set the how
    'my '.$id_proto_val.'_how_cont = '.$id_proto_val.'."^!how"();'."\n".
    '$void = '.$id_proto_val.'_how_cont."STORE"('.$id_how.');'."\n".

    # set the who
    'my '.$id_proto_val.'_who_cont = '.$id_proto_val.'."^!who"();'."\n".
    '$void = '.$id_proto_val.'_who_cont."STORE"('.$id_package_val.');'."\n".

    # run the init code
    $self->block->m0ld($id_mold).
    'my '.$id_mold.'_code_proto_cont = $scope."lookup"("Code");'."\n".
    'my '.$id_mold.'_code_proto = '.$id_mold.'_code_proto_cont."FETCH"();'."\n".
    'my '.$id_mold.'_code = '.$id_mold.'_code_proto."new"(:"outer"('.$id_package_scope.'),:"mold"('.$id_mold.'));'."\n".
    'my '.$id_mold.'_capture = ¢SMOP__S1P__Capturize."capturize"();'."\n".
    '$void = '.$id_mold.'_code."postcircumfix:( )"('.$id_mold.'_capture);'."\n".

    # store a sub of the same name in the current scope that returns the proper package
    'my '.$id_type_sub.' = '.$id_mold.'_code_proto."new"(:"outer"($scope),:"mold"(mold {'."\n".
    'my $interpreter;'."\n".
    'my $scope;'."\n".
    'my $type = $scope."lookup"("'.$self->name.'");'."\n".
    'my $continuation = $interpreter."continuation"();'."\n".
    'my $back = $continuation."back"();'."\n".
    'my $void = $back."setr"($type);'."\n".
    '$void = $interpreter."goto"($back);'."\n".
    '}));'."\n".
    $id_package_scope.'_outer_p = $scope."postcircumfix:{ }"("&'.$self->name.'");'."\n".
    '$void = '.$id_package_scope.'_outer_p."STORE"('.$id_type_sub.');'."\n"

}

package AST::IntegerConstant;
use Moose;
has 'value' => (is=>'ro');
extends 'AST::Base';
sub m0ld {
    my ($self,$ret) = @_;
    "my $ret = ".$self->value.";\n";
}
sub pretty {
    my $self = shift;
    $self->value
}

package AST::StringConstant;
use Moose;
extends 'AST::Base';
has 'value' => (is=>'ro');
sub m0ld {
    my ($self,$ret) = @_;
    #XXX metachars
    "my $ret = \"".$self->value."\";\n";
}
sub pretty {
    #XXX metachars
    my $self = shift;
    '"' . $self->value . '"'
}

package AST::Reg;
use Moose;
extends 'AST::Base';
has 'name' => (is=>'ro');
sub emit {
    my $self = shift;
    $self->name;
}
sub m0ld {
    my ($self,$ret) = @_;
    "my $ret = ".$self->name.";\n";
}
sub pretty {
    #XXX metachars
    my $self = shift;
    $self->name;
}

package AST::Capture;
use Moose;
has 'invocant' => (is=>'ro');
has 'positional' => (is=>'ro',default=>sub {[]});
has 'named' => (is=>'ro',default=>sub {[]});
has 'ctx' => (is=>'ro');
1;
