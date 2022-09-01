#include<stdio.h>
#include<string.h>

#define err_exit(msg) { fputs(msg "\n",stderr); return 1; }
int
main(int argc, char **argv)
{
  char buf[256];  /* good enough for this toy program */
  /* first read the offset for pages */
  int poffs = 0;
  if(scanf("OFFSET %d%*[\n]",&poffs) < 0) err_exit("problem reading the first line!");

  /* now read all the chapters */
  while(1) {
    int indent = -1,pageno = -1;
    int result = scanf(" %n%d %[^\n]%*c",&indent,&pageno,buf);
    if(result != 2)
      if(indent > 0 || pageno != -1) { err_exit("bad input!"); }
      else break;  
    printf("BookmarkBegin\nBookmarkTitle: %s\nBookmarkLevel: %d\nBookmarkPageNumber: %d\n",
        buf, indent+1, pageno+poffs);
  }
}
