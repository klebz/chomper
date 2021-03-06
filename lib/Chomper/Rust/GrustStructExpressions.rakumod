unit module Chomper::Rust::GrustStructExpressions;

use Data::Dump::Tree;

class StructExpressionStruct is export {
    has $.path-in-expression;
    has $.maybe-struct-expr-struct-body;

    has $.text;

    method gist {

        my $builder = "";

        $builder ~= $.path-in-expression.gist;

        $builder ~= '{';

        if $.maybe-struct-expr-struct-body {

            $builder ~= 
            "\n" 
            ~ $.maybe-struct-expr-struct-body.gist.indent(4)
            ~ "\n";
        }

        $builder ~= '}';

        $builder
    }
}

class StructExpressionTuple is export {
    has $.path-in-expression;
    has @.expressions;

    has $.text;

    method gist {

        my $builder = $.path-in-expression.gist;

        $builder ~= "(";
        $builder ~= @.expressions>>.gist.join(",");
        $builder ~= ")";

        $builder
    }
}

class StructExpressionUnit is export {
    has $.path-in-expression;

    has $.text;

    method gist {
        $.path-in-expression.gist
    }
}

class StructExprFields is export {
    has @.struct-expr-fields;
    has $.maybe-struct-base;

    has $.text;

    method gist {

        my @items = @.struct-expr-fields>>.gist;

        if $.maybe-struct-base {
            @items.push: $.maybe-struct-base.gist;
        }

        @items.join(",\n")
    }
}

class StructExprFieldTupleExpr is export {
    has $.maybe-comment;
    has $.tuple-index;
    has $.expression;

    has $.text;

    method gist {

        my $builder = "";

        if $.maybe-comment {
            $builder ~= $.maybe-comment.gist ~ "\n";
        }

        $builder ~= $.tuple-index.gist ~ ": ";
        $builder ~= $.expression.gist;

        $builder
    }
}

class StructExprFieldIdExpr is export {
    has $.maybe-comment;
    has $.identifier;
    has $.expression;

    has $.text;

    method gist {

        my $builder = "";

        if $.maybe-comment {
            $builder ~= $.maybe-comment.gist ~ "\n";
        }

        $builder ~= $.identifier.gist ~ ":";
        $builder ~= $.expression.gist;

        $builder
    }
}

class StructExprFieldId is export {
    has $.maybe-comment;
    has $.identifier;

    has $.text;

    method gist {
        if $.maybe-comment {
            qq:to/END/.chomp.trim
            {$.maybe-comment.gist}
            {$.identifier.gist}
            END
        } else {
            qq:to/END/.chomp.trim
            {$.identifier.gist}
            END
        }
    }
}

class StructBase is export {
    has $.expression;

    has $.text;

    method gist {
        ".." ~ $.expression.gist
    }
}
 
package StructExpressionGrammar is export {

    our role Rules {

        proto rule struct-expression { * }

        rule struct-expression:sym<struct> {
            <path-in-expression>
            <tok-lbrace>
            <struct-expr-struct-body>?
            <tok-rbrace>
        }

        rule struct-expression:sym<tuple> {
            <path-in-expression>
            <tok-lparen>
            [ <expression>* %% <tok-comma> ]
            <tok-rparen>
        }

        rule struct-expression:sym<unit> {
            <path-in-expression>
        }

        #--------------------
        proto rule struct-expr-struct-body { * }
        rule struct-expr-struct-body:sym<fields> { <struct-expr-fields> }
        rule struct-expr-struct-body:sym<base>   { <struct-base> }

        rule struct-expr-fields {
            [ <struct-expr-field>+ %% <tok-comma> ]
            [ <tok-comma>? <struct-base> ]?
        }

        proto rule struct-expr-field { * }

        rule struct-expr-field:sym<tup-expr> { 
            <comment>?
            <tuple-index>
            <tok-colon>
            <expression>
        }

        rule struct-expr-field:sym<id-expr> { 
            <comment>?
            <identifier>
            <tok-colon>
            <expression>
        }

        rule struct-expr-field:sym<id> { 
            <comment>?
            <identifier>
        }

        rule struct-base {
            <tok-dotdot> <expression>
        }
    }

    our role Actions {

        method struct-expression:sym<struct>($/) {  
            make StructExpressionStruct.new(
                path-in-expression            => $<path-in-expression>.made,
                maybe-struct-expr-struct-body => $<struct-expr-struct-body>.made,
                text                          => $/.Str,
            )
        }

        method struct-expression:sym<tuple>($/) {  
            make StructExpressionTuple.new(
                path-in-expression => $<path-in-expression>.made,
                expressions        => $<expression>>>.made,
                text               => $/.Str,
            )
        }

        method struct-expression:sym<unit>($/) {  
            make StructExpressionUnit.new(
                path-in-expression => $<path-in-expression>.made,
                text               => $/.Str,
            )
        }

        #--------------------
        method struct-expr-struct-body:sym<fields>($/) { make $<struct-expr-fields>.made }
        method struct-expr-struct-body:sym<base>($/)   { make $<struct-base>.made }

        method struct-expr-fields($/) {
            make StructExpr::Fields.new(
                struct-expr-fields => $<struct-expr-field>>>.made,
                maybe-struct-base  => $<struct-base>.made,
                text               => $/.Str,
            )
        }

        method struct-expr-field:sym<tup-expr>($/) { 
            make StructExprFieldTupleExpr.new(
                maybe-comment => $<comment>.made,
                tuple-index   => $<tuple-index>.made,
                expression    => $<expression>.made,
                text          => $/.Str,
            )
        }

        method struct-expr-field:sym<id-expr>($/) { 
            make StructExprFieldIdExpr.new(
                maybe-comment => $<comment>.made,
                identifier    => $<identifier>.made,
                expression    => $<expression>.made,
                text          => $/.Str,
            )
        }

        method struct-expr-field:sym<id>($/) { 
            make StructExprFieldId.new(
                maybe-comment => $<comment>.made,
                identifier    => $<identifier>.made,
                text          => $/.Str,
            )
        }

        method struct-base($/) {
            make StructBase.new(
                expression => $<expression>.made,
                text       => $/.Str,
            )
        }
    }
}
