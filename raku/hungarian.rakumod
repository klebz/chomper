our sub remove-hungarian-constant-prefix(Str $text) {
    my $out = $text;
    $out ~~ s/^<[kK]>_//;
    $out
}

our sub current-project-needs-strip-hungarian {
    #only need to pull hungarian prefixes off
    #cryengine structs
    my $cry     = $*CWD.Str.split("/")[*-1] ~~ "cry-rs";
    my $bitcoin = $*CWD.Str.split("/")[*-1] ~~ "bitcoin-rs";
    $cry or $bitcoin
}

our sub avoid-hungarian($in) {
    my $out = $in.subst(/^m_/, "");
    $out ~~ s/^f_//;
    $out ~~ s/^i_//;
    $out ~~ s/^b_2/b2/;
    $out ~~ s/^b_//;
    $out ~~ s/^e_//;
    $out ~~ s/^p_//;
    $out ~~ s/^c_//;
    $out ~~ s/^s_//;
    #$out ~~ s/^n_//;
    $out ~~ s/^v_//;
    $out ~~ s/^u_//;

    #this is done with regular type translations
    #"class", "struct", "enum", any others? any problems?
    $out ~~ s/^C<?before <[A..Z]>>//;
=begin comment
    $out ~~ s/^S<?before <[A..Z]>>//;
    $out ~~ s/^E<?before <[A..Z]>>//;
=end comment

    $out
}

our grammar HungarianStruct {

    rule TOP {
        <.ws> <hungarian-ident>
    }

    token hungarian-ident {
        <hungarian-prefix> <camel-case-ident>
    }

   token hungarian-prefix {
        | 'S'
        | 'C'
        | 'E'
        | 'T'
    }

    token camel-case-ident {
        <camel-case-segment>+
    }

    token camel-case-segment {
        <[A..Z]> <[a..z]>*
    }
}
