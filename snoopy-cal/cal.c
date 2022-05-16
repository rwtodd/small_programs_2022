/* http://gunkies.org/wiki/Snoopy_Calendar#snpcal.dat */
#include<stdio.h>
#include<time.h>
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

/* draw a month with `tot_days` days, that starts on day `idx` */
void
draw_day_grid(int tot_days, int idx)
{
   assert(tot_days >= 28 && tot_days <= 31);
   assert(idx >= 0 && idx <= 6);

   static const char blank[1] = "";
   putchar('\n'); puts(weekdays); putchar('\n');

   idx = -idx + 1;
   signed char digits[14];
   while(idx <= tot_days)
     {
        /* fill out digits[] with a row of 14 potential digits to draw */
        for(int column = 0; column < 7; ++column, ++idx)
          {
            if(idx <= 0 || idx > tot_days) { digits[column*2] = -1; digits[column*2+1] = -1; }
            else if(idx < 10) { digits[column*2] = -1; digits[column*2+1] = (char)idx; }
            else { digits[column*2] = (char)(idx/10); digits[column*2+1] = (char)(idx%10); }
          }
         
#define BAR printf("   I ")
#define SPC putchar(' ') 
#define DIGIT(col) if (digits[col] == -1) printf("      "); else draw_digit_fragment(digits[col], row); 
	/* if this isn't the first line, draw the dividers */
	if (idx > 8)
	{
          puts(" --------------------I-----------------I-----------------I-----------------I-----------------I-----------------I--------------------");
	}
        /* draw the digits */
        puts("                     I                 I                 I                 I                 I                 I                    ");
        for(int row = 0; row < 5; ++row)
          {
	     printf("     ");
             DIGIT(0); SPC; DIGIT(1); BAR; 
             DIGIT(2); SPC; DIGIT(3); BAR; 
             DIGIT(4); SPC; DIGIT(5); BAR; 
             DIGIT(6); SPC; DIGIT(7); BAR; 
             DIGIT(8); SPC; DIGIT(9); BAR; 
             DIGIT(10); SPC; DIGIT(11); BAR; 
             DIGIT(12); SPC; DIGIT(13); putchar('\n'); 
          }
        puts("                     I                 I                 I                 I                 I                 I                    ");
     }
}

/*
         SUNDAY            MONDAY            TUESDAY          WEDNESDAY         THURSDAY           FRIDAY           SATURDAY        
                                                                                                                                    
                     I                 I                 I                 I                 I                 I                    
                     I                 I                 I                 I                 I           1     I          222       
                     I                 I                 I                 I                 I          11     I         2   2      
                     I                 I                 I                 I                 I           1     I            2       
                     I                 I                 I                 I                 I           1     I          2         
                     I                 I                 I                 I                 I         11111   I         22222      
                     I                 I                 I                 I                 I                 I                    
 --------------------I-----------------I-----------------I-----------------I-----------------I-----------------I--------------------
                     I                 I                 I                 I                 I                 I                    
             33333   I            4    I         55555   I          666    I         77777   I          888    I          999       
                 3   I           44    I         5       I         6       I             7   I         8   8   I         9   9      
               33    I          4 4    I         5555    I         6666    I            7    I          888    I          9999      
             3   3   I         44444   I             5   I         6   6   I           7     I         8   8   I             9      
              333    I            4    I         5555    I          666    I           7     I          888    I          999       
                     I                 I                 I                 I                 I                 I                    
 --------------------I-----------------I-----------------I-----------------I-----------------I-----------------I--------------------
                     I                 I                 I                 I                 I                 I                    
        1     000    I    1      1     I    1     222    I    1    33333   I    1       4    I    1    55555   I    1     666       
       11    0   0   I   11     11     I   11    2   2   I   11        3   I   11      44    I   11    5       I   11    6          
        1    0   0   I    1      1     I    1       2    I    1      33    I    1     4 4    I    1    5555    I    1    6666       
        1    0   0   I    1      1     I    1     2      I    1    3   3   I    1    44444   I    1        5   I    1    6   6      
      11111   000    I  11111  11111   I  11111  22222   I  11111   333    I  11111     4    I  11111  5555    I  11111   666       
                     I                 I                 I                 I                 I                 I                    
 --------------------I-----------------I-----------------I-----------------I-----------------I-----------------I--------------------
                     I
*/

int 
main(int argc, char *argv[])
{
  int year = 1969;
  int month_idx = 1;

  /* First, handle command-line args and validate */
  if(argc > 1) sscanf(argv[1],"%d",&month_idx); 
  if(argc > 2) sscanf(argv[2],"%d",&year);

  --month_idx;
  if (month_idx < 0 || month_idx > 12 || year > 9999 || year < 0 ||
		  (month_idx == 12 && year == 9999) || argc > 3)
    {
      fprintf(stderr,"Usage: %s [month] [year]\n", argc > 0 ? argv[0] : "snoopy-cal");
      fprintf(stderr,"  month can be 1 to 13 (13 is Jan of following year)\n");
      fprintf(stderr,"  year can be 0 to 9999\n");
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
  draw_day_grid(31,6);
  return 0;
}
