
# rule simple-template-id { 
#   <template-name> 
#   <less> 
#   <template-argument-list>? 
#   <greater> 
# }
our class SimpleTemplateId 
does IDeclSpecifierSeq 
does IPostListHead {

    has Identifier           $.template-name is required;
    has ITemplateArgument @.template-arguments;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule template-id:sym<simple> { 
#   <simple-template-id> 
# }
our class TemplateId::Simple does ITemplateId {
    has SimpleTemplateId $.simple-template-id is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule template-id:sym<operator-function-id> { 
#   <operator-function-id> 
#   <less> 
#   <template-argument-list>? 
#   <greater> 
# }
our class TemplateId::OperatorFunctionId does ITemplateId {
    has OperatorFunctionId   $.operator-function-id is required;
    has TemplateArgumentList $.template-argument-list;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule template-id:sym<literal-operator-id> { 
#   <literal-operator-id> 
#   <less> 
#   <template-argument-list>? 
#   <greater> 
# }
our class TemplateId::LiteralOperatorId does ITemplateId {
    has ILiteralOperatorId   $.literal-operator-id is required;
    has TemplateArgumentList $.template-argument-list;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule template-declaration { 
#   <template> 
#   <less> 
#   <templateparameter-list> 
#   <greater> 
#   <declaration> 
# }
our class TemplateDeclaration { 
    has TemplateParameterList $.templateparameter-list is required;
    has IDeclaration          $.declaration            is required;
    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule scoped-template-id { 
#   <nested-name-specifier> 
#   <.template> 
#   <simple-template-id> 
# }
our class ScopedTemplateId { 
    has INestedNameSpecifier $.nested-name-specifier is required;
    has SimpleTemplateId    $.simple-template-id is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

our role Template::Actions {

    # rule scoped-template-id { <nested-name-specifier> <.template> <simple-template-id> }
    method scoped-template-id($/) {
        make ScopedTemplateId.new(
            nested-name-specifier => $<nested-name-specifier>.made,
            simple-template-id    => $<simple-template-id>.made,
        )
    }

    # rule template-declaration { <template> <less> <templateparameter-list> <greater> <declaration> }
    method template-declaration($/) {
        make TemplateDeclaration.new(
            templateparameter-list => $<templateparameter-list>.made,
            declaration            => $<declaration>.made,
        )
    }

    # rule templateparameter-list { <template-parameter> [ <.comma> <template-parameter> ]* } 
    method templateparameter-list($/) {
        make @<template-parameter>>>.made
    }

    # rule template-parameter:sym<type> { <type-parameter> }
    method template-parameter:sym<type>($/) {
        make $<type-parameter>.made
    }

    # rule template-parameter:sym<param> { <parameter-declaration> } 
    method template-parameter:sym<param>($/) {
        make $<parameter-declaration>.made
    }

    # rule simple-template-id { <template-name> <less> <template-argument-list>? <greater> } 
    method simple-template-id($/) {
        make SimpleTemplateId.new(
            template-name      => $<template-name>.made,
            template-arguments => $<template-argument-list>.made.List,
        )
    }

    # rule template-id:sym<simple> { <simple-template-id> }
    method template-id:sym<simple>($/) {
        make $<simple-template-id>.made
    }

    # rule template-id:sym<operator-function-id> { <operator-function-id> <less> <template-argument-list>? <greater> }
    method template-id:sym<operator-function-id>($/) {
        make TemplateId::OperatorFunctionId.new(
            operator-function-id   => $<operator-function-id>.made,
            template-argument-list => $<template-argument-list>.made,
        )
    }

    # rule template-id:sym<literal-operator-id> { <literal-operator-id> <less> <template-argument-list>? <greater> } 
    method template-id:sym<literal-operator-id>($/) {
        make TemplateId::LiteralOperatorId.new(
            literal-operator-id    => $<literal-operator-id>.made,
            template-argument-list => $<template-argument-list>.made,
        )
    }

    # token template-name { <identifier> }
    method template-name($/) {
        make $<identifier>.made
    }

    # rule template-argument-list { <template-argument> <ellipsis>? [ <.comma> <template-argument> <ellipsis>? ]* } 
    method template-argument-list($/) {
        make $<template-argument>>>.made
    }

    # token template-argument:sym<type-id> { <the-type-id> }
    method template-argument:sym<type-id>($/) {
        make $<the-type-id>.made
    }

    # token template-argument:sym<const-expr> { <constant-expression> }
    method template-argument:sym<const-expr>($/) {
        make $<constant-expression>.made
    }

    # token template-argument:sym<id-expr> { <id-expression> } 
    method template-argument:sym<id-expr>($/) {
        make $<id-expression>.made
    }
}
