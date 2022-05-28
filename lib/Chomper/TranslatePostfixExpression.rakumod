use Data::Dump::Tree;
use Chomper::ToRustIdent;
use Chomper::ToRustParams;
use Chomper::ToRust;
use Chomper::SnakeCase;
use Chomper::Cpp;
use Chomper::Rust;

proto sub translate-postfix-expression(
    $item where Cpp::PostfixExpression, 
    Positional $token-types) 
is export { * }

multi sub translate-postfix-expression(
    $item, 
    Positional $token-types) 
{ 
    say "need write translate-postfix-expression for token-types: {$item.token-types()}";
    ddt $item;
    exit;
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
    ]) 
{ 
    #this one is basically a run of the mill
    #function call on an identifier

    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id = @tail[0];
    my $expr-list      = @tail[1].expression-list;

    my $params 
    = $expr-list ?? to-rust-params($expr-list)>>.gist.join(", ") !! "";

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$ident}).{$func}({$params})"
    } else {
        "{$ident}.{$func}({$params})"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::PlusPlus',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id = @tail[0];

    my $id1 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $id2 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$id1}).{$id2} += 1"
    } else {
        "{$id1}.{$id2} += 1"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::MinusMinus',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id = @tail[0];

    my $id1 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $id2 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$id1}).{$id2} -= 1"
    } else {
        "{$id1}.{$id2} -= 1"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::Bracket',
    ]) 
{ 
    my $base 
    = to-rust($item.postfix-expression-body.id-expression);

    my $bracketed-expr 
    = to-rust($item.postfix-expression-tail[0].bracket-tail.expression);

    Rust::SuffixedExpression.new(
        base-expression            => $base,
        suffixed-expression-suffix => [
            Rust::IndexExpressionSuffix.new(
                expression => $bracketed-expr,
            )
        ]
    )
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::Bracket',
        'PostfixExpressionTail::Bracket',
    ]) 
{ 
    my $base 
    = to-rust($item.postfix-expression-body.id-expression);

    my $bracketed-expr1
    = to-rust($item.postfix-expression-tail[0].bracket-tail.expression);

    my $bracketed-expr2
    = to-rust($item.postfix-expression-tail[1].bracket-tail.expression);

    Rust::SuffixedExpression.new(
        base-expression            => $base,
        suffixed-expression-suffix => [
            Rust::IndexExpressionSuffix.new(
                expression => $bracketed-expr1,
            ),
            Rust::IndexExpressionSuffix.new(
                expression => $bracketed-expr2,
            )
        ]
    )
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Bracket',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id    = @tail[0];

    my $rust-bracket-expr = to-rust(@tail[1].bracket-tail.expression);

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$ident}).{$func}[$rust-bracket-expr]"
    } else {
        "{$ident}.{$func}[$rust-bracket-expr]"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::Bracket',
        'PostfixExpressionTail::IndirectionId',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $rust-bracket-expr = to-rust(@tail[0].bracket-tail.expression);

    my $indirection-id    = @tail[1];

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$ident}).{$func}[$rust-bracket-expr]"
    } else {
        "{$ident}.{$func}[$rust-bracket-expr]"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
        'PostfixExpressionTail::Bracket',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id    = @tail[0];
    my $expr-list         = @tail[1].expression-list;

    my $rust-bracket-expr = to-rust(@tail[2].bracket-tail.expression);

    my $params 
    = $expr-list ?? to-rust-params($expr-list)>>.gist.join(", ") !! "";

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$ident}).{$func}({$params})[$rust-bracket-expr]"
    } else {
        "{$ident}.{$func}({$params})[$rust-bracket-expr]"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::Bracket',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $rust-bracket-expr = to-rust(@tail[0].bracket-tail.expression);
    my $indirection-id    = @tail[1];
    my $expr-list         = @tail[2].expression-list;

    my $params 
    = $expr-list ?? to-rust-params($expr-list)>>.gist.join(", ") !! "";

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$ident}[$rust-bracket-expr]).{$func}({$params})"
    } else {
        "{$ident}[$rust-bracket-expr].{$func}({$params})"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-idA = @tail[0];
    my $expr-listA      = @tail[1].expression-list;
    my $indirection-idB = @tail[2];
    my $expr-listB      = @tail[3].expression-list;

    my $paramsA 
    = $expr-listA ?? to-rust-params($expr-listA)>>.gist.join(", ") !! "";

    my $paramsB 
    = $expr-listB ?? to-rust-params($expr-listB)>>.gist.join(", ") !! "";

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $funcA 
    = snake-case(to-rust($indirection-idA.id-expression).gist);

    my $funcB 
    = snake-case(to-rust($indirection-idB.id-expression).gist);

    my Bool $indirectA = $indirection-idA.indirect;
    my Bool $indirectB = $indirection-idB.indirect;

    if $indirectA {

        if $indirectB {
            "(*(*{$ident}).{$funcA}({$paramsA})).{$funcB}({$paramsB})"
        } else {
            "(*{$ident}).{$funcA}({$paramsA}).{$funcB}({$paramsB})"
        }

    } else {

        if $indirectB {
            "(*{$ident}.{$funcA}({$paramsA})).{$funcB}({$paramsB})"
        } else {
            "{$ident}.{$funcA}({$paramsA}).{$funcB}({$paramsB})"
        }
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::PlusPlus',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $increment-x = Rust::AddEqExpression.new(
        minuseq-expressions => [
            $ident,
            Rust::IntegerLiteral.new(
                value => 1
            )
        ]
    );

    my $old = Rust::SuffixedExpression.new(
        base-expression => Rust::BaseExpression.new(
            expression-item => Rust::PathInExpression.new(
                path-expr-segments => [
                    Rust::PathExprSegment.new(
                        path-ident-segment => Rust::Identifier.new(
                            value => "old"
                        )
                    )
                ]
            )
        )
    );

    my $store-x-to-old = Rust::LetStatement.new(
        pattern-no-top-alt => Rust::IdentifierPattern.new(
            ref        => False,
            mutable    => False,
            identifier => Rust::Identifier.new(
                value => "old",
            )
        ),
        maybe-expression => Rust::SuffixedExpression.new(
            base-expression => Rust::BaseExpression.new(
                expression-item => Rust::PathInExpression.new(
                    path-expr-segments => [
                        Rust::PathExprSegment.new(
                            path-ident-segment => Rust::Identifier.new(
                                value => $ident
                            )
                        )
                    ]
                )
            )
        )
    );

    Rust::BlockExpression.new(
        statements => Rust::Statements.new(
            statements => [
                $store-x-to-old,
                Rust::ExpressionStatementNoBlock.new(
                    expression-noblock => $increment-x,
                )
            ],
            maybe-expression-noblock => $old
        )
    ).gist
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::MinusMinus',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $increment-x = Rust::MinusEqExpression.new(
        stareq-expressions => [
            $ident,
            Rust::IntegerLiteral.new(
                value => 1
            )
        ]
    );

    my $old = Rust::SuffixedExpression.new(
        base-expression => Rust::BaseExpression.new(
            expression-item => Rust::PathInExpression.new(
                path-expr-segments => [
                    Rust::PathExprSegment.new(
                        path-ident-segment => Rust::Identifier.new(
                            value => "old"
                        )
                    )
                ]
            )
        )
    );

    my $store-x-to-old = Rust::LetStatement.new(
        pattern-no-top-alt => Rust::IdentifierPattern.new(
            ref        => False,
            mutable    => False,
            identifier => Rust::Identifier.new(
                value => "old",
            )
        ),
        maybe-expression => Rust::SuffixedExpression.new(
            base-expression => Rust::BaseExpression.new(
                expression-item => Rust::PathInExpression.new(
                    path-expr-segments => [
                        Rust::PathExprSegment.new(
                            path-ident-segment => Rust::Identifier.new(
                                value => $ident
                            )
                        )
                    ]
                )
            )
        )
    );

    Rust::BlockExpression.new(
        statements => Rust::Statements.new(
            statements => [
                $store-x-to-old,
                Rust::ExpressionStatementNoBlock.new(
                    expression-noblock => $increment-x,
                )
            ],
            maybe-expression-noblock => $old
        )
    ).gist
}


multi sub translate-postfix-expression(
    $item, 
    [
        'PostfixExpressionList',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
    ]) 
{ 
    my $list = to-rust($item.postfix-expression-body).gist;

    my @tail = $item.postfix-expression-tail;

    my $indirection-id = @tail[0];
    my $expr-list      = @tail[1].expression-list;

    my $params 
    = $expr-list ?? to-rust-params($expr-list)>>.gist.join(", ") !! "";

    my $func 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$list}).{$func}({$params})"
    } else {
        "{$list}.{$func}({$params})"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
    ]) 
{ 
    #this one is basically a run of the mill
    #function call on an identifier

    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id-a = @tail[0];
    my $indirection-id-b = @tail[1];
    my $expr-list        = @tail[2].expression-list;

    my $params 
    = $expr-list ?? to-rust-params($expr-list)>>.gist.join(", ") !! "";

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func-a 
    = snake-case(to-rust($indirection-id-a.id-expression).gist);

    my $func-b 
    = snake-case(to-rust($indirection-id-b.id-expression).gist);

    my Bool $indirect-a = $indirection-id-a.indirect;
    my Bool $indirect-b = $indirection-id-b.indirect;

    if $indirect-a {

        if $indirect-b {
            "(*(*{$ident}).{$func-a}).{$func-b}({$params})"
        } else {
            "(*{$ident}).{$func-a}.{$func-b}({$params})"
        }

    } else {

        if $indirect-b {
            "(*{$ident}.{$func-a}).{$func-b}({$params})"
        } else {
            "{$ident}.{$func-a}.{$func-b}({$params})"
        }
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
    ]) 
{ 
    #this one is basically a run of the mill
    #function call on an identifier

    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id-a = @tail[0];
    my $indirection-id-b = @tail[1];
    my $indirection-id-c = @tail[2];
    my $expr-list        = @tail[3].expression-list;

    my $params 
    = $expr-list ?? to-rust-params($expr-list)>>.gist.join(", ") !! "";

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func-a 
    = snake-case(to-rust($indirection-id-a.id-expression).gist);

    my $func-b 
    = snake-case(to-rust($indirection-id-b.id-expression).gist);

    my $func-c 
    = snake-case(to-rust($indirection-id-c.id-expression).gist);

    my Bool $indirect-a = $indirection-id-a.indirect;
    my Bool $indirect-b = $indirection-id-b.indirect;
    my Bool $indirect-c = $indirection-id-c.indirect;

    if $indirect-a {
        if $indirect-b {
            if $indirect-c {
                "(*(*(*{$ident}).{$func-a}).{$func-b}).{$func-c}({$params})"
            } else {
                "(*(*{$ident}).{$func-a}).{$func-b}.{$func-c}({$params})"
            }
        } else {
            if $indirect-c {
                "(*(*{$ident}).{$func-a}.{$func-b}).{$func-c}({$params})"
            } else {
                "(*{$ident}).{$func-a}.{$func-b}.{$func-c}({$params})"
            }
        }

    } else {

        if $indirect-b {
            if $indirect-c {
                "(*(*{$ident}.{$func-a}).{$func-b}).{$func-c}({$params})"
            } else {
                "(*{$ident}.{$func-a}).{$func-b}.{$func-c}({$params})"
            }
        } else {
            if $indirect-c {
                "(*{$ident}.{$func-a}.{$func-b}).{$func-c}({$params})"
            } else {
                "{$ident}.{$func-a}.{$func-b}.{$func-c}({$params})"
            }
        }
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
    ]) 
{ 
    #this one is basically a run of the mill
    #function call on an identifier

    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id = @tail[0];

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func 
    = snake-case(to-rust($indirection-id.id-expression).gist);

    my Bool $indirect = $indirection-id.indirect;

    if $indirect {
        "(*{$ident}).{$func}"
    } else {
        "{$ident}.{$func}"
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Bracket',
        'PostfixExpressionTail::IndirectionId',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id-a  = @tail[0];
    my $rust-bracket-expr = to-rust(@tail[1].bracket-tail.expression);
    my $indirection-id-b  = @tail[2];

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func-a 
    = snake-case(to-rust($indirection-id-a.id-expression).gist);

    my $func-b 
    = snake-case(to-rust($indirection-id-b.id-expression).gist);

    my Bool $indirect-a = $indirection-id-a.indirect;
    my Bool $indirect-b = $indirection-id-b.indirect;

    if $indirect-a {
        if $indirect-b {
            "(*(*{$ident}).{$func-a}[$rust-bracket-expr]).{$func-b}"
        } else {
            "(*{$ident}).{$func-a}[$rust-bracket-expr].{$func-b}"
        }
    } else {
        if $indirect-b {
            "(*{$ident}.{$func-a}[$rust-bracket-expr]).{$func-b}"
        } else {
            "{$ident}.{$func-a}[$rust-bracket-expr].{$func-b}"
        }
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Bracket',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id-a  = @tail[0];
    my $indirection-id-b  = @tail[1];
    my $rust-bracket-expr = to-rust(@tail[2].bracket-tail.expression);

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func-a 
    = snake-case(to-rust($indirection-id-a.id-expression).gist);

    my $func-b 
    = snake-case(to-rust($indirection-id-b.id-expression).gist);

    my Bool $indirect-a = $indirection-id-a.indirect;
    my Bool $indirect-b = $indirection-id-b.indirect;

    if $indirect-a {
        if $indirect-b {
            "(*(*{$ident}.{$func-a})).{$func-b}[$rust-bracket-expr]"
        } else {
            "(*{$ident}.{$func-a}).{$func-b}[$rust-bracket-expr]"
        }
    } else {
        if $indirect-b {
            "(*{$ident}.{$func-a}).{$func-b}[$rust-bracket-expr]"
        } else {
            "{$ident}.{$func-a}.{$func-b}[$rust-bracket-expr]"
        }
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Bracket',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::IndirectionId',
    ]) 
{ 
    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id-a  = @tail[0];
    my $rust-bracket-expr = to-rust(@tail[1].bracket-tail.expression);
    my $indirection-id-b  = @tail[2];
    my $indirection-id-c  = @tail[3];

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func-a 
    = snake-case(to-rust($indirection-id-a.id-expression).gist);

    my $func-b 
    = snake-case(to-rust($indirection-id-b.id-expression).gist);

    my $func-c 
    = snake-case(to-rust($indirection-id-c.id-expression).gist);

    my Bool $indirect-a = $indirection-id-a.indirect;
    my Bool $indirect-b = $indirection-id-b.indirect;
    my Bool $indirect-c = $indirection-id-c.indirect;

    if $indirect-a {
        if $indirect-b {
            if $indirect-c {
                "(*(*(*{$ident}).{$func-a}[$rust-bracket-expr]).{$func-b}).{$func-c}"
            } else {
                "(*(*{$ident}).{$func-a}[$rust-bracket-expr]).{$func-b}.{$func-c}"
            }
        } else {
            if $indirect-c {
                "(*(*{$ident}).{$func-a}[$rust-bracket-expr].{$func-b}).{$func-c}"
            } else {
                "(*{$ident}).{$func-a}[$rust-bracket-expr].{$func-b}.{$func-c}"
            }
        }
    } else {
        if $indirect-b {
            if $indirect-c {
                "(*(*{$ident}.{$func-a}[$rust-bracket-expr]).{$func-b}).{$func-c}"
            } else {
                "(*{$ident}.{$func-a}[$rust-bracket-expr]).{$func-b}.{$func-c}"
            }
        } else {
            if $indirect-c {
                "(*{$ident}.{$func-a}[$rust-bracket-expr].{$func-b}).{$func-c}"
            } else {
                "{$ident}.{$func-a}[$rust-bracket-expr].{$func-b}.{$func-c}"
            }
        }
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::IndirectionId',
    ]) 
{ 
    #this one is basically a run of the mill
    #function call on an identifier

    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id-a = @tail[0];
    my $indirection-id-b = @tail[1];

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func-a 
    = snake-case(to-rust($indirection-id-a.id-expression).gist);

    my $func-b 
    = snake-case(to-rust($indirection-id-b.id-expression).gist);

    my Bool $indirect-a = $indirection-id-a.indirect;
    my Bool $indirect-b = $indirection-id-b.indirect;

    if $indirect-a {

        if $indirect-b {
            "(*(*{$ident}).{$func-a}).{$func-b}"
        } else {
            "(*{$ident}).{$func-a}.{$func-b}"
        }

    } else {

        if $indirect-b {
            "(*{$ident}.{$func-a}).{$func-b}"
        } else {
            "{$ident}.{$func-a}.{$func-b}"
        }
    }
}

multi sub translate-postfix-expression(
    $item, 
    [
        'PrimaryExpression::Id',
        'PostfixExpressionTail::IndirectionId',
        'PostfixExpressionTail::Parens',
        'PostfixExpressionTail::IndirectionId',
    ]) 
{ 
    #this one is basically a run of the mill
    #function call on an identifier

    my $body = $item.postfix-expression-body.id-expression;
    my @tail = $item.postfix-expression-tail;

    my $indirection-id-a = @tail[0];
    my $expr-list        = @tail[1].expression-list;
    my $indirection-id-b = @tail[2];

    my $params 
    = $expr-list ?? to-rust-params($expr-list)>>.gist.join(", ") !! "";

    my $ident 
    = snake-case(to-rust-ident($body, snake-case => True).gist);

    my $func-a 
    = snake-case(to-rust($indirection-id-a.id-expression).gist);

    my $func-b 
    = snake-case(to-rust($indirection-id-b.id-expression).gist);

    my Bool $indirect-a = $indirection-id-a.indirect;
    my Bool $indirect-b = $indirection-id-b.indirect;

    if $indirect-a {
        if $indirect-b {
            "(*(*{$ident}).{$func-a}({$params})).{$func-b}"
        } else {
            "(*{$ident}).{$func-a}({$params}).{$func-b}"
        }

    } else {

        if $indirect-b {
            "(*{$ident}.{$func-a}({$params})).{$func-b}"
        } else {
            "{$ident}.{$func-a}({$params}).{$func-b}"
        }
    }
}
