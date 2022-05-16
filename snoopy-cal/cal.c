#include<stdio.h>
#include<time.h>
#include<assert.h>

#include "picdat.inc"
#include "extdat.inc"


/* draw an RLE-encoded picture from picdat.inc */
#define LLEN 133
static void
draw_rle_pic (const char *restrict pic)
{
  signed char count, chr;
  int len = 0;
  while (count = *pic++, chr = *pic++, count != -2)
    {
      len += count;
      if (count == -1)
        count = LLEN - len, len = 0;
      while (count--)
        putchar (chr);
      if (!len)
        putchar ('\n');
    }
  putchar ('\n');
}

/* draw one row of a digit, or blanks if the digit is -1 */
static void
draw_digit_fragment (int digit, int row)
{
  const static char blanks[6] = "      ";
  assert (row >= 0 && row < 5);
  assert (digit >= -1 && digit < 10);

  size_t len = 6;
  const char *ch = (digit >= 0) ? numerals[row] + (digit * len) : blanks;
  while (len--)
    putchar (*ch++);
}

/* banners have the month-name from extdat.inc, and the digits of the
 * year written on either side
 */
static void
draw_month_banner (int year, int month_idx)
{
  assert (year >= 0 && year <= 9999);
  assert (month_idx >= 0 && month_idx < 12);

  int digit_4 = year % 10;
  year /= 10;
  int digit_3 = year % 10;
  year /= 10;
  int digit_2 = year % 10;
  year /= 10;
  int digit_1 = year % 10;
  year /= 10;

  month_idx *= 7;
  /* We'll define some shorthand here to make the layout easier */
#define BL(n) printf("%" #n "c", ' ');
#define NL putchar('\n')
#define DIGIT(d,l) draw_digit_fragment(digit_ ## d, l);
#define MONTH    BL(12) fputs(months[month_idx++], stdout); BL(19)
  BL (12) MONTH NL;
  BL (6) DIGIT (2, 0) MONTH DIGIT (3, 0) NL;
  BL (6) DIGIT (2, 1) MONTH DIGIT (3, 1) NL;
  DIGIT (1, 0) DIGIT (2, 2) MONTH DIGIT (3, 2) DIGIT (4, 0) NL;
  DIGIT (1, 1) DIGIT (2, 3) MONTH DIGIT (3, 3) DIGIT (4, 1) NL;
  DIGIT (1, 2) DIGIT (2, 4) MONTH DIGIT (3, 4) DIGIT (4, 2) NL;
  DIGIT (1, 3) BL (6) MONTH BL (6) DIGIT (4, 3) NL;
  DIGIT (1, 4) BL (121) DIGIT (4, 4) NL;
}
#undef BL
#undef NL
#undef DIGIT
#undef MONTH

/* draw a grid of days for a month month with `tot_days` days, 
 * that starts on day `idx`
 */
static void
draw_day_grid (int tot_days, int idx)
{
  /* define some constants and macros to make formatting easier */
  static const char bar_txt[] = "   I ";
  static const char blank_bars[] =
    "                     I                 I                 I                 I                 I                 I                    ";
  static const char divider_bars[] =
    " --------------------I-----------------I-----------------I-----------------I-----------------I-----------------I--------------------";
#define BAR fputs(bar_txt,stdout);
#define SPC putchar(' ');
#define DIGIT(col) draw_digit_fragment(digits[col], row);

  assert (tot_days >= 28 && tot_days <= 31);
  assert (idx >= 0 && idx <= 6);

  static const char blank[1] = "";
  putchar ('\n');
  puts (weekdays);
  putchar ('\n');

  idx = -idx + 1;
  signed char digits[14];
  while (idx <= tot_days)
    {
      /* fill out digits[] with a row of 14 potential digits to draw */
      for (int column = 0; column < 7; ++column, ++idx)
        if (idx <= 0 || idx > tot_days)
            digits[column * 2] = digits[column * 2 + 1] = -1;
        else if (idx < 10)
            digits[column * 2] = -1, digits[column * 2 + 1] = (char) idx;
        else
            digits[column * 2] = (char) (idx / 10), digits[column * 2 + 1] = (char) (idx % 10);

      /* if this isn't the first line, draw the dividers */
      if (idx > 8) puts (divider_bars);

      /* draw the digits */
      puts (blank_bars);
      for (int row = 0; row < 5; ++row)
        {
          fputs ("     ", stdout);
          DIGIT (0)  SPC DIGIT (1)  BAR
          DIGIT (2)  SPC DIGIT (3)  BAR
          DIGIT (4)  SPC DIGIT (5)  BAR
          DIGIT (6)  SPC DIGIT (7)  BAR
          DIGIT (8)  SPC DIGIT (9)  BAR
          DIGIT (10) SPC DIGIT (11) BAR
          DIGIT (12) SPC DIGIT (13) putchar ('\n');
        }
      puts (blank_bars);
    }
}
#undef BAR
#undef SPC
#undef DIGIT

int
main (int argc, char *argv[])
{
  time_t today = time (NULL);
  struct tm selected = *localtime (&today);
  selected.tm_mday = 1;         /* we only care about the 1st of the month */

  /* handle cmdline args to reset the month or month+year */
  if (argc > 1)
    if (sscanf (argv[1], "%d", &selected.tm_mon))
      --selected.tm_mon;
    else
      goto usage;

  if (argc > 2)
    if (sscanf (argv[2], "%d", &selected.tm_year))
      selected.tm_year -= 1900;
    else
      goto usage;

  /* now validate the configuration further */
  if (selected.tm_mon < 0 || selected.tm_mon > 12 || selected.tm_year > 9999
      || selected.tm_year < 0 || (selected.tm_mon == 12
                                  && selected.tm_year == 9999) || argc > 3)
    {
    usage:
      fprintf (stderr, "Usage: %s [month] [year]\n",
               argc > 0 ? argv[0] : "snoopy-cal");
      fprintf (stderr,
               "  month can be 1 to 13 (13 is Jan of following year)\n");
      fprintf (stderr, "  year can be 0 to 9999\n");
      return -1;
    }

  /* draw the picture for the chosen month */
  draw_rle_pic (pics[selected.tm_mon]);

  /* Now draw the calendar.  mktime() takes care of wrap-around to the following
   * year if the user selected month '13'.
   */
  mktime (&selected);
  draw_month_banner (selected.tm_year + 1900, selected.tm_mon);
  /* account for leap-years */
  int leap_day = selected.tm_mon == 1 && !(selected.tm_year % 4)
    && selected.tm_year % 100;
  draw_day_grid (days_in_month[selected.tm_mon] + leap_day, selected.tm_wday);
  return 0;
}
