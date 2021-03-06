unit module Chomper::Rust::GrustLiteralPattern;

use Data::Dump::Tree;

class NumericLiteral is export {
    has Bool $.minus;
    has $.value;

    has $.text;

    method gist {
        if $.minus {
            "-" ~ $.value
        } else {
            $.value
        }
    }
}

package LiteralPatternGrammar is export {

    our role Rules {

        proto rule literal-pattern { * }

        rule literal-pattern:sym<bool>         { <boolean-literal> }
        rule literal-pattern:sym<char>         { <char-literal> }
        rule literal-pattern:sym<byte>         { <byte-literal> }
        rule literal-pattern:sym<str>          { <string-literal> }
        rule literal-pattern:sym<raw-str>      { <raw-string-literal> }
        rule literal-pattern:sym<byte-str>     { <byte-string-literal> }
        rule literal-pattern:sym<raw-byte-str> { <raw-byte-string-literal> }
        rule literal-pattern:sym<int>          { <integer-literal-pattern> }
        rule literal-pattern:sym<float>        { <float-literal-pattern> }

        rule float-literal-pattern {
            <tok-minus>? <float-literal>
        }

        rule integer-literal-pattern {
            <tok-minus>? <integer-literal>
        }
    }

    our role Actions {

        method literal-pattern:sym<bool>($/) {
            make $<boolean-literal>.made
        }

        method literal-pattern:sym<char>($/) {
            make $<char-literal>.made 
        }

        method literal-pattern:sym<byte>($/) {
            make $<byte-literal>.made 
        }

        method literal-pattern:sym<str>($/) {
            make $<string-literal>.made 
        }

        method literal-pattern:sym<raw-str>($/) {
            make $<raw-string-literal>.made 
        }

        method literal-pattern:sym<byte-str>($/) {
            make $<byte-string-literal>.made 
        }

        method literal-pattern:sym<raw-byte-str>($/) {
            make $<raw-byte-string-literal>.made 
        }

        method integer-literal-pattern($/) { 
            make NumericLiteral.new(
                minus => so $/<tok-minus>:exists,
                value => ~$/<integer-literal>,
                text  => $/.Str,
            )
        }

        method float-literal-pattern($/) { 
            make NumericLiteral.new(
                minus => so $/<tok-minus>:exists,
                value => ~$/<float-literal>,
                text  => $/.Str,
            )
        }

        method literal-pattern:sym<int>($/) { 
            make $<integer-literal-pattern>.made
        }

        method literal-pattern:sym<float>($/) { 
            make $<float-literal-pattern>.made
        }
    }
}
