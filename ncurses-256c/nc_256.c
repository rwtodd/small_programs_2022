#include<stdlib.h>
#include<stdio.h>
#include<ncurses.h>

static void
kill_program(const char *msg)
{
  endwin();
  fputs(msg,stderr);
  putc('\n',stderr);
  exit(1);
}

static void
setup_palette(void)
{
  static const char msg[] = "problem setting up colors!";
  if(start_color() != OK) kill_program(msg);
  for(int c = 1; c<COLOR_PAIRS; ++c) 
     if(init_pair(c, c, COLOR_BLACK) != OK)
       kill_program(msg);
}

int
main(int argc, char *argv[])
{
  initscr();
  if(!has_colors()) kill_program("Your terminal has no colors!");
  setup_palette();
  printw("You have %d colors and %d pairs available.\n\n", COLORS, COLOR_PAIRS);
  for(int c = 0; c < COLOR_PAIRS; ++c) {
      attrset(COLOR_PAIR(c));
      printw("C:%03d", c);
      attron(A_BOLD);
      printw(" (BOLD) ");
      attrset(A_NORMAL);
      if(c % 8 == 7) addch('\n');
  }
  printw("\n\nPress a key to continue.");
  refresh();
  getch();
  endwin();

  return 0;
}
