unit module Chomper::Rust::GrustMetaItem;

use Data::Dump::Tree;

class MetaItemSimple is export {
    has $.simple-path;

    has $.text;

    method gist {
        $.simple-path.gist
    }
}

class MetaItemSimpleEqExpr is export {
    has $.simple-path;
    has $.expression;

    has $.text;

    method gist {
        $.simple-path.gist ~ " = " ~ $.expression.gist
    }
}

class MetaItemSimpleWithMetaSeq is export {
    has $.simple-path;
    has $.meta-seq;

    has $.text;

    method gist {

        if $.meta-seq {

            $.simple-path.gist 
            ~ "(" 
            ~ $.meta-seq.List>>.gist.join(",") 
            ~ ")"

        } else {

            $.simple-path.gist ~ "()"
        }
    }
}

class MetaWord is export {
    has $.identifier;

    has $.text;

    method gist {
        $.identifier.gist
    }
}

class MetaNameValueStr is export {
    has $.identifier;
    has $.any-string-literal;

    has $.text;

    method gist {

        my $builder = $.identifier.gist;

        $builder ~= " = ";

        $builder ~= $.any-string-literal.gist;

        $builder
    }
}

class MetaListPaths is export {
    has $.identifier;
    has @.simple-paths;

    has $.text;

    method gist {

        my $builder = $.identifier.gist;

        $builder ~= "(";
        $builder ~= @.simple-paths>>.gist.join(",");
        $builder ~= ")";

        $builder
    }
}

class MetaListIdents is export {
    has $.identifier;
    has @.grouped-identifiers;

    has $.text;

    method gist {

        my $builder = $.identifier.gist;

        $builder ~= "(";
        $builder ~= @.grouped-identifiers>>.gist.join(",");
        $builder ~= ")";

        $builder
    }
}

class MetaListNameValueStr is export {
    has $.identifier;
    has @.grouped-meta-name-value-str;

    has $.text;

    method gist {
        my $builder = $.identifier.gist;

        $builder ~= "(";
        $builder ~= @.grouped-meta-name-value-str>>.gist.join(",");
        $builder ~= ")";

        $builder
    }
}

package MetaItemGrammar is export {

    our role Rules {

        proto rule meta-item { * }

        rule meta-item:sym<simple> {  
            <simple-path>
        }

        rule meta-item:sym<simple-eq-expr> {  
            <simple-path> <tok-eq> <expression>
        }

        rule meta-item:sym<simple-with-meta-seq> {  
            <simple-path> <tok-lparen> <meta-seq>? <tok-rparen>
        }

        rule meta-seq {
            <meta-item-inner>+ %% <tok-comma>
        }

        #---------------
        proto rule meta-item-inner { * }

        rule meta-item-inner:sym<basic> { <meta-item> }

        rule meta-item-inner:sym<expr>  { <expression> }

        rule meta-word {
            <identifier>
        }

        #---------------
        proto rule any-string-literal { * }

        rule any-string-literal:sym<basic> { <string-literal> }
        rule any-string-literal:sym<raw>   { <raw-string-literal> }

        #---------------
        rule meta-name-value-str {
            <identifier> <tok-eq> <any-string-literal>
        }

        rule meta-list-paths {
            <identifier> 
            <tok-lparen>
            [ <simple-path>* %% <tok-comma> ] 
            <tok-rparen>
        }

        rule ident-list {
            <identifier>* %% <tok-comma>
        }

        rule meta-list-idents {
            <identifier>
            <tok-lparen>
            <ident-list>
            <tok-rparen>
        }

        rule meta-list-name-value-str {
            <identifier>
            <tok-lparen>
            [ <meta-name-value-str>* %% <tok-comma> ]
            <tok-rparen>
        }
    }

    our role Actions {

        method meta-item:sym<simple>($/) {  
            make MetaItemSimple.new(
                simple-path => $<simple-path>.made,
                text        => $/.Str,
            )
        }

        method meta-item:sym<simple-eq-expr>($/) {  
            make MetaItemSimpleEqExpr.new(
                simple-path => $<simple-path>.made,
                expression  => $<expression>.made,
                text        => $/.Str,
            )
        }

        method meta-item:sym<simple-with-meta-seq>($/) {  
            make MetaItemSimpleWithMetaSeq.new(
                simple-path => $<simple-path>.made,
                meta-seq    => $<meta-seq>.made,
                text        => $/.Str,
            )
        }

        method meta-seq($/) {
            make $<meta-item-inner>>>.made
        }

        #---------------
        method meta-item-inner:sym<basic>($/) { make $<meta-item>.made }

        method meta-item-inner:sym<expr>($/)  { make $<expression>.made }

        method meta-word($/) {
            make $<identifier>.made
        }

        #---------------
        method any-string-literal:sym<basic>($/) { make $<string-literal>.made }
        method any-string-literal:sym<raw>($/)   { make $<raw-string-literal>.made }

        #---------------
        method meta-name-value-str($/) {
            make MetaNameValueStr.new(
                identifier         => $<identifier>.made,
                any-string-literal => $<any-string-literal>.made,
                text               => $/.Str,
            )
        }

        method meta-list-paths($/) {
            make MetaListPaths.new(
                identifier   => $<identifier>.made,
                simple-paths => $<simple-path>>>.made,
                text         => $/.Str,
            )
        }

        method ident-list($/) {
            make $<identifier>>>.made
        }

        method meta-list-idents($/) {
            make MetaListIdents.new(
                identifier          => $<identifier>.made,
                grouped-identifiers => $<ident-list>.made,
                text                => $/.Str,
            )
        }

        method meta-list-name-value-str($/) {
            make MetaListNameValueStr.new(
                identifier                  => $<identifier>.made,
                grouped-meta-name-value-str => $<meta-name-value-str>>>.made,
                text                        => $/.Str,
            )
        }
    }
}
