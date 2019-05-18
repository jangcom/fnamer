# fnamer

<?xml version="1.0" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link rev="made" href="mailto:" />
</head>

<body>



<ul id="index">
  <li><a href="#NAME">NAME</a></li>
  <li><a href="#SYNOPSIS">SYNOPSIS</a></li>
  <li><a href="#DESCRIPTION">DESCRIPTION</a></li>
  <li><a href="#OPTIONS">OPTIONS</a></li>
  <li><a href="#EXAMPLES">EXAMPLES</a></li>
  <li><a href="#REQUIREMENTS">REQUIREMENTS</a></li>
  <li><a href="#CAVEATS">CAVEATS</a></li>
  <li><a href="#SEE-ALSO">SEE ALSO</a></li>
  <li><a href="#AUTHOR">AUTHOR</a></li>
  <li><a href="#COPYRIGHT">COPYRIGHT</a></li>
  <li><a href="#LICENSE">LICENSE</a></li>
</ul>

<h1 id="NAME">NAME</h1>

<p>fnamer - Rename multiple filenames according to your conventions</p>

<h1 id="SYNOPSIS">SYNOPSIS</h1>

<pre><code>    perl fnamer.pl [-dirs=dname ...] [-pairs=old-new ...] [-space_to=-|_]
                   [-turn_off=routine ...] [-nofm] [-nopause]</code></pre>

<h1 id="DESCRIPTION">DESCRIPTION</h1>

<pre><code>    fnamer helps renaming multiple filenames according to user specifications.
    The user can:
    - turn off the predefined rules
    - specify old-new string pairs on the fly
    - hardcode new rules**
    ** Define a new routine and register its information to
       the run_fname_modifiers routine.</code></pre>

<h1 id="OPTIONS">OPTIONS</h1>

<pre><code>    Multiple values are separated by the comma (,).

    -dirs=dname ... (default: current working directory)
        Directories whose files and subdirectories will be renamed.
        If &#39;all&#39; is input and a subdirectory named &#39;all&#39; does not exist in
        the current working directory, all the subdirectories will be examined.

    -pairs=old-new ...
        Pairs of the old and new strings of filenames. Use this option
        for specifying your conventions on the fly.
        For instance, the options -pairs=rpt-deck,Phase-phase,_test-
        will rename rpt to deck and figures to figs, and remove _test.
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
        Do not pause the shell at the end of the program.</code></pre>

<h1 id="EXAMPLES">EXAMPLES</h1>

<pre><code>    perl fnamer.pl -dirs=.,../wow -pairs=fig-figs -nopause
    perl fnamer.pl -turn_off=yy_to_yyyy,custom_strings
    perl fnamer.pl -dirs=all -nopause
    perl fnamer.pl -pairs=_new-</code></pre>

<h1 id="REQUIREMENTS">REQUIREMENTS</h1>

<p>Perl 5</p>

<h1 id="CAVEATS">CAVEATS</h1>

<pre><code>    - USE WITH CARE: renaming via this program is irreversible.
    - DO NOT work on filenames containing non-English letters; otherwise
      the filenames will be ruined FOREVER.
    - Multiple runs of this program with the same on-the-fly string pairs can
      lead to duplicate renaming. For instance, if you have a file called
      &#39;fig.eps&#39; and run the program with the option -pairs=fig-figs
      more than twice, the filename will eventually become &#39;figss.eps&#39;.</code></pre>

<h1 id="SEE-ALSO">SEE ALSO</h1>

<p><a href="https://github.com/jangcom/fnamer">fnamer on GitHub</a></p>

<h1 id="AUTHOR">AUTHOR</h1>

<p>Jaewoong Jang &lt;jangj@korea.ac.kr&gt;</p>

<h1 id="COPYRIGHT">COPYRIGHT</h1>

<p>Copyright (c) 2017-2019 Jaewoong Jang</p>

<h1 id="LICENSE">LICENSE</h1>

<p>This software is available under the MIT license; the license information is found in &#39;LICENSE&#39;.</p>


</body>

</html>
