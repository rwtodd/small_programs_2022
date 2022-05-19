#!/usr/bin/perl
#  Change unicode quotes to TeX quotes, and also try to do simple ".." to ``..'' conversion.
#
use v5.30;
use open qw(:std :utf8);

while (<>) {
  tr/\x{2018}\x{2019}/`'/;
  s/ *\x{2013} */---/g;
  s/\x{2026}/\\ldots/g;
  s/\x{201c}/``/g;
  s/\x{201d}/''/g;
  s/"([^"]*)"/``$1''/g;
  print; 
}
