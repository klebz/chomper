use Chomper::FormatTextwidth;
use Chomper::GetLeftMargin;
use Chomper::LineBreak;
use Chomper::MaximallyShiftTowardLeftMargin;
use Chomper::RemoveCommentTokens;
use Chomper::RemoveDoubleNewlines;
use Chomper::WrapComment;

our grammar DoxyComment::Grammar {

    rule TOP {
        <.ws> <armnn-comment>
    }

    regex armnn-comment {
        <line>+
    }

    regex line {
        || <.ws> <brief-stmt>       \n
        || <.ws> <code-stmt>        \n
        || <.ws> <param-stmt>       \n
        || <.ws> <deprecated-stmt>  \n
        || <.ws> <return-stmt>      \n
        || <.ws> <note-stmt>        \n
        || <.ws> <warning-stmt>     \n
        || <.ws> <description-stmt> \n
        || <.ws> <date-stmt>        \n
        || <basic-text>             \n
        || <empty-line>
    }
    regex empty-line {
        \s+
    }
    regex basic-text {
        || <basic-text-from-sentence-begin>
        || <basic-text-from-sentence-middle>
    }
    regex basic-text-from-sentence-middle {
        \N+
    }
    regex basic-text-from-sentence-begin {
       <.ws> <[A..Z -]> \N+
    }
    regex until-newline {
        \N+
    }
    token ident {
        | <[A..Z a..z 0..9 _]>+
        | '...'
    }
    regex in-out-core {
            | 'in'
            | 'out'
            | 'in,out'
            | 'in, out'
    }
    regex in-out {
        '[' <in-out-core> ']'
    }
    regex note-opener {
        | <.marker> <.kw-note> 
        | 'Note that'
        | 'note that'
        | 'Note:'
        | 'NOTE:'
    }
    regex note-stmt {
        <.note-opener>
        <.ws> <description=.until-newline>
    }
    regex warning-stmt {
        <.marker> <.kw-warning> 
        <.ws> <description=.until-newline>
    }
    regex description-stmt {
        <.marker> <.kw-description> 
        <.ws> <description=.until-newline>
    }
    regex date-stmt {
        <.marker> <.kw-date> 
        <.ws> <description=.until-newline>
    }
    regex code-stmt {
        <exempli-gratia>? <.marker> <.kw-code>
        <description=code-text> <.marker> <.kw-endcode>
    }
    regex exempli-gratia {
        <.ws> <[E e]> '.' <[G g]> '.' <.ws>
    }
    regex code-text {
        .*?
    }

    regex param-stmt {
        <.marker> <.kw-param> <in-out>? 
        <.ws> <param-name=.ident> 
        <.ws> <description=.until-newline>
    }

    regex deprecated-stmt {
        <.marker> <.kw-deprecated> 
        <.ws> <description=.until-newline>
    }

    regex return-stmt {
        <.marker> <.kw-return>  
        <.ws> <description=.until-newline>
    }

    regex brief-stmt {
        <.marker> <.kw-brief>  
        <.ws> <description=.until-newline>
    }

    token kw-code    { 'code' }
    token kw-endcode { 'endcode' }

    token kw-return {
        | 'return'
        | 'returns'
        | 'retval'
    }

    token kw-param {
        | 'param'
        | 'tparam'
    }

    token kw-deprecated {
        | 'deprecated'
    }

    token kw-warning {
        | 'warning'
    }

    token kw-description {
        | 'description'
    }

    token kw-date {
        | 'date'
    }

    token kw-note {
        | 'note'
    }
    token kw-brief {
        | 'brief'
    }

    token marker {
        | '@'
        | '\\'
    }
}

sub get-body($header, @tail, $approx-text-width) {

    sub get-tail-comment(@tail) {
        #`(TODO: probably remove redundancy with
        get-body)

        my $block = do for @tail {
            if $_ ~~ LineBreak {
                "\n"
            } else {

                #`(this is for text behind CodeExample
                we want to keep this in bounds)

                $_.chomp.trim
            }
        }.join(" ").chomp;

        format-textwidth(maximally-shift-toward-left-margin($block), 30)
    }

    if $approx-text-width {

        @tail.prepend: $header<description>.chomp.trim;

        my $res = do for @tail {
            if $_ ~~ LineBreak {
                "\n"
            } else {
                $_.chomp.trim
            }
        }.join(" ").chomp;

        format-textwidth(
            maximally-shift-toward-left-margin($res), 
            $approx-text-width
        )

    } else { #CodeExample

        my $code = maximally-shift-toward-left-margin(
            $header<description>.chomp
        ).chomp.trim;

        my $comment = get-tail-comment(@tail);

        qq:to/END/;
        $code
        $comment
        END
    }
}


our class DoxyComment {

    class Param {
        #`(represents parsed information concerning 
        parameters)

        has Match $.header is rw;
        has @.tail is rw;

        method format($approx-text-width) {

            my $in-out = $!header<in-out><in-out-core>;

            my $name   = $!header<param-name>.Str;

            my $header = do if $in-out {
                "@param\[{$in-out.Str.trim}\] $name"
            } else {
                "@param $name"
            };

            my $body   = get-body($.header, @.tail, $approx-text-width);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    class Ret {
        #`(represents parsed information concerning
        return values)

        has Match $.header is rw;
        has @.tail is rw;

        method format($approx-text-width) {
            my $header = "@return";
            my $body   = get-body($.header, @.tail, $approx-text-width);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    class Brief {
        #`(represents parsed information concerning
        the brief description)

        has Match $.header is rw;
        has @.tail is rw;

        method format($approx-text-width) {
            my $header = "@brief";
            my $body   = get-body($.header, @.tail, $approx-text-width);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    class Deprecated {
        #`(represents parsed information concerning
        the deprecated description)

        has Match $.header is rw;
        has @.tail is rw;

        method format($approx-text-width) {
            my $header = "@deprecated";
            my $body   = get-body($.header, @.tail, $approx-text-width);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    class Note {
        #`(represents parsed information concerning
        any notes)

        has Match $.header is rw;
        has @.tail is rw;

        method format($approx-text-width) {
            my $header = "@note";
            my $body   = get-body($.header, @.tail, $approx-text-width);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    class Warning {
        #`(represents parsed information concerning
        any warnings)

        has Match $.header is rw;
        has @.tail is rw;

        method format($approx-text-width) {
            my $header = "@warning";
            my $body   = get-body($.header, @.tail, $approx-text-width);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    class Description {
        #`(represents parsed information concerning
        any descriptions)

        has Match $.header is rw;
        has @.tail is rw;

        method format($approx-text-width) {
            my $header = "@description";
            my $body   = get-body($.header, @.tail, $approx-text-width);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    class DateNote {
        #`(represents parsed information concerning
        any date note)

        has Match $.header is rw;
        has @.tail is rw;

        method format($approx-text-width) {
            my $header = "@date";
            my $body   = get-body($.header, @.tail, $approx-text-width);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    class CodeExample {
        #`(represents parsed information concerning
        code examples)

        has Match $.header is rw;
        has @.tail is rw;

        method format-no-width() {
            my $header = "@code";
            my $body   = get-body($.header, @.tail, Nil);

            qq:to/END/.chomp.trim;
            $header

            $body
            END
        }
    }

    submethod BUILD(Match :$armnn-comment) {

        my @lines = $armnn-comment<line>.List;

        enum ParseState <Header Params CodeExamples Returns Briefs Notes Warnings Descriptions Dates Deprecateds>;

        my ParseState $state = Header;

        my $cur-item = Nil;

        sub maybe-update-state($line) {
            if $line<param-stmt>:exists {
                $state = Params;
                return True;
            }

            if $line<note-stmt>:exists {
                $state = Notes;
                return True;
            }

            if $line<deprecated-stmt>:exists {
                $state = Deprecateds;
                return True;
            }

            if $line<code-stmt>:exists {
                $state = CodeExamples;
                return True;
            }

            if $line<warning-stmt>:exists {
                $state = Warnings;
                return True;
            }

            if $line<description-stmt>:exists {
                $state = Descriptions;
                return True;
            }

            if $line<date-stmt>:exists {
                $state = Dates;
                return True;
            }

            if $line<return-stmt>:exists {
                $state = Returns;
                return True;
            }

            if $line<brief-stmt>:exists {
                $state = Briefs;
                return True;
            }

            return False;
        }

        sub flush-cur-item {
            if $cur-item {
                given $cur-item {

                    when DoxyComment::Param {
                        @!params.push: $cur-item;
                    }
                    when DoxyComment::Deprecated {
                        @!deprecateds.push: $cur-item;
                    }
                    when DoxyComment::Note {
                        @!notes.push: $cur-item;
                    }
                    when DoxyComment::CodeExample {
                        @!code-examples.push: $cur-item;
                    }
                    when DoxyComment::Warning {
                        @!warnings.push: $cur-item;
                    }
                    when DoxyComment::Description {
                        @!descriptions.push: $cur-item;
                    }
                    when DoxyComment::DateNote {
                        @!dates.push: $cur-item;
                    }
                    when DoxyComment::Ret {
                        @!returns.push: $cur-item;
                    }
                    when DoxyComment::Brief {
                        @!briefs.push: $cur-item;
                    }
                }
                $cur-item = Nil;
            }
        }

        sub new-cur-item($state, $line) {

            if $cur-item {
                die "cur-item already set!";
            }

            my $res;

            given $state {
                when Header { 
                    die "invalid control flow";
                }
                when Params {
                    $res = DoxyComment::Param.new;
                    $res.header = $line<param-stmt>;
                }
                when CodeExamples {
                    $res = DoxyComment::CodeExample.new;
                    $res.header = $line<code-stmt>;
                }
                when Notes {
                    $res = DoxyComment::Note.new;
                    $res.header = $line<note-stmt>;
                }
                when Deprecateds {
                    $res = DoxyComment::Deprecated.new;
                    $res.header = $line<deprecated-stmt>;
                }
                when Warnings {
                    $res = DoxyComment::Warning.new;
                    $res.header = $line<warning-stmt>;
                }
                when Descriptions {
                    $res = DoxyComment::Description.new;
                    $res.header = $line<description-stmt>;
                }
                when Dates {
                    $res = DoxyComment::DateNote.new;
                    $res.header = $line<date-stmt>;
                }
                when Returns {
                    $res = DoxyComment::Ret.new;
                    $res.header = $line<return-stmt>;
                }
                when Briefs {
                    $res = DoxyComment::Brief.new;
                    $res.header = $line<brief-stmt>;
                }
            }

            $res
        }

        for @lines -> $line {

            my $updated = maybe-update-state($line);

            if $updated {
                flush-cur-item();
                $cur-item = new-cur-item($state, $line);
            }

            sub add-basic-text($txt) {
                if $state eq Header {
                    @!header.push: $txt;
                } else {
                    $cur-item.tail.push: $txt;
                }
            }

            if $line<basic-text>:exists {
                if $line<basic-text><basic-text-from-sentence-begin>:exists {
                    add-basic-text(LineBreak.new);
                }
                add-basic-text($line<basic-text>.Str);
            }

            if $line<empty-line>:exists {
                if $state eq Header {
                    @!header.push: LineBreak.new;
                } else {
                    $cur-item.tail.push: LineBreak.new;
                }
            }
        }

        flush-cur-item();
    }

    has @.header;
    has Param       @.params;
    has Deprecated  @.deprecateds;
    has Ret         @.returns;
    has Note        @.notes;
    has CodeExample @.code-examples;
    has Warning     @.warnings;
    has Description @.descriptions;
    has DateNote    @.dates;
    has Brief       @.briefs;

    method header-line {

        my @text;

        for @!header -> $header-line {

            if $header-line ~~ LineBreak {
                @text.push: "\n";
                next;
            }

            my $line = $header-line.trim-leading;

            my $cond = $line.ends-with("\n\n ");

            my $processed = $cond
            ?? "{$line.chomp.trim}\n"
            !! "{$line.chomp.trim} ";

            @text.push: $processed;
        }

        @text.join(" ")
    }

    method format-params($approx-text-width) {
        @!params>>.format($approx-text-width)
    }

    method format-returns($approx-text-width) {
        @!returns>>.format($approx-text-width)
    }

    method format-code-examples-no-width() {
        @!code-examples>>.format-no-width()
    }

    method format-briefs($approx-text-width) {
        @!briefs>>.format($approx-text-width)
    }

    method format-deprecateds($approx-text-width) {
        @!deprecateds>>.format($approx-text-width)
    }

    method format-notes($approx-text-width) {
        @!notes>>.format($approx-text-width)
    }

    method format-warnings($approx-text-width) {
        @!warnings>>.format($approx-text-width)
    }

    method format-descriptions($approx-text-width) {
        @!descriptions>>.format($approx-text-width)
    }

    method format-date-notes($approx-text-width) {
        @!dates>>.format($approx-text-width)
    }

    method format-text(@lines) {
        qq:to/END/;
        -----------
        {@lines.join("\n----------\n")}
        END
    }

    method formatted(:$approx-text-width) {

        my $header  = format-textwidth(self.header-line, $approx-text-width);

        my @notes         = self.format-notes($approx-text-width);
        my @warnings      = self.format-warnings($approx-text-width);
        my @descriptions  = self.format-descriptions($approx-text-width);
        my @dates         = self.format-date-notes($approx-text-width);
        my @params        = self.format-params($approx-text-width);
        my @deprecateds   = self.format-deprecateds($approx-text-width);
        my @returns       = self.format-returns($approx-text-width);
        my @code-examples = self.format-code-examples-no-width();
        my @briefs        = self.format-briefs($approx-text-width);

        my $params-text        = self.format-text(@params);
        my $deprecateds-text   = self.format-text(@deprecateds);
        my $notes-text         = self.format-text(@notes);
        my $warnings-text      = self.format-text(@warnings);
        my $descriptions-text  = self.format-text(@descriptions);
        my $dates-text         = self.format-text(@dates);
        my $code-examples-text = self.format-text(@code-examples);
        my $returns-text       = self.format-text(@returns);
        my $briefs-text        = self.format-text(@briefs);

        my $result  = qq:to/END/.chomp.trim;
        $header

        {@briefs.elems        ?? $briefs-text        !! ""}
        {@notes.elems         ?? $notes-text         !! ""}
        {@params.elems        ?? $params-text        !! ""}
        {@deprecateds.elems   ?? $deprecateds-text   !! ""}
        {@warnings.elems      ?? $warnings-text      !! ""}
        {@descriptions.elems  ?? $descriptions-text  !! ""}
        {@dates.elems         ?? $dates-text         !! ""}
        {@code-examples.elems ?? $code-examples-text !! ""}
        {@returns.elems       ?? $returns-text       !! ""}
        END

        wrap-comment(remove-double-newlines($result))
    }
}

our sub parse-doxy-comment(Str $in, :$indent = False) {

    my $text  = remove-comment-tokens($in);

    my $match = 
    DoxyComment::Grammar.parse($text)<armnn-comment>;

    my $res = DoxyComment.new(
        armnn-comment => $match
    ).formatted(approx-text-width => 30);

    $indent 
    ?? $res.indent(4) 
    !! $res
}
