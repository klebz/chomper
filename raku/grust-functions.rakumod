our class Function {
    has $.function-qualifiers;
    has $.identifier;
    has $.maybe-generic-params;
    has $.maybe-function-parameters;
    has $.maybe-function-return-type;
    has $.maybe-where-clause;
    has $.maybe-block-expression;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class FunctionQualifiers {
    has Bool $.const;
    has Bool $.async;
    has Bool $.unsafe;
    has $.maybe-function-extern-modifier;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class FunctionParameters {
    has $.maybe-self-param;
    has @.function-params;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class SelfParam {
    has @.outer-attributes;
    has $.self-param-variant;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class SelfBorrow {
    has $.maybe-lifetime;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class SelfParamVariantShorthand {
    has $.maybe-self-borrow;
    has Bool $.mutable;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class SelfParamVariantTyped {
    has Bool $.mutable;
    has $.type;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class FunctionParam {
    has $.maybe-comment;
    has @.outer-attributes;
    has $.function-param-variant;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class FunctionParamVariantPatternType {
    has $.pattern-no-top-alt;
    has $.type;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class FunctionParamVariantPatternEllipsis {
    has $.pattern-no-top-alt;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class FunctionParamVariantEllipsis { 

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our class FunctionReturnType {
    has $.type;
    has $.maybe-comment;

    has $.text;

    submethod TWEAK {
        say self.gist;
    }

    method gist {
        say "need to write gist!";
        say $.text;
        ddt self;
        exit;
    }
}

our role Function::Rules {

    rule function-extern-modifier {
        <kw-extern> <abi>?
    }

    rule function {
        <function-qualifiers>
        <kw-fn>
        <identifier>
        <generic-params>?
        <tok-lparen>
        <function-parameters>?
        <tok-rparen>
        <function-return-type>?
        <where-clause>?
        [
            | <block-expression>
            | <tok-semi>
        ]
    }

    rule function-qualifiers {
        <kw-const>?
        <kw-async>?
        <kw-unsafe>?
        <function-extern-modifier>?
    }

    proto rule abi { * }

    rule abi:sym<str>     { <string-literal> }

    rule abi:sym<raw-str> { <raw-string-literal> }

    #----------------------
    proto rule function-parameters { * }

    rule function-parameters:sym<self-and-just-params> {
        <self-param> 
        <tok-comma>
        [ <function-param>+ %% <tok-comma> ]
    }

    rule function-parameters:sym<just-params> {
        <function-param>+ %% <tok-comma>
    }

    rule function-parameters:sym<just-self> {
        <self-param> <tok-comma>?
    }

    #----------------------
    rule self-param {  
        <outer-attribute>*
        <self-param-variant>
    }

    rule self-borrow {
        <tok-and> <lifetime>?
    }

    proto rule self-param-variant { * }

    rule self-param-variant:sym<shorthand> { 
        <self-borrow>?
        <kw-mut>?
        <kw-selfvalue>
    }

    rule self-param-variant:sym<typed> { 
        <kw-mut>?
        <kw-selfvalue>
        <tok-colon>
        <type>
    }

    #-------------------
    rule function-param {
        <comment>?
        <outer-attribute>*
        <function-param-variant>
    }

    proto rule function-param-variant { * }

    rule function-param-variant:sym<pattern-type> {
        <pattern-no-top-alt> 
        <tok-colon>
        <type> 
    }

    rule function-param-variant:sym<pattern-ellipsis> {
        <pattern-no-top-alt> 
        <tok-colon>
        <tok-dotdotdot>
    }

    rule function-param-variant:sym<ellipsis> {
        <tok-dotdotdot>
    }

    rule function-param-variant:sym<type> {
        <type>
    }

    #-------------------
    rule function-return-type {
        <tok-rarrow>
        <type>
        <comment>?
    }

}

our role Function::Actions {

    method function($/) {
        make Function.new(
            function-qualifiers        => $<function-qualifiers>.made,
            identifier                 => $<identifier>.made,
            maybe-generic-params       => $<generic-params>.made,
            maybe-function-parameters  => $<function-parameters>.made,
            maybe-function-return-type => $<function-return-type>.made,
            maybe-where-clause         => $<where-clause>.made,
            maybe-block-expression     => $<block-expression>.made,
        )
    }

    method function-qualifiers($/) {
        make FunctionQualifiers.new(
            const                          => so $/<kw-const>:exists,
            async                          => so $/<kw-async>:exists,
            unsafe                         => so $/<kw-unsafe>:exists,
            maybe-function-extern-modifier => $<function-extern-modifier>.made,
        )
    }

    method abi:sym<str>($/)     { make $<string-literal>.made }
    method abi:sym<raw-str>($/) { make $<raw-string-literal>.made }

    #----------------------
    method function-parameters:sym<self-and-just-params>($/) {
        make FunctionParameters.new(
            maybe-self-param => $<self-param>.made,
            function-params => $<function-param>>>.made,
        )
    }

    method function-parameters:sym<just-params>($/) {
        make FunctionParameters.new(
            function-params => $<function-param>>>.made,
        )
    }

    method function-parameters:sym<just-self>($/) {
        make FunctionParameters.new(
            maybe-self-param => $<self-param>.made,
        )
    }

    #----------------------
    method self-param($/) {  
        make SelfParam.new(
            outer-attributes   => $<outer-attrigute>>>.made,
            self-param-variant => $<self-param-variant>.made,
        )
    }

    method self-borrow($/) {
        make SelfBorrow.new(
            maybe-lifetime => $<lifetime>.made,
        )
    }

    method self-param-variant:sym<shorthand>($/) { 
        make SelfParamVariantShorthand.new(
            maybe-self-borrow => $<self-borrow>.made,
            mutable           => so $/<kw-mut>:exists,
        )
    }

    method self-param-variant:sym<typed>($/) { 
        make SelfParamVariantTyped.new(
            mutable => so $/<kw-mut>:exists,
            type    => $<type>.made,
        )
    }

    #-------------------
    method function-param($/) {
        make FunctionParam.new(
            maybe-comment          => $<comment>.made,
            outer-attributes       => $<outer-attributes>>>.made,
            function-param-variant => $<function-param-variant>.made,
        )
    }

    method function-param-variant:sym<pattern-type>($/) {
        make FunctionParamVariantPatternType.new(
            pattern-no-top-alt => $<pattern-no-top-alt>.made,
            type               => $<type>.made,
        )
    }

    method function-param-variant:sym<pattern-ellipsis>($/) {
        make FunctionParamVariantPatternEllipsis.new(
            pattern-no-top-alt => $<pattern-no-top-alt>.made,
        )
    }

    method function-param-variant:sym<ellipsis>($/) {
        make FunctionParamVariantEllipsis.new
    }

    method function-param-variant:sym<type>($/) {
        make $<type>.made
    }

    #-------------------
    method function-return-type($/) {
        make FunctionReturnType.new(
            type          => $<type>.made,
            maybe-comment => $<comment>.made,
        )
    }
}