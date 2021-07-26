use util;

our sub translate-operator-into-bool($submatch, $body, $rclass) {

    my (
        $rcomments-list,
        $rinline, 
        $rtype 
    ) = rparse-operator-into-bool($submatch);

    my $rcomment       = format-rust-comments($rcomments-list);


    qq:to/END/;
    impl Into<{$rtype}> for $rclass \{

        $rcomment
        {$rinline}fn into(self) -> $rtype \{
            todo!();
            /*
            {$body.trim.chomp.indent(4)}
            */
        \}
    \}
    END
}

