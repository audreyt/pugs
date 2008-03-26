#!/usr/bin/perl
# A script to help create and run elf_a .
use strict;
use warnings;
require 'elf_a_src/ir_nodes_ref.pl';
require 'elf_a_src/util.pl';

sub main {
  IRNodesRef->load_ir_node_config("./elf_a_src/ir_nodes.config");
  write_ir_nodes();
  write_ast_handlers();
#  write_emit_p5();

  my $files = join(" ",map{"elf_b_src/$_"}qw(
    Match.pm
    ast_to_ir.pl
    ast_handlers.pl
    ir_nodes.p6
    main.p6 ));
  system("./elf_a_create.pl --create-only") == 0 or die "elf_a_create failed\n";
  my $cmd = "./elf_a -x -o ./elf_b $files";
  print $cmd,"\n";
  system($cmd) == 0 or die "Failed to build ./elf_b\n";

  if(@ARGV && $ARGV[0] eq '--create-only') {
    exit(0);
  }
  exec("./elf_b",@ARGV);
  die "Exec failed $!";
}
main();

sub write_ir_nodes {
  my $file = "./elf_b_src/ir_nodes.p6";
  my $code = "#line 2 ir_nodes.p6\n".unindent(<<'  END');
    # Warning: This file is mechanically written.  Your changes will be overwritten.
    package IR0 {
      class Base {
      };
      class Val_Base is Base {
      };
      class Lit_Base is Base {
      };
      class Rule_Base is Base {
      };
      # describe_anything
  END

  for my $node (IRNodesRef->nodes) {
    my($name,@fields)=($node->name,$node->fields);
    my @all = $node->all_fields;
    
    my $base = 'Base';
    $base = "${1}_Base" if $name =~ /([^_]+)_/;
    my $has = join("",map{"has \$.$_;\n        "} @all);
    my $params = join(',',map{"\$$_"}@all);
    my $init = "";
    for my $param (@all) {
      $init .= "\$.$param = \$$param;\n          ";
    }
    my $field_names = join(',',map{"'$_'"}@fields);
    my $field_values = join(',',map{'$.'.$_}@fields);

    $code .= unindent(<<"    END",'  ');
      class $name is $base {
        $has
        method emit(\$emitter) { \$emitter.emit_$name(self) };
        method node_name() { '$name' };
        method field_names() { [$field_names] };
        method field_values() { [$field_values] };
        method describe() {
          @{["'".$name."('~".join("~','~",(map{'self.describe_anything($.'.$_.')'}@fields),"')'")]}
        };
      };
    END
  }
  $code .= unindent(<<'  END');
    }
  END
  text2file($code,$file);
}

sub write_ast_handlers {
  my $file = "./elf_b_src/ast_handlers.pl";
  my @paragraphs = load_paragraphs("./elf_a_src/ast_handlers.config");

  my $code = "#line 2 ast_handlers.pl\n".unindent(<<"  END");
    # Warning: This file is mechanically written.  Your changes will be overwritten.
    package IRBuild {
  END

  my %seen;
  for my $para (@paragraphs) {
    $para =~ /^([\w:]+)\n(.*)/s or die "bug";
    my($name,$body)=($1,$2);
    die "Saw an AST handler for '$name' twice!\n" if $seen{$name}++;

    $body =~ s/\@\{\(\((.*?)\)\)\}/$1.flatten/g;
    $body =~ s/([\'\"])\./$1~/g;
    $body =~ s/\.([\'\"])/~$1/g;
    $body =~ s{\s*=~\s*s/((?:[^\\\/]|\\.)*)/((?:[^\\\/]|\\.)*)/g;}{.re_gsub(/$1/,'$2');}g;
    $body =~ s/^(\s*if)\(/$1 \(/g;

    $body =~ s/(\$m(?:<\w+>)+)/irbuild_ir($1)/g;
    $body =~ s/<(\w+)>/.{'hash'}{'$1'}/g;
    $body =~ s/([A-Z]\w+)\.new\(/IR::$1.new(\$m,/g;
    $body =~ s/\*text\*/(\$m.match_string)/g;
    if($body =~ /\*1\*/) {
      $body =~ s/\*1\*/\$one/g;
      $body = unindent(<<'      END',"  ").$body;
        my $key;
        for $m.{'hash'}.keys.flatten {
          if $_ ne 'match' {
            if $key {
              die("Unexpectedly more than 1 field - dont know which to choose\n")
            }
            $key = $_;
          }
        }
        my $one = irbuild_ir($m.{hash}{$key});
      END
    }

    $code .= unindent(<<"    END","    ");
      \$main::irbuilder.add_constructor('$name', sub (\$m) {
      $body;
      });
    END

  }
  $code .= unindent(<<"  END");
  }
  END
  text2file($code,$file);
}
