use Data::Dump::Tree;

our class ItemStruct {
    has $.struct-tuple-args;
    has $.struct-decl-args;
    has $.maybe-where-clause;
    has $.ident;
    has $.generic-params;

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

our class StructField {
    has $.comment;
    has $.attrs-and-vis;
    has $.ty-sum;
    has $.ident;

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

our role ItemStruct::Rules {

    #-------------------------
    proto rule item-struct { * }

    rule item-struct:sym<a> {
        <kw-struct> 
        <ident> 
        <generic-params> 
        <maybe-where-clause> 
        <struct-decl-args>
    }

    rule item-struct:sym<b> {
        <kw-struct> 
        <ident> 
        <generic-params> 
        <struct-tuple-args> 
        <maybe-where-clause> ';'
    }

    rule item-struct:sym<c> {
        <kw-struct> 
        <ident> 
        <generic-params> 
        <maybe-where-clause> ';'
    }

    #-------------------------
    rule struct-decl-args  { '{' <struct-decl-fields> ','? '}' }

    #-------------------------
    rule struct-tuple-args { '(' <struct-tuple-fields> ','? ')' }

    #-------------------------
    rule struct-decl-fields {
        <struct-decl-field>* %% ","
    }

    rule struct-decl-field {
        <comment>?
        <attrs-and-vis> <ident> ':' <ty-sum>
    }

    #-------------------------
    rule struct-tuple-fields {
        <struct-tuple-field>* %% ","
    }

    rule struct-tuple-field {
        <attrs-and-vis> <ty-sum>
    }
}

our role ItemStruct::Actions {

    method item-struct:sym<a>($/) {
        make ItemStruct.new(
            ident              =>  $<ident>.made,
            generic-params     =>  $<generic-params>.made,
            maybe-where-clause =>  $<maybe-where-clause>.made,
            struct-decl-args   =>  $<struct-decl-args>.made,
            text               => ~$/,
        )
    }

    method item-struct:sym<b>($/) {
        make ItemStruct.new(
            ident              =>  $<ident>.made,
            generic-params     =>  $<generic-params>.made,
            struct-tuple-args  =>  $<struct-tuple-args>.made,
            maybe-where-clause =>  $<maybe-where-clause>.made,
            text               => ~$/,
        )
    }

    method item-struct:sym<c>($/) {
        make ItemStruct.new(
            ident              =>  $<ident>.made,
            generic-params     =>  $<generic-params>.made,
            maybe-where-clause =>  $<maybe-where-clause>.made,
            text               => ~$/,
        )
    }

    method struct-decl-args($/) {
        make $<struct-decl-fields>.made
    }

    method struct-tuple-args($/) {
        make $<struct-tuple-fields>.made
    }

    method struct-decl-fields($/) {
        make $<struct-decl-field>>>.made
    }

    method struct-decl-field($/) {
        make StructField.new(
            comment       => $<comment>.made,
            attrs-and-vis => $<attrs-and-vis>.made,
            ident         => $<ident>.made,
            ty-sum        => $<ty-sum>.made,
            text          => ~$/,
        )
    }

    method struct-tuple-fields($/) {
        make $<struct-tuple-field>>>.made
    }

    method struct-tuple-field($/) {
        make StructField.new(
            attrs-and-vis =>  $<attrs-and-vis>.made,
            ty-sum        =>  $<ty-sum>.made,
            text          => ~$/,
        )
    }
}