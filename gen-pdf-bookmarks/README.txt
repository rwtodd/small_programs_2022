A helper program to generate pdf bookmark and page label data
for use by pdftk-java.

Because it's a simple C program, the format is pretty rigid,
but for whatever reason I didn't feel like using perl/python today.

The following commands are accepted (1 per line):

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1) Name a page with text:  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NAME 1: Cover
NAME 210: BackCover

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2) Number pages to match the book (decimal numbers): ~~~~~~~~~~~~~

PAGE 2 = BOOK 1  
PAGE 40 = BOOK 52  and BTW this text will be ignored


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
3) Number pages to match the book (roman numerals): ~~~~~~~~~~~~~~

PAGE 2 = BOOK 1r

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
4) Add a bookmark (the page number is the BOOK page according to
the most-recent 'PAGE' command) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4 Contents
6 Preface
8 Chapter One
 10 Subheading 1
 12 Subheading 2
14 Chapter Two
 15 Indenting makes nested bookmarks like you might expect
 21 So these two items are "under" Chapter Two in most PDF readers
  22 So this is a third-level of nesting
  24 Only indent by 1 space at a time... it's a rigid simple C program
28 Chapter Three

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
5) Blank lines, or lines with # followed by comment text are allowed

# this is a comment
    # so is this

