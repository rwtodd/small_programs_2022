#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#define err_exit(msg) { fprintf(stderr,"line %d: %s\n",lineno,msg); return EXIT_FAILURE; }

int
main(int argc, char **argv)
{
  /* we need a buffer for the line of input */
  char *line_buf = NULL; size_t line_bufsz = 0, line_len = 0;
  int lineno = 0; /*track the line number */

  /* we need a buffer for the page label text */
  size_t labelssz = 512, labels_len = 0;
  char *labels = malloc(labelssz);

  /* we need to track the offset between the book pages and the pdf pages */
  int poffs = 0;  

  /* keep reading until we run out of data */
  while((line_len = getline(&line_buf, &line_bufsz,stdin)) != -1) {
    int index = -1, indent = -1, pageno = -1;
    int pdfpg, bookpg;
    char ptype;

    ++lineno;

    /* remove the trailing \n or \r\n */
    if(line_len > 1 && line_buf[line_len - 2] == '\r') line_buf[line_len - 2] = '\0';
    else if(line_len > 0 && line_buf[line_len-1] == '\n') line_buf[line_len - 1] = '\0';

    /* check for book numbering commands: page x = book y, (technically GaP x = BoB y would work too!) */
    if(sscanf(line_buf,"%*[PpAaGgEe] %d = %*[BbOoKk] %d%n",&pdfpg,&bookpg,&index) == 2) {
       char * style;
       /* check for roman numerals */
       switch(line_buf[index]) {
         case 'r': 
           style="LowercaseRomanNumerals"; break;
         case 'R':
           style="UppercaseRomanNumerals"; break;
         default:
           style="DecimalArabicNumerals"; break;
       }

       /* make sure there's room for more labels */
       if(labels_len > labelssz - 100) {
          labelssz *= 2;
          if(!(labels = realloc(labels, labelssz)))
            err_exit("could not allocate memory for labels!");
       }

       poffs = pdfpg - bookpg;
       int len = sprintf(labels + labels_len,
          "PageLabelBegin\nPageLabelNewIndex: %d\nPageLabelStart: %d\nPageLabelNumStyle: %s\n",
          pdfpg, bookpg, style);
       if(len < 0) err_exit("error formatting page labels!");
       labels_len += len;
    }

    /* check for a new named page (sets offset back to 0): name 21: <the name> */
    else if(sscanf(line_buf,"%*[NnAaMmEe] %d: %n",&pdfpg,&index) == 1) {
       poffs = 0;

       /* make sure there's room for more labels */
       if(labels_len > labelssz - 100) {
          labelssz *= 2;
          if(!(labels = realloc(labels, labelssz)))
            err_exit("could not allocate memory for labels!");
       }

       int len = sprintf(labels + labels_len, 
          "PageLabelBegin\nPageLabelNewIndex: %d\nPageLabelStart: 1\nPageLabelPrefix: %s\nPageLabelNumStyle: NoNumber\n",
          pdfpg, line_buf + index);
       if(len < 0) err_exit("error formatting page labels!");
       labels_len += len;
    }

    /* check for a bookmark */
    else if(sscanf(line_buf," %n%d%c %n",&indent,&pageno,&ptype,&index) == 2) {
      switch(ptype) {
         case 'p':
         case 'P': break;
         case ' ': pageno += poffs; break;
         default: err_exit("bad input, looks like page suffix!");
      }
      printf("BookmarkBegin\nBookmarkTitle: %s\nBookmarkLevel: %d\nBookmarkPageNumber: %d\n",
          line_buf+index, indent+1, pageno);
    }

    /* it should be blank or a #-comment otherwise */
    else {
      const char *cur = line_buf;
      while(*cur == ' ') ++cur;
      if(*cur != '#' && *cur != '\0') err_exit("bad input!");
    }
  }

  /* write the saved page labels so they appear in a block at the end */
  puts(labels);
  return EXIT_SUCCESS;
}
