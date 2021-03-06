use Chomper::Util;
use Chomper::WrapBodyTodo;

our sub translate-op-negate($submatch, $body, $rclass) {

    my ( $rcomments-list,
            $rinline, 
            $rtype) = 
        rparse-operator-negate($submatch);

    my $rcomment       = format-rust-comments($rcomments-list);

    qq:to/END/;
    impl Neg for $rtype \{
        type Output = Self;

        $rcomment
        {$rinline}fn neg(self) -> Self::Output \{
            {wrap-body-todo($body)}
        \}
    \}
    END

}
