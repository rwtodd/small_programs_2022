/* http://gunkies.org/wiki/Snoopy_Calendar#snpcal.dat */
#include<stdio.h>
#include<assert.h>

#include "picdata.inc"
#include "worddata.inc"

#define LLEN 133

static void 
draw_digit_fragment(int digit, int line)
{
  assert (line >= 0 && line < 7);
  assert (digit >= 0 && digit < 10);

  size_t len = 6;
  const char *restrict ch = numerals[line] + (digit * len); 
  while(len--) putchar(*ch++);
}

static void
draw_month_banner(int year, int month_idx)
{
  assert (year >= 0 && year <= 9999);
  assert (month_idx >= 0 && month_idx < 12);

  int digit_4 = year % 10; year /= 10;
  int digit_3 = year % 10; year /= 10;
  int digit_2 = year % 10; year /= 10;
  int digit_1 = year % 10; year /= 10;

  month_idx *= 7;
  /* We'll define some shorthand here to make the layout easier */
  #define BL(n) printf("%" #n "c", ' ');
  #define NL putchar('\n')
  #define DIGIT(d,l) draw_digit_fragment(digit_ ## d, l);
  #define MONTH    BL(12) printf("%s",months[month_idx++]); BL(19)
  BL(12)                MONTH    NL;
  BL(6)      DIGIT(2,0) MONTH    DIGIT(3,0) NL;
  BL(6)      DIGIT(2,1) MONTH    DIGIT(3,1) NL;
  DIGIT(1,0) DIGIT(2,2) MONTH    DIGIT(3,2) DIGIT(4,0) NL;
  DIGIT(1,1) DIGIT(2,3) MONTH    DIGIT(3,3) DIGIT(4,1) NL;
  DIGIT(1,2) DIGIT(2,4) MONTH    DIGIT(3,4) DIGIT(4,2) NL;
  DIGIT(1,3) BL(6)      MONTH    BL(6)      DIGIT(4,3) NL;
  DIGIT(1,4) BL(121)                        DIGIT(4,4) NL;
  #undef BL
  #undef NL 
  #undef DIGIT
  #undef MONTH
}


int 
main(int argc, char *argv[])
{
  int year = 1969;
  int month_idx = 1;

  if(argc > 1) sscanf(argv[1],"%d",&year);
  if(argc > 2) sscanf(argv[2],"%d",&month_idx);
  --month_idx;
  if (month_idx < 0 || month_idx > 12 || year > 9999 || year < 0 ||
		  (month_idx == 12 && year == 9999))
    {
      fprintf(stderr,"Usage: %s year month\n", argc > 0 ? argv[0] : "snoopy-cal");
      fprintf(stderr,"  year can be 0 to 9999\n");
      fprintf(stderr,"  month can be 1 to 13 (13 is Jan of following year)\n");
      return -1;
    }

  /* draw the picture for the chosen month */
  const char *cur = pics[month_idx];
  signed char count, chr;
  int len = 0;
  while(count = *cur++, chr = *cur++, count != -2) {
    len += count;
    if(count == -1) count = LLEN - len, len = 0;
    while(count--) putchar(chr);
    if(!len) putchar('\n');
  }
  putchar('\n');

  /* Now draw the calendar.  If the month_idx was 12, we actually want
   * January of the following year.  So fix that up first.
   */
  if (month_idx == 12) month_idx = 0, ++year;
  draw_month_banner(year, month_idx);
  return 0;
}
