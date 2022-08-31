/* read from stdin and output to stdout.
 * expect a djvused (bookmark ... ) stream
 * as input
 */

#include<stdio.h>
#include<string.h>

#define err_exit(msg) {fputs(msg "\n",stderr); return 1;}
int
main(int argc, char **argv)
{
  /* we start with canned text */
  if(scanf(" (bookmarks") < 0) err_exit("bad input, so bad we couldn't get started!");

  /* ok now life is just a series of 
   *   (name location (subname subloc) (subname subloc)) 
   * structures */
  int paren_depth = 1;  /* 1 because we have "(bookmarks" already open */
  char buf[256];        /* fixed-sized unsafe buffer, but good enough for a program like this one */
  int bpage;        
  while(paren_depth) {
    if(2 != scanf(" ( \"%[^\"]\" \"#%d\" ", buf, &bpage)) {
      err_exit("bad input, or out of input too early!");
    }
    /* print out this entry */
    printf("BookmarkBegin\nBookmarkTitle: %s\nBookmarkLevel: %d\nBookmarkPageNumber: %d\n",
        buf, paren_depth, bpage);
    ++paren_depth; /* we haven't looked for closing parens yet */
    while(1 == scanf(" %[)]",buf)) paren_depth -= strlen(buf);  /* account for closing parens */
    if(paren_depth < 0) err_exit("bad format: too many closing parens!");
  }
  return 0;
}
