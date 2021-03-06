unit module Chomper::Rust::GrustTraits;

use Data::Dump::Tree;

class Trait is export {
    has Bool $.unsafe;
    has $.identifier;
    has $.maybe-generic-params;
    has $.maybe-type-param-bounds;
    has $.maybe-where-clause;
    has @.inner-attributes;
    has @.associated-items;
    has $.maybe-comment;

    has $.text;

    method has-name {
        True
    }

    method name {
        $.identifier.gist
    }

    method gist {

        my $builder = "";

        if $.unsafe {
            $builder ~= "unsafe ";
        }

        $builder ~= "trait " ~ $.identifier.gist;

        if $.maybe-generic-params {
            $builder ~= $.maybe-generic-params.gist;
        }

        if $.maybe-type-param-bounds {
            $builder ~= ": " ~ $.maybe-type-param-bounds.gist;
        }

        if $.maybe-where-clause {
            $builder ~= $.maybe-where-clause.gist;
        }

        $builder ~= '{';

        for @.inner-attributes {
            $builder ~= $_.gist ~ "\n";
        }

        for @.associated-items {
            $builder ~= $_.gist ~ "\n";
        }

        if $.maybe-comment {
            $builder ~= $.maybe-comment.gist;
        }

        $builder ~= '}';

        $builder
    }
}

class InherentImpl is export {
    has $.maybe-generic-params;
    has $.type;
    has $.maybe-where-clause;
    has @.inner-attributes;
    has @.associated-items;
    has $.maybe-comment;

    has $.text;

    method has-name {
        False
    }

    method gist {
        my $builder = "impl";

        if $.maybe-generic-params {
            $builder ~= $.maybe-generic-params.gist;
        }

        $builder ~= " " ~ $.type.gist;

        if $.maybe-where-clause {
            $builder ~= "\n" ~ $.maybe-where-clause.gist;
        }

        $builder ~= "\n\{";

        for @.inner-attributes {
            $builder ~= $_.gist ~ "\n";
        }

        for @.associated-items {
            $builder ~= $_.gist ~ "\n";
        }

        if $.maybe-comment {
            $builder ~= $.maybe-comment.gist;
        }

        $builder ~= "\n}";

        $builder
    }
}

class TraitImpl is export {
    has Bool $.default is required;
    has Bool $.unsafe;
    has $.maybe-generic-params;
    has Bool $.bang;
    has $.type-path;
    has $.for-type;
    has $.maybe-where-clause;
    has @.inner-attributes;
    has @.associated-items;
    has $.maybe-comment;

    has $.text;

    method has-name {
        False
    }

    method gist {

        my $builder = "";

        if $.default {
            $builder ~= "default ";
        }

        if $.unsafe {
            $builder ~= "unsafe ";
        }

        $builder ~= "impl";

        if $.maybe-generic-params {
            $builder ~= $.maybe-generic-params.gist;
        }

        if $.bang {
            $builder ~= "!";
        }

        $builder ~= " " ~ $.type-path.gist;
        $builder ~= " for " ~ $.for-type.gist;

        if $.maybe-where-clause {
            $builder ~= "\n" ~ $.maybe-where-clause.gist ~ "\n";
        }

        $builder ~= '{';

        for @.inner-attributes {
            $builder ~= $_.gist ~ "\n";
        }

        for @.associated-items {
            $builder ~= $_.gist ~ "\n";
        }

        if $.maybe-comment {
            $builder ~= $.maybe-comment.gist;
        }

        $builder ~= '}';

        $builder
    }
}

class TraitAlias is export {
    has @.outer-attributes;
    has $.maybe-visibility;
    has $.identifier;
    has $.maybe-generic-params;
    has $.type-param-bounds;
    has $.maybe-where-clause;

    has $.text;

    method has-name {
        True
    }

    method name {
        $.identifier.gist
    }

    method gist {

        my $builder = "";

        for @.outer-attributes {
            $builder ~= $_.gist ~ "\n";
        }

        if $.maybe-visibility {
            $builder ~= $.maybe-visibility.gist ~ " ";
        }

        $builder ~= "trait " ~ $.identifier.gist;

        if $.maybe-generic-params {
            $builder ~= $.maybe-generic-params.gist;
        }

        $builder ~= " = " ~ $.type-param-bounds.gist;

        if $.maybe-where-clause {
            $builder ~= "\n" ~ $.maybe-where-clause.gist ~ "\n";
        }

        $builder ~ ";"
    }
}

package TraitGrammar is export {

    our role Rules {

        rule trait {
            <kw-unsafe>?
            <kw-trait>
            <identifier>
            <generic-params>?
            [ <tok-colon> <type-param-bounds>? ]?
            <where-clause>?
            <tok-lbrace>
            <inner-attribute>*
            <associated-item>*
            <comment>?
            <tok-rbrace>
        }

        proto rule implementation { * }
        rule implementation:sym<inherent> { <inherent-impl> }
        rule implementation:sym<trait>    { <trait-impl> }

        rule inherent-impl {
            <kw-impl>
            <generic-params>?
            <type>
            <where-clause>?
            <tok-lbrace>
            <inner-attribute>*
            <associated-item>*
            <comment>?
            <tok-rbrace>
        }

        rule trait-impl {
            <kw-default>?
            <kw-unsafe>?
            <kw-impl>
            <generic-params>?
            <tok-bang>?
            <type-path>
            <kw-for>
            <type>
            <where-clause>?
            <tok-lbrace>
            <inner-attribute>*
            <associated-item>*
            <comment>?
            <tok-rbrace>
        }

        rule trait-alias {
            <outer-attribute>* 
            <visibility>? 
            <kw-trait> 
            <identifier>
            <generic-params>? 
            <tok-eq>
            <type-param-bounds> 
            <where-clause>?
            <tok-semi>
        }
    }

    our role Actions {

        method trait($/) {
            my @bounds = $/<type-param-bounds>:exists ?? $<type-param-bounds>>>.made !! [];

            make Trait.new(
                unsafe                  => so $<kw-unsafe>:exists,
                identifier              => $<identifier>.made,
                maybe-generic-params    => $<generic-params>.made,
                maybe-type-param-bounds => @bounds,
                maybe-where-clause      => $<where-clause>.made,
                inner-attributes        => $<inner-attribute>>>.made,
                associated-items        => $<associated-item>>>.made,
                maybe-comment           => $<comment>.made,
                text                    => $/.Str,
            )
        }

        method implementation:sym<inherent>($/) { make $<inherent-impl>.made }
        method implementation:sym<trait>($/)    { make $<trait-impl>.made }

        method inherent-impl($/) {
            make InherentImpl.new(
                maybe-generic-params => $<generic-params>.made,
                type                 => $<type>.made,
                maybe-where-clause   => $<where-clause>.made,
                inner-attributes     => $<inner-attribute>>>.made,
                associated-items     => $<associated-item>>>.made,
                maybe-comment        => $<comment>.made,
                text                 => $/.Str,
            )
        }

        method trait-impl($/) {
            make TraitImpl.new(
                default              => $/<kw-default>:exists,
                unsafe               => $/<kw-unsafe>:exists,
                maybe-generic-params => $<generic-params>.made,
                bang                 => so $/<tok-bang>:exists,
                type-path            => $<type-path>.made,
                for-type             => $<type>.made,
                maybe-where-clause   => $<where-clause>.made,
                inner-attributes     => $<inner-attribute>>>.made,
                associated-items     => $<associated-item>>>.made,
                maybe-comment        => $<comment>.made,
                text                 => $/.Str,
            )
        }

        method trait-alias($/) {
            make TraitAlias.new(
                outer-attributes     => $<outer-attribute>>>.made,
                maybe-visibility     => $<visibility>.made,
                identifier           => $<identifier>.made,
                maybe-generic-params => $<generic-params>.made,
                type-param-bounds    => $<type-param-bounds>.made,
                maybe-where-clause   => $<where-clause>.made,
                text                 => $/.Str,
            )
        }
    }
}
