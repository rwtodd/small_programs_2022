% alw-cipher "The default english qabalah letter values."
alw_cipher(alphabet(1,20,13,6,25,18,11,4,23,16,9,2,21,14,7,26,19,12,5,24,17,10,3,22,15,8)).

% love-x-cipher "an inversion of the ALW cipher -- see New Order of Thelema"
love_x_cipher(alphabet(9,20,13,6,17,2,19,12,23,16,1,18,5,22,15,26,11,4,21,8,25,10,3,14,7,24)).

% liber-cxv-cipher "from linda falorio 1978 http://englishqabalah.com/"
liber_cxv_cipher(alphabet(1,5,9,12,2,8,10,0,3,6,9,14,6,13,4,7,18,15,16,11,5,8,10,11,6,32)).

% leeds-cipher "1-7-1 1-7-1 cipher (see https://grahamhancock.com/leedsm1/)"
leeds_cipher(alphabet(1,2,3,4,5,6,7,6,5,4,3,2,1,1,2,3,4,5,6,7,6,5,4,3,2,1)).

% simple-cipher "A-Z 1-26"
simple_cipher(alphabet(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26)).

% trigrammaton-cipher "From R. Leo Gillis TQ (trigrammaton qabalah)"
trigram_cipher(alphabet(5,20,2,23,13,12,11,3,0,7,17,1,21,24,10,4,16,14,15,9,25,22,8,6,18,19)).

% liber-a-cipher "Liber A vel Follis https://hermetic.com/wisdom/lib-follis"
liber_a_cipher(alphabet(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)).

% collect the ciphers so they are query-able
ciphers(alw_cipher). ciphers(love_x_cipher). ciphers(liber_cxv_cipher). ciphers(leeds_cipher).
ciphers(simple_cipher). ciphers(trigram_cipher). ciphers(liber_a_cipher).

% look up a sigle Char in cipher Ciph, resulting in Val
cipher_lookup(Ciph,Char,Val) :- call(Ciph,Alphabet), char_code(Char,Code), 
   Idx is Code - 96, Idx > 0, arg(Idx, Alphabet, Val).
cipher_lookup(_,'-',0).
cipher_lookup(_,'\'',0).

% as cipher_lookup, but always return 0 instead of failing if the character isn't found.
permissive_lookup(Ciph,Char,Val) :- (cipher_lookup(Ciph,Char,Val) ; Val =0), !.

% find a permissive total gematria value for the entire given Atom/Chars.
gematria(Ciph,Atom,Total) :- atom(Atom), atom_chars(Atom,Chars), !, gematria(Ciph, Chars, Total).
gematria(Ciph,Chars,Total) :- maplist(permissive_lookup(Ciph),Chars,Vals), sum_list(Vals,Total).

% split a phrase into runs of characters with a value, and runs without a value
% returning a list of all the runs.  Runs with values take the form Atom-Value.
gematria_phrase(Ciph,Atom,Runs) :- atom(Atom), atom_chars(Atom,Chars), !, gematria_phrase(Ciph, Chars, Runs).
gematria_phrase(Ciph,Chars,Runs) :- phrase(split_gem(Ciph,Runs),Chars).

% parsing helper... 0 or more G's in a row.
many(G,[V|Vs]) --> call(G,V), !, many(G,Vs).
many(_,[]) --> [].

% parsing helper... 1 or more G's in a row.
manyplus(G,Vs) --> many(G,Vs), { Vs \= [] }.

% parsing helper... is the value found in the cipher or not?
cipher_found(Ciph,C-V) --> [C], { cipher_lookup(Ciph,C,V) }.
cipher_notfound(Ciph,C) --> [C], { \+ cipher_lookup(Ciph,C,_) }.

%parsing helper... end of stream?
eos([],[]).

% for use in maplist/4 below... to pull apart a list of  C-V into lists of C and V.
cv_construct(C-V,C,V).

% the parser that does the actual splitting into runs for gematria_phrase/3 above.
split_gem(Ciph,[C-V|Runs]) --> manyplus(cipher_found(Ciph),CVs), !, 
  { maplist(cv_construct,CVs,Cs,Vs) }, { sum_list(Vs,V) }, { atom_chars(C,Cs) }, 
  split_gem(Ciph,Runs).
split_gem(Ciph,[Run|Runs]) --> manyplus(cipher_notfound(Ciph),Chars), !, 
  { atom_chars(Run,Chars) }, split_gem(Ciph,Runs).
split_gem(_,[]) --> call(eos), [].

% vim: filetype=prolog
