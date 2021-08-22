use util;
use snake-case;
use typemap;
use type-info;

our class AbstractFunction {

    has @.comments;
    has Bool $.const is required;
    has $.rt;
    has $.name is required;
    has $.args;

    method get-rt {
        $!rt ?? " -> $!rt" !! ""
    }

    method get-doc-comments {

        if @!comments.elems > 0 {
            my @doc-comments = do for @!comments {
                make-doc-comment($_).chomp.trim
            };
            @doc-comments.join("\n")
        } else {
            ""
        }
    }

    method gist {

        my $args = format-rust-function-args($!args);

        my $tag = do if $args.chomp.trim {
            $.const ?? "&self, " !! "&mut self, ";
        } else {
            $.const ?? "&self" !! "&mut self";
        };

        self.get-doc-comments 
        ~ "\nfn {$!name}({$tag}{$args}){self.get-rt};\n"
    }
}

our class AbstractFunctions {

    has AbstractFunction @.declarations;

    method gist {
        do for @!declarations { $_.gist() }.join("\n")
    }
}

our sub translate-abstract-function-declarations(
    $submatch, $body, $rclass) {

    my $writer = AbstractFunctions.new(declarations => [ ]);

    for $submatch<abstract-function-declaration>.List {

        $writer.declarations.push: AbstractFunction.new(
            comments => get-rcomments-list($_).split("\n")>>.chomp,
            const    => $_<const>:exists,
            name     => snake-case($_<name>.Str),
            args     => get-rfunction-args-list($_),
            rt       => get-rust-return-type($_),
        );
    }

    $writer.gist.indent(4)
}
