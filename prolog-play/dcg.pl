reversal([]) --> [].
reversal([L|Ls]) --> reversal(Ls), [L].

palindrome --> [].
palindrome --> [_].
palindrome --> [E], palindrome, [E].


% vim: filetype=prolog
