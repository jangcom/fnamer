#!/usr/bin/perl
use strict;
use warnings;
use autodie;
use Carp qw(croak);
use Cwd qw(getcwd);
use DateTime;
use feature qw(say);
use File::Basename qw(basename);
use constant ARRAY => ref [];
use constant HASH  => ref {};


our $VERSION = '2.01';
our $LAST    = '2019-04-19';
our $FIRST   = '2017-05-15';


#----------------------------------My::Toolset----------------------------------
sub show_front_matter {
    # """Display the front matter."""
    
    my $prog_info_href = shift;
    my $sub_name = join('::', (caller(0))[0, 3]);
    croak "The 1st arg of [$sub_name] must be a hash ref!"
        unless ref $prog_info_href eq HASH;
    
    # Subroutine optional arguments
    my(
        $is_prog,
        $is_auth,
        $is_usage,
        $is_timestamp,
        $is_no_trailing_blkline,
        $is_no_newline,
        $is_copy,
    );
    my $lead_symb = '';
    foreach (@_) {
        $is_prog                = 1  if /prog/i;
        $is_auth                = 1  if /auth/i;
        $is_usage               = 1  if /usage/i;
        $is_timestamp           = 1  if /timestamp/i;
        $is_no_trailing_blkline = 1  if /no_trailing_blkline/i;
        $is_no_newline          = 1  if /no_newline/i;
        $is_copy                = 1  if /copy/i;
        # A single non-alphanumeric character
        $lead_symb              = $_ if /^[^a-zA-Z0-9]$/;
    }
    my $newline = $is_no_newline ? "" : "\n";
    
    #
    # Fill in the front matter array.
    #
    my @fm;
    my $k = 0;
    my $border_len = $lead_symb ? 69 : 70;
    my %borders = (
        '+' => $lead_symb.('+' x $border_len).$newline,
        '*' => $lead_symb.('*' x $border_len).$newline,
    );
    
    # Top rule
    if ($is_prog or $is_auth) {
        $fm[$k++] = $borders{'+'};
    }
    
    # Program info, except the usage
    if ($is_prog) {
        $fm[$k++] = sprintf(
            "%s%s - %s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $prog_info_href->{titl},
            $prog_info_href->{expl},
            $newline,
        );
        $fm[$k++] = sprintf(
            "%sVersion %s (%s)%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $prog_info_href->{vers},
            $prog_info_href->{date_last},
            $newline,
        );
    }
    
    # Timestamp
    if ($is_timestamp) {
        my %datetimes = construct_timestamps('-');
        $fm[$k++] = sprintf(
            "%sCurrent time: %s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $datetimes{ymdhms},
            $newline,
        );
    }
    
    # Author info
    if ($is_auth) {
        $fm[$k++] = $lead_symb.$newline if $is_prog;
        $fm[$k++] = sprintf(
            "%s%s%s",
            ($lead_symb ? $lead_symb.' ' : $lead_symb),
            $prog_info_href->{auth}{$_},
            $newline,
        ) for qw(name posi affi mail);
    }
    
    # Bottom rule
    if ($is_prog or $is_auth) {
        $fm[$k++] = $borders{'+'};
    }
    
    # Program usage: Leading symbols are not used.
    if ($is_usage) {
        $fm[$k++] = $newline if $is_prog or $is_auth;
        $fm[$k++] = $prog_info_href->{usage};
    }
    
    # Feed a blank line at the end of the front matter.
    if (not $is_no_trailing_blkline) {
        $fm[$k++] = $newline;
    }
    
    #
    # Print the front matter.
    #
    if ($is_copy) {
        return @fm;
    }
    else {
        print for @fm;
        return;
    }
}


sub validate_argv {
    # """Validate @ARGV against %cmd_opts."""
    
    my $argv_aref     = shift;
    my $cmd_opts_href = shift;
    my $sub_name = join('::', (caller(0))[0, 3]);
    croak "The 1st arg of [$sub_name] must be an array ref!"
        unless ref $argv_aref eq ARRAY;
    croak "The 2nd arg of [$sub_name] must be a hash ref!"
        unless ref $cmd_opts_href eq HASH;
    
    # For yn prompts
    my $the_prog = (caller(0))[1];
    my $yn;
    my $yn_msg = "    | Want to see the usage of $the_prog? [y/n]> ";
    
    #
    # Terminate the program if the number of required arguments passed
    # is not sufficient.
    #
    my $argv_req_num = shift; # (OPTIONAL) Number of required args
    if (defined $argv_req_num) {
        my $argv_req_num_passed = grep $_ !~ /-/, @$argv_aref;
        if ($argv_req_num_passed < $argv_req_num) {
            printf(
                "\n    | You have input %s nondash args,".
                " but we need %s nondash args.\n",
                $argv_req_num_passed,
                $argv_req_num,
            );
            print $yn_msg;
            while ($yn = <STDIN>) {
                system "perldoc $the_prog" if $yn =~ /\by\b/i;
                exit if $yn =~ /\b[yn]\b/i;
                print $yn_msg;
            }
        }
    }
    
    #
    # Count the number of correctly passed command-line options.
    #
    
    # Non-fnames
    my $num_corr_cmd_opts = 0;
    foreach my $arg (@$argv_aref) {
        foreach my $v (values %$cmd_opts_href) {
            if ($arg =~ /$v/i) {
                $num_corr_cmd_opts++;
                next;
            }
        }
    }
    
    # Fname-likes
    my $num_corr_fnames = 0;
    $num_corr_fnames = grep $_ !~ /^-/, @$argv_aref;
    $num_corr_cmd_opts += $num_corr_fnames;
    
    # Warn if "no" correct command-line options have been passed.
    if (not $num_corr_cmd_opts) {
        print "\n    | None of the command-line options was correct.\n";
        print $yn_msg;
        while ($yn = <STDIN>) {
            system "perldoc $the_prog" if $yn =~ /\by\b/i;
            exit if $yn =~ /\b[yn]\b/i;
            print $yn_msg;
        }
    }
    
    return;
}


sub show_elapsed_real_time {
    # """Show the elapsed real time."""
    
    my @opts = @_ if @_;
    
    # Parse optional arguments.
    my $is_return_copy = 0;
    my @del; # Garbage can
    foreach (@opts) {
        if (/copy/i) {
            $is_return_copy = 1;
            # Discard the 'copy' string to exclude it from
            # the optional strings that are to be printed.
            push @del, $_;
        }
    }
    my %dels = map { $_ => 1 } @del;
    @opts = grep !$dels{$_}, @opts;
    
    # Optional strings printing
    print for @opts;
    
    # Elapsed real time printing
    my $elapsed_real_time = sprintf("Elapsed real time: [%s s]", time - $^T);
    
    # Return values
    if ($is_return_copy) {
        return $elapsed_real_time;
    }
    else {
        say $elapsed_real_time;
        return;
    }
}


sub pause_shell {
    # """Pause the shell."""
    
    my $notif = $_[0] ? $_[0] : "Press enter to exit...";
    
    print $notif;
    while (<STDIN>) { last; }
    
    return;
}


sub construct_timestamps {
    # """Construct timestamps."""
    
    # Optional setting for the date component separator
    my $date_sep  = '';
    
    # Terminate the program if the argument passed
    # is not allowed to be a delimiter.
    my @delims = ('-', '_');
    if ($_[0]) {
        $date_sep = $_[0];
        my $is_correct_delim = grep $date_sep eq $_, @delims;
        croak "The date delimiter must be one of: [".join(', ', @delims)."]"
            unless $is_correct_delim;
    }
    
    # Construct and return a datetime hash.
    my $dt  = DateTime->now(time_zone => 'local');
    my $ymd = $dt->ymd($date_sep);
    my $hms = $dt->hms($date_sep ? ':' : '');
    (my $hm = $hms) =~ s/[0-9]{2}$//;
    
    my %datetimes = (
        none   => '', # Used for timestamp suppressing
        ymd    => $ymd,
        hms    => $hms,
        hm     => $hm,
        ymdhms => sprintf("%s%s%s", $ymd, ($date_sep ? ' ' : '_'), $hms),
        ymdhm  => sprintf("%s%s%s", $ymd, ($date_sep ? ' ' : '_'), $hm),
    );
    
    return %datetimes;
}


sub rm_duplicates {
    # """Remove duplicate items from an array."""
    
    my $aref = shift;
    my $sub_name = join('::', (caller(0))[0, 3]);
    croak "The 1st arg of [$sub_name] must be an array ref!"
        unless ref $aref eq ARRAY;
    
    my(%seen, @uniqued);
    @uniqued = grep !$seen{$_}++, @$aref;
    @$aref = @uniqued;
    
    return;
}
#-------------------------------------------------------------------------------


sub parse_argv {
    # """@ARGV parser"""
    
    my(
        $argv_aref,
        $cmd_opts_href,
        $run_opts_href,
    ) = @_;
    my %cmd_opts = %$cmd_opts_href; # For regexes
    
    # Parser: Overwrite default run options if requested by the user.
    my $field_sep    = ',';
    my $subfield_sep = '-';
    my $cwd = getcwd();
    foreach (@$argv_aref) {
        # Directories whose filenames will be renamed
        if (/$cmd_opts{dirs}/i) {
            if (/\ball\b/i and not -e 'all') {
                # For consistent parent dir expression
                foreach my $fname (glob ".* *") {
                    push @{$run_opts_href->{dirs}}, './'.$fname if -d $fname;
                }
                s/$cwd/./ for @{$run_opts_href->{dirs}};
            }
            else {
                s/$cmd_opts{dirs}//i;
                @{$run_opts_href->{dirs}} = split /$field_sep/;
            }
        }
        
        # Old-new string pairs
        if (/$cmd_opts{pairs}/i) {
            s/$cmd_opts{pairs}//i;
            %{$run_opts_href->{pairs}} = split /$subfield_sep/;
        }
        
        # Whitespace replacement
        if (/$cmd_opts{space_to}/i) {
            s/$cmd_opts{space_to}//i;
            unless ($_ eq '-' or $_ eq '_') {
                printf(
                    "[%s] is not allowed as a replacement of whitespace;".
                    " defaulting to [%s].\n\n",
                    $_,
                    $run_opts_href->{space_to},
                );
                next;
            }
            $run_opts_href->{space_to} = $_;
        }
        
        # Predefined routine toggles
        if (/$cmd_opts{turn_off}/i) {
            s/$cmd_opts{turn_off}//i;
            @{$run_opts_href->{turn_off}} = split /$field_sep/;
        }
        
        # The front matter won't be displayed at the beginning of the program.
        if (/$cmd_opts{nofm}/) {
            $run_opts_href->{is_nofm} = 1;
        }
        
        # The shell won't be paused at the end of the program.
        if (/$cmd_opts{nopause}/) {
            $run_opts_href->{is_nopause} = 1;
        }
    }
    rm_duplicates($run_opts_href->{dirs});
    
    return;
}


sub replace_whitespace {
    # """Replace whitespace with the hyphen or underscore."""
    
    my(
        $old,
        $olds_news_href,
        $space_to,
    ) = @_;
    
    # True: If the old filename had been renamed at least once,
    #       work continuously on that renamed filename.
    # False: If not, work on the not-yet-renamed old filename.
    my $new = exists $olds_news_href->{$old} ? $olds_news_href->{$old} : $old;
    
    $new =~ s/\s+/$space_to/g;
    
    return $olds_news_href->{$old} = $new;
}


sub remove_symbols {
    # """Remove symbols and duplicate periods (.) from filenames."""
    
    my(
        $old,
        $olds_news_href,
    ) = @_;
    my $new = exists $olds_news_href->{$old} ? $olds_news_href->{$old} : $old;
    
    # Remove characters other than [a-zA-Z0-9_\-.\f\t\n\r ].
    $new =~ s/[^\w\-.\s]+//ga;
    
    # Remove duplicate periods (.); but skip link files of Windows.
    if ($new =~ /[.]+.*[.]+/ and not $new =~ /lnk$/i) {
        (my $_bname = $new) =~ s/(.*)([.]\w+)$/$1/;
        (my $_ext   = $new) =~ s/(.*)([.]\w+)$/$2/;
        $_bname =~ s/[.]+//g;
        $new    = $_bname.$_ext;
    }
    
    return $olds_news_href->{$old} = $new;
}


sub yy_to_yyyy {
    # """Rename two-digit years to four-digit years."""
    
    my(
        $old,
        $olds_news_href,
    ) = @_;
    my $new = exists $olds_news_href->{$old} ? $olds_news_href->{$old} : $old;
    
    $new =~ s/
        (?<lead_delim>[\-_]?)
        (?<yymmdd>1[0-9]{5})
        (?<rear_delim>[\-_]?)
    /$+{lead_delim}20$+{yymmdd}$+{rear_delim}/x;
    
    return $olds_news_href->{$old} = $new;
}


sub uncap_ext {
    # """Lowercase file extensions."""
    
    my(
        $old,
        $olds_news_href,
    ) = @_;
    my $new = exists $olds_news_href->{$old} ? $olds_news_href->{$old} : $old;
    
    $new =~ s/[.]\K(?<ext>\w+)$/\L$+{ext}/;
    
    return $olds_news_href->{$old} = $new;
}


sub uncap_allcapped_substr {
    # """Lowercase all-uppercased filename substrings."""
    
    my(
        $old,
        $olds_news_href,
    ) = @_;
    my $new = exists $olds_news_href->{$old} ? $olds_news_href->{$old} : $old;
    
    $new =~ s/([A-Z]+)/\L$1/g;
    
    return $olds_news_href->{$old} = $new;
}


sub unix_case {
    # """Apply unix-like case."""
    
    my(
        $old,
        $olds_news_href,
        $space_to,
    ) = @_;
    my $new = exists $olds_news_href->{$old} ? $olds_news_href->{$old} : $old;
    
    # CamelCap --> Unix-like case
    # Author name
    $new =~ s/
        ^(?<fam_name>[a-zA-Z]+)
        (?<given_name>[A-Z]{1,2})
        (?<delim>[\-_])
    /\L$+{fam_name}$space_to/x;
    
    # All-capped followed by CamelCap
    $new =~
        s/
            (?<all_capped>[A-Z]+)
            (?<all_capped_last>[A-Z]{1})
            (?<lead_camel>[a-z]+)
        /\L$+{all_capped}$space_to$+{all_capped_last}$+{lead_camel}/gx;
    
    # Leading capped
    $new =~ s/^(?<lead>[A-Z]+)/\L$+{lead}/;
    
    # CamelCapped (an upper case followed by a lower case)
    $new =~ s/[a-z]+\K(?<bound>[A-Z]+)/$space_to\L$+{bound}/g;
    $new =~ s/(?<bound>[\-_][A-Z]+)/\L$+{bound}/g;
    $new =~ s/_+/_/;
    
    # An uppercase letter followed by a number
    $new =~ s/[0-9]+\K(?<bound>[A-Z]+)/$space_to\L$+{bound}/g;
    
    return $olds_news_href->{$old} = $new;
}


sub custom_strings {
    # """Rename filenames using custom string pairs."""
    
    my(
        $old,
        $olds_news_href,
        $user_pairs_href,
    ) = @_;
    my $new = exists $olds_news_href->{$old} ? $olds_news_href->{$old} : $old;
    
    # Overriding by user-specified string pairs
    while (my($k, $v) = each %$user_pairs_href) { $new =~ s/$k/$v/g }
    
    # Inconsistent cases
    $new =~ s/^JJ/jang/; # Case-sensitive, as I use jj
    $new =~ s/^JangJ/jang/;
    $new =~ s/PhD/phd/;
    $new =~ s/WiFi/wifi/;
    
    # Enumeration
    $new =~ s/^([0-9])-([0-9])/0$1-0$2/; # zero-padding
    $new =~ s/^([0-9]){1}[\-_]/0$1/;     # zero-padding
    
    # Languages
    $new =~ s/(?<delim>[\-_])?(?<lang>kor)/$+{delim}kr/i;
    $new =~ s/(?<delim>[\-_])?(?<lang>jpn)/$+{delim}jp/i;
    
    # Programs
    $new =~ s/LaTeX/latex/;
    $new =~ s/TeX/tex/;
    $new =~ s/(?<mc>(?:MCNP(X|[0-9])?|PHITS))/\L$+{mc}/;
    
    # Linac
    $new =~ s/linear_accel/linac/i;
    $new =~ s/(e|elec)[\-_](linac|gun)/e$2/i;
    $new =~ s/(x|s)-band/$1band/i;
    $new =~ s/(\bxlin\b)|(xband_linac)|(x_linac)/xlinac/i;
    $new =~ s/(\bslin\b)|(sband_linac)|(s_linac)/slinac/i;
    
    return $olds_news_href->{$old} = $new;
}


sub olds_news_preproc {
    # """Preprocess the pairs of old and new filenames."""
    
    my $olds_news_href = shift;
    my $olds_dupl_href = {};
    my $to_be_renamed_count = 0;
    
    # Create a conversion.
    my $lengthiest = '';
    foreach my $dir (keys %$olds_news_href) {
        my %olds_news = %{$olds_news_href->{$dir}};
        foreach my $old (keys %olds_news) {
            next if $old eq $olds_news{$old};
            my $old_full_path = $dir.'/'.$old;
            $lengthiest = $old_full_path
                if length($lengthiest) < length($old_full_path);
        }
    }
    my $conv = '%-'.length($lengthiest).'s';
    
    # Preprocessing
    foreach my $dir (sort keys %$olds_news_href) {
        # Directory-specific storages
        my %olds_news = %{$olds_news_href->{$dir}};
        $olds_dupl_href->{$dir} = [];
        
        # Find duplicate new filenames.
        my @vals     = values %olds_news;
        my(%seen_tmp, %seen);
        my @dupl_tmp = grep $seen_tmp{$_}++, @vals;
        my @dupl     = grep !$seen{$_}++,    @dupl_tmp;
        
        # Skip duplicate new filenames.
        foreach my $k (keys %olds_news) {
            foreach (@dupl) {
                if (exists $olds_news{$k} and $olds_news{$k} eq $_) {
                    push @{$olds_dupl_href->{$dir}}, $k;
                    delete $olds_news{$k};
                    %{$olds_news_href->{$dir}} = %olds_news;
                }
            }
        }
        
        # Display the old and new filenames.
        while (my($old, $new) = each %olds_news) {
            if ($old ne $new) {
                printf("$conv --> %s/%s\n", $dir.'/'.$old, $dir, $new);
                $to_be_renamed_count++;
            }
        }
    }
    
    return($olds_dupl_href, $to_be_renamed_count);
}


sub flush {
    # """Run renaming."""
    
    my(
        $olds_news_href,
        $to_be_renamed_count,
    ) = @_;
    
    my $cwd = getcwd();
    foreach my $dir (sort keys %$olds_news_href) {
        # Directory-specific storages
        my %olds_news = %{$olds_news_href->{$dir}};
        
        chdir $dir;
        while (my($old, $new) = each %olds_news) {
            rename($old, $new) if $old ne $new;
        }
        chdir $cwd;
    }
    
    # Reporting
    printf(
        "%s file%s been renamed.\n",
        $to_be_renamed_count,
        $to_be_renamed_count > 1 ? 's have' : ' has',
    );
    
    return;
}


sub run_fname_modifiers {
    # """Run filename modifiers."""
    
    my(
        $prog_info_href,
        $run_opts_href,
    ) = @_;
    my %_prog_info = %$prog_info_href; # For regexes
    
    # Rules predefined by the author of fnamer
    my %rules = (
        custom_strings => {
            cref     => \&custom_strings,
            add_args => $run_opts_href->{pairs},
            toggle   => 1,
        },
        replace_whitespace => {
            cref     => \&replace_whitespace,
            add_args => [$run_opts_href->{space_to}],
            regexes  => [qr/\s+/],
            toggle   => 1,
        },
        remove_symbols => {
            cref     => \&remove_symbols,
            add_args => [$run_opts_href->{space_to}],
            regexes  => [qr/[^\w\-.\s]/a, qr/[.]{2,}/],
            toggle   => 1,
        },
        yy_to_yyyy => {
            cref     => \&yy_to_yyyy,
            add_args => [],
            regexes  => [qr/^1[0-9]{5}[\-_]/, qr/[\-_]1[0-9]{5}[.\w]*$/],
            toggle   => 1,
        },
        uncap_ext => {
            cref     => \&uncap_ext,
            add_args => [],
            regexes  => [qr/[.A-Z]+$/],
            toggle   => 1,
        },
        uncap_allcapped_substr => {
            cref     => \&uncap_allcapped_substr,
            add_args => [],
            regexes  => [qr/[0-9\-_.]+[A-Z]+[0-9\-_.]+/],
            toggle   => 1,
        },
        unix_case => {
            cref     => \&unix_case,
            add_args => [$run_opts_href->{space_to}],
            regexes  => [qr/[a-z]+[A-Z]+/, qr/[A-Z]+[a-z]+/],
            toggle   => 1,
        },
    );
    foreach (@{$run_opts_href->{turn_off}}) {
        $rules{$_}{toggle} = 0 if exists $rules{$_};
    }
    
    # Buffer pairs of old and new filenames.
    my %olds_news;
    my $cwd = getcwd();
    foreach my $dir (@{$run_opts_href->{dirs}}) {
        # Directory-specific storage for old and new filenames
        $olds_news{$dir} = {};
        say "Directory [$dir] not found." if not -e $dir;
        chdir $dir if -e $dir;
        foreach my $old (glob ".* *") {
            # Skip the following:
            next if $old =~ /$_prog_info{titl}/; # This source code
            next if $old =~ /_?HDR|_?DSC|IMG_?/; # Photo files
            next if $old =~ /[.]run[.]/;         # LaTeX aux files
            
            # Performed ahead of other rules
            custom_strings(
                $old,
                $olds_news{$dir},
                $rules{custom_strings}{add_args},
            ) if $rules{custom_strings}{toggle};
            
            foreach my $rule (sort keys %rules) {
                next if not $rules{$rule}{toggle};
                
                if (grep { $old =~ $_ } @{$rules{$rule}{regexes}}) {
                    $rules{$rule}{cref}->(
                        $old,
                        $olds_news{$dir},
                        @{$rules{$rule}{add_args}}, # Additional arguments
                    );
                }
            }
        }
        chdir $cwd;
    }
    
    # Preprocess the pairs of old and new filenames.
    my (
        $olds_dupl_href,
        $to_be_renamed_count,
    ) = olds_news_preproc(\%olds_news);
    
    # If the buffered hashes contain defined key-val pairs,
    # ask whether to perform the renaming.
    my $is_first = 1;
    foreach my $dir (@{$run_opts_href->{dirs}}) {
        if (@{$olds_dupl_href->{$dir}}) {
            say '-' x 70 if $is_first;
            say "The following files will not be renamed".
                " as having duplicate new filenames:" if $is_first;
            say '-' x 70 if $is_first;
            say "$dir/$_" for @{$olds_dupl_href->{$dir}};
            $is_first = 0;
        }
    }
    
    if ($to_be_renamed_count == 0) {
        say '-' x 70;
        say "No filenames to be renamed.";
        say '-' x 70;
    }
    
    elsif ($to_be_renamed_count != 0) {
        say '-' x 70;
        say "* Warning: The renaming will be irrevocable! *";
        say '-' x 70;
        my $yn_message = sprintf(
            "Rename %s file%s above? [y/n]> ",
            $to_be_renamed_count,
            $to_be_renamed_count > 1 ? 's' : '',
        );
        print $yn_message;
        while (chomp(my $yn = <STDIN>)) {
            if ($yn =~ /\by\b/i) {
                flush(\%olds_news, $to_be_renamed_count);
                last;
            }
            elsif ($yn =~ /\bn\b/i) {
                last;
            }
            print $yn_message;
        }
    }
    
    return;
}


sub fnamer {
    # """fnamer main routine"""
    
    if (@ARGV) {
        my %prog_info = (
            titl       => basename($0, '.pl'),
            expl       =>
                "Rename multiple filenames according to your conventions",
            vers       => $VERSION,
            date_last  => $LAST,
            date_first => $FIRST,
            auth       => {
                name => 'Jaewoong Jang',
                posi => 'PhD student',
                affi => 'University of Tokyo',
                mail => 'jan9@korea.ac.kr',
            },
        );
        my %cmd_opts = ( # Command-line opts
            dirs     => qr/-?-dirs?\s*=\s*/i,
            pairs    => qr/-?-pairs?\s*=\s*/i,
            space_to => qr/-?-space(?:_to)?\s*=\s*/i,
            turn_off => qr/-?-(?:turn_)?off\s*=\s*/i,
            nofm     => qr/-?-nofm\b/,
            nopause  => qr/-?-nopause\b/i,
        );
        my %run_opts = ( # Program run opts
            dirs       => ['.'],
            pairs      => {},
            space_to   => '_',
            turn_off   => [],
            is_nofm    => 0,
            is_nopause => 0,
        );
        
        # Notification - beginning
        show_front_matter(\%prog_info, 'prog', 'auth')
            unless $run_opts{is_nofm};
        
        # ARGV validation and parsing
        validate_argv(\@ARGV, \%cmd_opts);
        parse_argv(\@ARGV, \%cmd_opts, \%run_opts);
        
        # Main
        run_fname_modifiers(\%prog_info, \%run_opts);
        
        # Notification - end
        show_elapsed_real_time();
        pause_shell()
            unless $run_opts{is_nopause};
    }
    
    system("perldoc \"$0\"") if not @ARGV;
    
    return;
}


fnamer();
__END__

=head1 NAME

fnamer - Rename multiple filenames according to your conventions

=head1 SYNOPSIS

    perl fnamer.pl [-dirs=dname ...] [-pairs=old-new ...] [-space_to=-|_]
                   [-turn_off=routine ...] [-nofm] [-nopause]

=head1 DESCRIPTION

    fnamer helps renaming multiple filenames according to user specifications.
    The user can:
    - turn off the predefined rules
    - specify old-new string pairs on the fly
    - hardcode new rules**
    ** Define a new routine and register its information to
       the run_fname_modifiers routine.

=head1 OPTIONS

    Multiple values are separated by the comma (,).

    -dirs=dname ... (default: current working directory)
        Directories whose files and subdirectories will be renamed.
        If 'all' is input and a subdirectory named 'all' does not exist in
        the current working directory, all the subdirectories will be examined.

    -pairs=old-new ...
        Pairs of the old and new strings of filenames. Use this option
        for specifying your conventions on the fly.
        For instance, the options -pairs=rpt-deck,figures-figs,Phase-phase
        will rename rpt to deck, figures to figs, and Phase to phase.
        If given, these pairs will take precedence over the predefined rules.

    -space_to=-|_ (short form: -space, default: _)
        Whitespace replacement.

    -turn_off=routine ... (short form: -off)
        You can turn off the predefined routines listed below.
            custom_strings
            replace_whitespace
            remove_symbols
            yy_to_yyyy
            uncap_ext
            uncap_allcapped_substr
            unix_case

    -nofm
        Do not show the front matter at the beginning of the program.

    -nopause
        Do not pause the shell at the end of the program.

=head1 EXAMPLES

    perl fnamer.pl -dirs=.,../wow -pairs=fig-figs -nopause
    perl fnamer.pl -turn_off=yy_to_yyyy,custom_strings
    perl fnamer.pl -dirs=all -nopause

=head1 REQUIREMENTS

Perl 5

=head1 CAVEATS

    - USE WITH CARE: renaming via this program is irreversible.
    - DO NOT work on filenames containing non-English letters; otherwise
      the filenames will be ruined FOREVER.
    - Multiple runs of this program with the same on-the-fly string pairs can
      lead to duplicate renaming. For instance, if you have a file called
      'fig.eps' and run the program with the option -pairs=fig-figs
      more than twice, the filename will eventually become 'figss.eps.'.

=head1 SEE ALSO

L<fnamer on GitHub|https://github.com/jangcom/fnamer>

=head1 AUTHOR

Jaewoong Jang <jan9@korea.ac.kr>

=head1 COPYRIGHT

Copyright (c) 2017-2019 Jaewoong Jang

=head1 LICENSE

This software is available under the MIT license;
the license information is found in 'LICENSE'.

=cut
