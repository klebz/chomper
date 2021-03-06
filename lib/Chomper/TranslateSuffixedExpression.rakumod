use Chomper::Cpp;
use Chomper::Rust;
use Chomper::ToRust;
use Chomper::TranslateIo;
use Chomper::ToRustType;
use Chomper::ToRustIdent;
use Chomper::ToRustParams;
use Chomper::ToRustPathInExpression;

use Chomper::TranslateIndexExpressionSuffix;
use Chomper::TranslatePostfixExpression;

use Data::Dump::Tree;

proto sub to-rust-suffixed-expression($item) is export { * }

multi sub to-rust-suffixed-expression($item where Cpp::NoPointerDeclarator) {  

    given $item.token-types {
        when ["Identifier", "Bracketed"] {

            my Rust::PathInExpression $expression-item 
            = to-rust-path-in-expression($item.no-pointer-declarator-base);

            my $bracketed     = $item.no-pointer-declarator-tail[0];

            Rust::SuffixedExpression.new(
                base-expression => Rust::BaseExpression.new(
                    expression-item => $expression-item,
                ),
                suffixed-expression-suffix => [
                    to-rust-index-expression-suffix($bracketed)
                ],
            )
        }
        default {
            die "need to consider token-types: $_";
        }
    }
}

multi sub to-rust-suffixed-expression($item where Cpp::PostfixExpression) {  
    translate-postfix-expression($item, $item.token-types)
}

multi sub to-rust-suffixed-expression($item where Cpp::InclusiveOrExpression) {  
    ddt $item;
    exit;
}

multi sub to-rust-suffixed-expression($item where Cpp::IntegerLiteral::Dec) {  
    Rust::SuffixedExpression.new(
        base-expression => Rust::BaseExpression.new(
            expression-item => Rust::IntegerLiteral.new(
                value => $item.decimal-literal.value
            )
        ),
    )
}

multi sub to-rust-suffixed-expression($item where Cpp::CharacterLiteral) {  
    Rust::SuffixedExpression.new(
        base-expression => Rust::BaseExpression.new(
            expression-item => Rust::CharLiteral.new(

                #it is possible we want to do more
                #than just take the gist here...
                value => $item.gist
            )
        ),
    )
}

multi sub to-rust-suffixed-expression($item) {  
    die "need write hook for suffixed-expression! {$item.WHAT.^name}";
}
