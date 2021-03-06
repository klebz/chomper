unit module Chomper::Rust::GrustPathExpressions;

use Data::Dump::Tree;

class PathInExpression is export {
    has @.path-expr-segments;

    has $.text;

    method gist {
        @.path-expr-segments>>.gist.join("::")
    }
}

class PathExprSegment is export {
    has $.path-ident-segment;
    has $.maybe-generic-args;

    has $.text;

    method gist {

        if $.maybe-generic-args {

            $.path-ident-segment.gist 
            ~ "::" 
            ~ $.maybe-generic-args.gist

        } else {
            $.path-ident-segment.gist 
        }
    }
}

class QualifiedPathInExpression is export {
    has $.qualified-path-type;
    has @.path-expr-segments;

    has $.text;

    method gist {

        my $builder = $.qualified-path-type.gist;

        for @.path-expr-segments {
            $builder ~= "::" ~ $_.gist;
        }

        $builder
    }
}

class QualifiedPathType is export {
    has $.type;
    has $.maybe-as-type-path;

    has $.text;

    method gist {

        my $builder = "<";

        $builder ~= $.type.gist;

        if $.maybe-as-type-path {
            $builder ~= " as " ~ $.maybe-as-type-path.gist;
        }

        $builder ~= ">";

        $builder
    }
}

class QualifiedPathInType is export {
    has $.qualified-path-type;
    has @.type-path-segments;

    has $.text;

    method gist {

        my $builder = $.qualified-path-type.gist;

        for @.type-path-segments {
            $builder ~= "::" ~ $._.gist;
        }

        $builder
    }
}

package PathExpressionGrammar is export {

    our role Rules {

        proto rule path-expression { * }
        rule path-expression:sym<basic>      { <path-in-expression> }
        rule path-expression:sym<qualified>  { <qualified-path-in-expression> }

        token path-in-expression {
            <tok-path-sep>?
            [
                <path-expr-segment>+ %% <tok-path-sep>
            ]
        }

        token path-expr-segment {
            <path-ident-segment> 
            [ <tok-path-sep> <generic-args> ]?
        }

        proto token path-ident-segment { * }

        token path-ident-segment:sym<ident>   { <identifier> }
        token path-ident-segment:sym<super>   { <kw-super> }
        token path-ident-segment:sym<selfv>   { <kw-selfvalue> }
        token path-ident-segment:sym<selft>   { <kw-selftype> }
        token path-ident-segment:sym<crate>   { <kw-crate> }
        token path-ident-segment:sym<$-crate> { <dollar-crate> }

        token dollar-crate {
            <tok-dollar> <kw-crate> 
        }

        token qualified-path-in-expression {
            <qualified-path-type> [<tok-path-sep> <path-expr-segment>]+
        }

        rule qualified-path-type {
            <tok-lt>
            <type>
            [
                <kw-as>
                <type-path>
            ]?
            <tok-gt>
        }

        token qualified-path-in-type {
            <qualified-path-type>
            [
                <tok-path-sep>
                <type-path-segment>
            ]+
        }
    }

    our class IdentSuper {
        method gist { "super" }
    }

    our class IdentSelfType  {
        method gist { "Self" }
    }

    our class IdentSelfValue {
        method gist { "self" }
    }

    our class IdentCrate {
        method gist { "crate" }

    }

    our class DollarCrate {
        method gist { "\$crate" }
    }

    our role Actions {

        method path-expression:sym<basic>($/)      { make $<path-in-expression>.made }
        method path-expression:sym<qualified>($/)  { make $<qualified-path-in-expression>.made }

        method path-in-expression($/) {
            make PathInExpression.new(
                path-expr-segments => $<path-expr-segment>>>.made,
                text               => $/.Str,
            )
        }

        method path-expr-segment($/) {
            make PathExprSegment.new(
                path-ident-segment => $<path-ident-segment>.made,
                maybe-generic-args => $<generic-args>.made,
                text               => $/.Str,
            )
        }

        method path-ident-segment:sym<ident>($/)   { make $<identifier>.made }
        method path-ident-segment:sym<super>($/)   { make IdentSuper.new }
        method path-ident-segment:sym<selfv>($/)   { make IdentSelfValue.new }
        method path-ident-segment:sym<selft>($/)   { make IdentSelfType.new }
        method path-ident-segment:sym<crate>($/)   { make IdentCrate.new }
        method path-ident-segment:sym<$-crate>($/) { make DollarCrate.new }

        method dollar-crate($/) {
            make DollarCrate.new
        }

        method qualified-path-in-expression($/) {
            make QualifiedPathInExpression.new(
                qualified-path-type => $<qualified-path-type>.made,
                path-expr-segments  => $<path-expr-segment>>>.made,
                text                => $/.Str,
            )
        }

        method qualified-path-type($/) {
            make QualifiedPathType.new(
                type               => $<type>.made,
                maybe-as-type-path => $<type-path>.made,
                text               => $/.Str,
            )
        }

        method qualified-path-in-type($/) {
            make QualifiedPathInType.new(
                qualified-path-type => $<qualified-path-type>.made,
                type-path-segments  => $<type-path-segment>>>.made,
                text                => $/.Str,
            )
        }
    }
}
