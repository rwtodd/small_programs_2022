module DoubleCola

// see the lisp version for comments with info about the problem

let double_cola n = 
  let names = [| "sheldon"; "leonard"; "penny" ; "raj" ; "howard" |]
  let rec dc_index n = if n < 5 then n else dc_index ((n-5)/2)
  names[dc_index (n - 1)]
  

