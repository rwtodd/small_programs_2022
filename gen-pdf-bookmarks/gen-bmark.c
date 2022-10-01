#include<stdio.h>
#include<stdlib.h>
#include<string.h>

void err_exit(int lineno, const char *const msg) __attribute__ ((noreturn));
#define eexit(msg) err_exit(lineno, msg)

int
main(int argc, char **argv)
{
  int lineno = 0; /*track the line number */

  /* we need a buffer for the line of input */
  char *line_buf = NULL; size_t line_bufsz = 0, line_len = 0;

  /* we need a buffer for the page label text */
  FILE *labels; size_t labels_sz; char *labels_buf;
  if ((labels = open_memstream(&labels_buf, &labels_sz)) == NULL)
    eexit("Could not open labels buffer!");

  /* we need to track the offset between the book pages and the pdf pages */
  int poffs = 0;  

  /* keep reading until we run out of data */
  while((line_len = getline(&line_buf, &line_bufsz,stdin)) != -1) {
    /* scratch variables for parsing commands */
    int index = -1, indent = -1, pageno = -1;
    int pdfpg, bookpg;
    char ptype;

    ++lineno;

    /* remove the trailing newline */
    if(line_len > 1 && line_buf[line_len - 2] == '\r') line_buf[line_len - 2] = '\0';
    else if(line_len > 0 && line_buf[line_len-1] == '\n') line_buf[line_len - 1] = '\0';

    /* check for book numbering commands: page x = book y, (technically GaP x = BoB y would work too!) */
    if(sscanf(line_buf,"%*[PpAaGgEe] %d = %*[BbOoKk] %d%n",&pdfpg,&bookpg,&index) == 2) {
       char * style;
       switch(line_buf[index]) {
         case 'r': 
           style="LowercaseRomanNumerals"; break;
         case 'R':
           style="UppercaseRomanNumerals"; break;
         default:
           style="DecimalArabicNumerals"; break;
       }
       poffs = pdfpg - bookpg;
       if(fprintf(labels,
               "PageLabelBegin\nPageLabelNewIndex: %d\nPageLabelStart: %d\nPageLabelNumStyle: %s\n",
               pdfpg, bookpg, style) < 0) eexit("Error writing labels!");
    }

    /* check for a new named page (sets offset back to 0): name 21: <the name> */
    else if(sscanf(line_buf,"%*[NnAaMmEe] %d: %n",&pdfpg,&index) == 1) {
       poffs = 0;
       if(fprintf(labels,
                 "PageLabelBegin\nPageLabelNewIndex: %d\nPageLabelStart: 1\nPageLabelPrefix: %s\n"
		 "PageLabelNumStyle: NoNumber\n",
                  pdfpg, line_buf + index) < 0) eexit("Error writing labels!");
    }

    /* check for a bookmark */
    else if(sscanf(line_buf," %n%d%c %n",&indent,&pageno,&ptype,&index) == 2) {
      switch(ptype) {
         case 'p':
         case 'P': break;
         case ' ': pageno += poffs; break;
         default: eexit("bad input, looks like page suffix!");
      }
      printf("BookmarkBegin\nBookmarkTitle: %s\nBookmarkLevel: %d\nBookmarkPageNumber: %d\n",
          line_buf+index, indent+1, pageno);
    }

    /* if we got here, we should have a blank line or a #-comment */
    else {
      const char *cur = line_buf;
      while(*cur == ' ') ++cur;
      if(*cur != '#' && *cur != '\0') eexit("bad input!");
    }
  }

  /* write the saved page labels so they appear in a block at the end */
  fclose(labels);
  puts(labels_buf);
  return EXIT_SUCCESS; /* don't bother free()-ing labels_buf... we are exiting the program */
}

void err_exit(int lineno, const char *const msg) {
  fprintf(stderr, "line %d: %s\n",lineno,msg);
  exit(EXIT_FAILURE);
}
