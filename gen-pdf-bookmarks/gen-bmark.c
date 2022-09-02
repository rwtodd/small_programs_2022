#include<stdio.h>
#include<string.h>

#define err_exit(msg) { fputs(msg "\n",stderr); return 1; }
int
main(int argc, char **argv)
{
  char buf[256];  /* good enough for this toy program */
  int poffs = 0;  /* the current page offset */

  /* now read all the chapters */
  while(1) {
    int indent = -1,pageno = -1;
    /* always check for a new poffs offset ... */
    int pdfpg, bookpg;
    if(scanf("PAGE %d = BOOK %d",&pdfpg,&bookpg) == 2) {
       /* eat the rest of the line the CR/LF */
       if( scanf("%*[^\r\n]") < 0 || scanf("%*[\r\n]") < 0) 
         err_exit("error on PAGE=BOOK line???");
       poffs = pdfpg - bookpg;
    }

    /* ... and then read the next contents entry */
    int result = scanf(" %n%d %[^\r\n]%*[\r\n]",&indent,&pageno,buf);
    if(result != 2)
      if(indent > 0 || pageno != -1) { err_exit("bad input!"); }
      else break;  
    printf("BookmarkBegin\nBookmarkTitle: %s\nBookmarkLevel: %d\nBookmarkPageNumber: %d\n",
        buf, indent+1, pageno+poffs);
  }
}
