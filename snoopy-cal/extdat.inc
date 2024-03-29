/* here is more data from the original Fortran program, turned into C arrays
   for use in our C program.  Each line here is 78 chars long (plus the \0).
*/
static const char months[][79] =  {
"           JJJJJJJ   AAAAA   N     N  U     U   AAAAA   RRRRRR   Y     Y      " /* 01 */,
"              J     A     A  NN    N  U     U  A     A  R     R   Y   Y       " /* 02 */,
"              J     A     A  N N   N  U     U  A     A  R     R    Y Y        " /* 03 */,
"              J     AAAAAAA  N  N  N  U     U  AAAAAAA  RRRRRR      Y         " /* 04 */,
"              J     A     A  N   N N  U     U  A     A  R   R       Y         " /* 05 */,
"           J  J     A     A  N    NN  U     U  A     A  R    R      Y         " /* 06 */,
"            JJ      A     A  N     N   UUUUU   A     A  R     R     Y         " /* 07 */,
"       FFFFFFF  EEEEEEE  BBBBBB   RRRRRR   U     U   AAAAA   RRRRRR   Y     Y " /* 08 */,
"       F        E        B     B  R     R  U     U  A     A  R     R   Y   Y  " /* 09 */,
"       F        E        B     B  R     R  U     U  A     A  R     R    Y Y   " /* 10 */,
"       FFFFF    EEEEE    BBBBBB   RRRRRR   U     U  AAAAAAA  RRRRRR      Y    " /* 11 */,
"       F        E        B     B  R   R    U     U  A     A  R   R       Y    " /* 12 */,
"       F        E        B     B  R    R   U     U  A     A  R    R      Y    " /* 13 */,
"       F        EEEEEEE  BBBBBB   R     R   UUUUU   A     A  R     R     Y    " /* 14 */,
"                    M     M   AAAAA   RRRRRR    CCCCC   H     H               " /* 15 */,
"                    MM   MM  A     A  R     R  C     C  H     H               " /* 16 */,
"                    M M M M  A     A  R     R  C        H     H               " /* 17 */,
"                    M  M  M  AAAAAAA  RRRRRR   C        HHHHHHH               " /* 18 */,
"                    M     M  A     A  R   R    C        H     H               " /* 19 */,
"                    M     M  A     A  R    R   C     C  H     H               " /* 20 */,
"                    M     M  A     A  R     R   CCCCC   H     H               " /* 21 */,
"                     AAAAA   PPPPPP   RRRRRR   IIIIIII  L                     " /* 22 */,
"                    A     A  P     P  R     R     I     L                     " /* 23 */,
"                    A     A  P     P  R     R     I     L                     " /* 24 */,
"                    AAAAAAA  PPPPPP   RRRRRR      I     L                     " /* 25 */,
"                    A     A  P        R   R       I     L                     " /* 26 */,
"                    A     A  P        R    R      I     L                     " /* 27 */,
"                    A     A  P        R     R  IIIIIII  LLLLLLL               " /* 28 */,
"                             M     M   AAAAA   Y     Y                        " /* 29 */,
"                             MM   MM  A     A   Y   Y                         " /* 30 */,
"                             M M M M  A     A    Y Y                          " /* 31 */,
"                             M  M  M  AAAAAAA     Y                           " /* 32 */,
"                             M     M  A     A     Y                           " /* 33 */,
"                             M     M  A     A     Y                           " /* 34 */,
"                             M     M  A     A     Y                           " /* 35 */,
"                         JJJJJJJ  U     U  N     N  EEEEEEE                   " /* 36 */,
"                            J     U     U  NN    N  E                         " /* 37 */,
"                            J     U     U  N N   N  E                         " /* 38 */,
"                            J     U     U  N  N  N  EEEEE                     " /* 39 */,
"                            J     U     U  N   N N  E                         " /* 40 */,
"                         J  J     U     U  N    NN  E                         " /* 41 */,
"                          JJ       UUUUU   N     N  EEEEEEE                   " /* 42 */,
"                         JJJJJJJ  U     U  L        Y     Y                   " /* 43 */,
"                            J     U     U  L         Y   Y                    " /* 44 */,
"                            J     U     U  L          Y Y                     " /* 45 */,
"                            J     U     U  L           Y                      " /* 46 */,
"                            J     U     U  L           Y                      " /* 47 */,
"                         J  J     U     U  L           Y                      " /* 48 */,
"                          JJ       UUUUU   LLLLLLL     Y                      " /* 49 */,
"                 AAAAA   U     U   GGGGG   U     U   SSSSS   TTTTTTT          " /* 50 */,
"                A     A  U     U  G     G  U     U  S     S     T             " /* 51 */,
"                A     A  U     U  G        U     U  S           T             " /* 52 */,
"                AAAAAAA  U     U  G   GGG  U     U   SSSSS      T             " /* 53 */,
"                A     A  U     U  G     G  U     U        S     T             " /* 54 */,
"                A     A  U     U  G     G  U     U  S     S     T             " /* 55 */,
"                A     A   UUUUU    GGGGG    UUUUU    SSSSS      T             " /* 56 */,
" SSSSS   EEEEEEE  PPPPPP  TTTTTTT  EEEEEEE  M     M  BBBBBB   EEEEEEE  RRRRRR " /* 57 */,
"S     S  E        P     P    T     E        MM   MM  B     B  E        R     R" /* 58 */,
"S        E        P     P    T     E        M M M M  B     B  E        R     R" /* 59 */,
" SSSSS   EEEEE    PPPPPP     T     EEEEE    M  M  M  BBBBBB   EEEEE    RRRRRR " /* 60 */,
"      S  E        P          T     E        M     M  B     B  E        R   R  " /* 61 */,
"S     S  E        P          T     E        M     M  B     B  E        R    R " /* 62 */,
" SSSSS   EEEEEEE  P          T     EEEEEEE  M     M  BBBBBB   EEEEEEE  R     R" /* 63 */,
"            OOOOO    CCCCC   TTTTTTT   OOOOO   BBBBBB   EEEEEEE  RRRRRR       " /* 64 */,
"           O     O  C     C     T     O     O  B     B  E        R     R      " /* 65 */,
"           O     O  C           T     O     O  B     B  E        R     R      " /* 66 */,
"           O     O  C           T     O     O  BBBBBB   EEEEE    RRRRRR       " /* 67 */,
"           O     O  C           T     O     O  B     B  E        R   R        " /* 68 */,
"           O     O  C     C     T     O     O  B     B  E        R    R       " /* 69 */,
"            OOOOO    CCCCC      T      OOOOO   BBBBBB   EEEEEEE  R     R      " /* 70 */,
"       N     N   OOOOO   V     V  EEEEEEE  M     M  BBBBBB   EEEEEEE  RRRRRR  " /* 71 */,
"       NN    N  O     O  V     V  E        MM   MM  B     B  E        R     R " /* 72 */,
"       N N   N  O     O  V     V  E        M M M M  B     B  E        R     R " /* 73 */,
"       N  N  N  O     O  V     V  EEEEE    M  M  M  BBBBBB   EEEEE    RRRRRR  " /* 74 */,
"       N   N N  O     O   V   V   E        M     M  B     B  E        R   R   " /* 75 */,
"       N    NN  O     O    V V    E        M     M  B     B  E        R    R  " /* 76 */,
"       N     N   OOOOO      V     EEEEEEE  M     M  BBBBBB   EEEEEEE  R     R " /* 77 */,
"       DDDDDD   EEEEEEE   CCCCC   EEEEEEE  M     M  BBBBBB   EEEEEEE  RRRRRR  " /* 78 */,
"       D     D  E        C     C  E        MM   MM  B     B  E        R     R " /* 79 */,
"       D     D  E        C        E        M M M M  B     B  E        R     R " /* 80 */,
"       D     D  EEEEE    C        EEEEE    M  M  M  BBBBBB   EEEEE    RRRRRR  " /* 81 */,
"       D     D  E        C        E        M     M  B     B  E        R   R   " /* 82 */,
"       D     D  E        C     C  E        M     M  B     B  E        R    R  " /* 83 */,
"       DDDDDD   EEEEEEE   CCCCC   EEEEEEE  M     M  BBBBBB   EEEEEEE  R     R " /* 84 */
};

static const char weekdays[] = "         SUNDAY            MONDAY            TUESDAY          WEDNESDAY"
                               "         THURSDAY           FRIDAY           SATURDAY";

static const int days_in_month[] = { 31,28,31,30,31,30,31,31,30,31,30,31 };

/* each digit is 6 chars wide */
static const char numerals[][60] = {
"  000    1    222  33333    4  55555  666  77777  888   999 ", /*  92 */
" 0   0  11   2   2     3   44  5     6         7 8   8 9   9", /*  93 */
" 0   0   1      2    33   4 4  5555  6666     7   888   9999", /*  94 */
" 0   0   1    2    3   3 44444     5 6   6   7   8   8     9", /*  95 */
"  000  11111 22222  333     4  5555   666    7    888   999 "  /*  96 */
};
