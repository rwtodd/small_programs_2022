#include<stdio.h>
#include<string.h>

#define err_exit(msg) { fputs(msg "\n",stderr); return 1; }
int
main(int argc, char **argv)
{
  char buf[256];  /* good enough for this toy program */

  /* we need to store labels text and output it at the end... so ... */
  char labels[1024];
  labels[0] = '\0';
  size_t label_sz = 0;

  int poffs = 0;  /* the current page offset */

  /* keep reading until we run out of data */
  while(1) {
    int indent = -1,pageno = -1;
    int pdfpg, bookpg;

    /* check for book numbering commands */
    if(scanf("PAGE %d = BOOK %d",&pdfpg,&bookpg) == 2) {
       /* check for roman numerals */
       char * style = (scanf("%[rR]",buf) == 1) ? "LowercaseRomanNumerals" : "DecimalArabicNumerals";

       /* eat the rest of the line the CR/LF */
       if( scanf("%*[^\r\n]") < 0 || scanf("%*[\r\n]") < 0) 
         err_exit("error on PAGE=BOOK line???");
       poffs = pdfpg - bookpg;
       int len = sprintf(labels + label_sz, 
          "PageLabelBegin\nPageLabelNewIndex: %d\nPageLabelStart: %d\nPageLabelNumStyle: %s\n",
          pdfpg, bookpg, style);
       if(len < 0) err_exit("error formatting page labels!");
       label_sz += len;
    }

    /* check for a new named page (sets offset back to 0) */
    else if(scanf("NAME %d: %[^\r\n]%*[\r\n]",&pdfpg,buf) == 2) {
       poffs = 0;
       int len = sprintf(labels + label_sz, 
          "PageLabelBegin\nPageLabelNewIndex: %d\nPageLabelStart: 1\nPageLabelPrefix: %s\nPageLabelNumStyle: NoNumber\n",
          pdfpg, buf);
       if(len < 0) err_exit("error formatting page labels!");
       label_sz += len;
       continue;
    }

    /* if we got here we better have a bookmark */
    else {
      int result = scanf(" %n%d %[^\r\n]%*[\r\n]",&indent,&pageno,buf);
      if(result != 2)
        if(indent > 0 || pageno != -1) { err_exit("bad input!"); }
        else break;  
      printf("BookmarkBegin\nBookmarkTitle: %s\nBookmarkLevel: %d\nBookmarkPageNumber: %d\n",
          buf, indent+1, pageno+poffs);
    }
  }

  /* write the saved page labels so they appear in a block at the end */
  puts(labels);
}
