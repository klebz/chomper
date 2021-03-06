unit module Chomper::Rust::GrustFunctionPointerTypes;

use Data::Dump::Tree;

class BareFunctionType is export {
    has $.maybe-for-lifetimes;
    has $.function-type-qualifiers;
    has $.maybe-function-parameters;
    has $.maybe-function-return-type;

    has $.text;

    method gist {
        my $builder = "";

        if $.maybe-for-lifetimes {
            $builder ~= $.maybe-for-lifetimes.gist ~ " ";
        }

        $builder ~= $.function-type-qualifiers.gist;
        $builder ~= " fn (";

        if $.maybe-function-parameters {
            $builder ~= $.maybe-function-parameters.gist;
        }

        $builder ~= ")";

        if $.maybe-function-return-type {
            $builder ~= " " ~ $.maybe-function-return-type.gist;
        }

        $builder
    }
}

class FunctionExternModifier is export {
    has $.maybe-abi;

    has $.text;

    method gist {
        if $.maybe-abi {
            "extern " ~ $.maybe-abi.gist
        } else {
            "extern"
        }
    }
}

class FunctionTypeQualifiers is export {
    has Bool $.unsafe;
    has $.maybe-function-extern-modifier;

    has $.text;

    method gist {

        my $builder = "";

        if $.unsafe {
            $builder ~= "unsafe ";
        }

        if so $.maybe-function-extern-modifier {
            $builder ~= $.maybe-function-extern-modifier;
        }

        $builder
    }
}

class BareFunctionReturnType is export {
    has $.type-no-bounds;

    has $.text;

    method gist {
        "-> " ~ $.type-no-bounds.gist
    }
}

class FunctionParametersBasic is export {
    has @.maybe-named-params;

    has $.text;

    method gist {
        @.maybe-named-params>>.gist.join(", ")
    }
}

class FunctionParametersVariadic is export {
    has @.maybe-named-params;
    has @.outer-attributes;

    has $.text;

    method gist {

        my $builder = @.maybe-named-params>>.gist.join(", ") ~ ", ";

        for @.outer-attributes {
            $builder ~= $_.gist ~ "\n";
        }

        $builder ~= "...";

        $builder
    }
}

class MaybeNamedParam is export {
    has @.outer-attributes;
    has $.maybe-identifier-or-underscore;
    has $.type;

    has $.text;

    method gist {

        my $builder = "";

        for @.outer-attributes {
            $builder ~= $_.gist ~ "\n";
        }

        if $.maybe-type-identifier-or-underscore {
            $builder ~= $.maybe-type-identifier-or-underscore.gist ~ ":";
        }

        $builder ~= $.type.gist;

        $builder
    }
}

package BareFunctionTypeGrammar is export {

    our role Rules {

        regex bare-function-type {

            #this needs to be uncommented but for
            #some reason it breaks function args that
            #begin with "for"
            #<for-lifetimes>? 

            <.ws>
            <function-type-qualifiers>
            <.ws>
            <kw-fn>
            <tok-lparen>
            <.ws>
            <bare-function-parameters>?
            <.ws>
            <tok-rparen>
            <.ws>
            <bare-function-return-type>?
        }

        rule function-extern-modifier {
            <kw-extern>
            <abi>?
        }

        rule function-type-qualifiers {
            <kw-unsafe>?
            <function-extern-modifier>?
        }

        rule bare-function-return-type {
            <tok-rarrow>
            <type-no-bounds>
        }

        #-------------------
        proto rule bare-function-parameters { * }

        rule bare-function-parameters:sym<basic> {  
            <maybe-named-param>+ %% <tok-comma>
        }

        rule bare-function-parameters:sym<variadic> {  
            [<maybe-named-param>+ % <tok-comma>]
            <outer-attribute>*
            <tok-dotdotdot>
        }

        rule maybe-named-param {
            <outer-attribute>*
            [
                <identifier-or-underscore>
                <tok-colon>
            ]?
            <type>
        }
    }

    our role Actions {

        method bare-function-type($/) {
            make BareFunctionType.new(
                maybe-for-lifetimes        => $<for-lifetimes>.made,
                function-type-qualifiers   => $<function-type-qualifiers>.made,
                maybe-function-parameters  => $<bare-function-parameters>.made,
                maybe-function-return-type => $<bare-function-return-type>.made,
                text                       => $/.Str,
            )
        }

        method function-extern-modifier($/) {
            make FunctionExternModifier.new(
                maybe-abi => $<abi>.made,
                text      => $/.Str,
            )
        }

        method function-type-qualifiers($/) {
            make FunctionTypeQualifiers.new(
                unsafe                         => so $/<kw-unsafe>:exists,
                maybe-function-extern-modifier => $<function-extern-modifier>.made,
                text                           => $/.Str,
            )
        }

        method bare-function-return-type($/) {
            make BareFunctionReturnType.new(
                type-no-bounds => $<type-no-bounds>.made,
                text           => $/.Str,
            )
        }

        #-------------------
        method function-parameters:sym<basic>($/) {  
            make FunctionParametersBasic.new(
                maybe-named-params => $<maybe-named-param>>>.made,
                text               => $/.Str,
            )
        }

        method function-parameters:sym<variadic>($/) {  
            make FunctionParametersVariadic.new(
                maybe-named-params => $<maybe-named-param>>>.made,
                outer-attributes   => $<outer-attribute>>>.made,
                text               => $/.Str,
            )
        }

        method maybe-named-param($/) {
            make MaybeNamedParam.new(
                outer-attributes               => $<outer-attribute>>>.made,
                maybe-identifier-or-underscore => $<identifier-or-underscore>.made,
                type                           => $<type>.made,
                text                           => $/.Str,
            )
        }
    }
}
