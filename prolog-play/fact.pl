% see what gnu prolog's upper integer limit is (if any), and also play
% with findall/3.  For me, the high was 22! = 1,055,182,290,538,725,376

:- initialization(main).

% fact(N,Acc,F)  factorial calculated with Accumulator
fact(1,Acc,Acc).
fact(N,Acc,F) :- N > 1, N1 is N - 1, Acc1 is Acc * N, fact(N1,Acc1,F).

% fact(N,F) convenience that calls fact/3
fact(N,F) :- fact(N,1,F).

% identify the first entry that's smaller than the previous... overflow
% must use phrase/3 with this, since we won't read the whole list...
% If it fails, there was no overflow.
find_overflow(N,F1) --> [f(N,F1),f(_,F2)], { F1 > F2 }, !.
find_overflow(N,F1) --> [_], !, find_overflow(N,F1).

main :- findall(f(N,F), (between(1,50,N), fact(N,F)), Fs),
  phrase(find_overflow(N,F),Fs,_), format('~D! = ~D~n',[N,F]).

% vim: filetype=prolog
