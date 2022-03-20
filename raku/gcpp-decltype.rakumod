# rule decltype-specifier-body:sym<expr> { 
#   <expression> 
# }
our class DecltypeSpecifierBody::Expr does IDecltypeSpecifierBody {
    has IExpression $.expression is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule decltype-specifier-body:sym<auto> { 
#   <auto> 
# }
our class DecltypeSpecifierBody::Auto does IDecltypeSpecifierBody {

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

# rule decltype-specifier { 
#   <decltype> 
#   <.left-paren> 
#   <decltype-specifier-body> 
#   <.right-paren> 
# }
our class DecltypeSpecifier { 
    has IDecltypeSpecifierBody $.decltype-specifier-body is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}

our role Decltype::Actions {

    # rule decltype-specifier-body:sym<expr> { <expression> }
    method decltype-specifier-body:sym<expr>($/) {
        make $<expression>.made
    }

    # rule decltype-specifier-body:sym<auto> { <auto> }
    method decltype-specifier-body:sym<auto>($/) {
        make DecltypeSpecifierBody::Auto.new
    }

    # rule decltype-specifier { <decltype> <.left-paren> <decltype-specifier-body> <.right-paren> } 
    method decltype-specifier($/) {
        make DecltypeSpecifier.new(
            decltype-specifier-body => $<decltype-specifier-body>.made,
        )
    }
}
