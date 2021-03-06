unit module Chomper::Cpp::GcppTry;

use Data::Dump::Tree;

use Chomper::Cpp::GcppRoles;
use Chomper::Cpp::GcppStatement;
use Chomper::Cpp::GcppConstructor;

use Chomper::TreeMark;

# rule handler { 
#   <catch> 
#   <.left-paren> 
#   <exception-declaration> 
#   <.right-paren> 
#   <compound-statement> 
# }
class Handler is export { 
    has IExceptionDeclaration $.exception-declaration is required;
    has $.compound-statement is required;

    has $.text;

    method name {
        'Handler'
    }

    method gist(:$treemark=False) {
        my $builder = "catch(";

        if $treemark {
            $builder ~= sigil(TreeMark::<_Declaration>);

        } else {
            $builder ~= $.exception-declaration.gist(:$treemark);
        }

        $builder ~= ")";

        if $treemark {
            $builder ~= " " ~ sigil(TreeMark::<_Statements>);

        } else {
            $builder ~= $.compound-statement.gist(:$treemark);
        }

        $builder
    }
}

# rule handler-seq { 
#   <handler>+ 
# }
class HandlerSeq is export { 
    has Handler @.handlers is required;

    has $.text;

    method name {
        'HandlerSeq'
    }

    method gist(:$treemark=False) {
        @.handlers>>.gist(:$treemark).join("\n")
    }
}

# rule try-block { 
#   <try_> 
#   <compound-statement> 
#   <handler-seq> 
# }
class TryBlock does IStatement is export { 
    has $.compound-statement is required;
    has @.handler-seq is required;

    has $.text;

    method name {
        'TryBlock'
    }

    method gist(:$treemark=False) {

        my $builder = "try ";

        if $treemark {
            $builder ~= sigil(TreeMark::<_Statements>);

        } else {
            $builder ~= $.compound-statement.gist(:$treemark);
        }

        for @.handler-seq {
            $builder ~= " " ~ $_.gist(:$treemark) ~ "\n";
        }

        $builder
    }
}

# rule function-try-block { 
#   <try_> 
#   <constructor-initializer>? 
#   <compound-statement> 
#   <handler-seq> 
# }
class FunctionTryBlock is export { 
    has ConstructorInitializer $.constructor-initializer;
    has CompoundStatement      $.compound-statement is required;
    has                        @.handler-seq is required;

    has $.text;

    method name {
        'FunctionTryBlock'
    }

    method gist(:$treemark=False) {

        my $builder = "try ";

        $builder = $builder.&maybe-extend(:$treemark,$.constructor-initializer);

        $builder ~= $.compound-statement.gist(:$treemark);

        for @.handler-seq {
            $builder ~= $_.gist(:$treemark) ~ "\n";
        }

        $builder
    }
}

package TryGrammar is export {

    our role Actions {

        # rule try-block { <try_> <compound-statement> <handler-seq> }
        method try-block($/) {
            make TryBlock.new(
                compound-statement => $<compound-statement>.made,
                handler-seq        => $<handler-seq>.made,
                text               => ~$/,
            )
        }

        # rule function-try-block { <try_> <constructor-initializer>? <compound-statement> <handler-seq> }
        method function-try-block($/) {
            make FunctionTryBlock.new(
                constructor-initializer => $<constructor-initializer>.made,
                compound-statement      => $<compound-statement>.made,
                handler-seq             => $<handler-seq>.made,
                text                    => ~$/,
            )
        }

        # rule handler-seq { <handler>+ }
        method handler-seq($/) {
            make $<handler>>>.made
        }

        # rule handler { <catch> <.left-paren> <exception-declaration> <.right-paren> <compound-statement> }
        method handler($/) {
            make Handler.new(
                exception-declaration => $<exception-declaration>.made,
                compound-statement    => $<compound-statement>.made,
                text                  => ~$/,
            )
        }
    }

    our role Rules {

        rule try-block {
            <try_>
            <compound-statement>
            <handler-seq>
        }

        rule function-try-block {
            <try_>
            <constructor-initializer>?
            <compound-statement>
            <handler-seq>
        }

        rule handler-seq {
            <handler>+
        }

        rule handler {
            <catch>
            <left-paren>
            <exception-declaration>
            <right-paren>
            <compound-statement>
        }
    }
}
