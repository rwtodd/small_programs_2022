This is a little program to convert djvused bookmarks to pdftk-java bookmarks
so that I can easily move bookmarks from DjVu files to equivalent PDFs.  The page order must be the
same for the DjVu and PDF, and it should work.

example:
  djvused -e print-outline input.djvu | d2p > out.bmarks


P.S. yes fixed-length buffers are not good for unsafe environments but this is
just code I'm using on my own data for a specific one-time purpose.  so... 

