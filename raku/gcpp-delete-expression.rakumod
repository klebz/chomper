
# rule delete-expression { 
#   <doublecolon>? 
#   <delete> 
#   [ <.left-bracket> <.right-bracket> ]? 
#   <cast-expression> 
# }
our class DeleteExpression { 
    has ICastExpression $.cast-expression is required;

    has $.text;

    method gist{
        say "need write gist!";
        ddt self;
        exit;
    }
}
