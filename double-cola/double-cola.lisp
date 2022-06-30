;; (from https://www.youtube.com/watch?v=7fylNa2wZaU -- he doesn't seem to realize
;; that logarithms help linearize exponential growth, so I wrote these solutions while
;; watching him)
;;
;; Here's the problem statement (from https://codeforces.com/problemset/problem/82/A):
;;
;; Sheldon, Leonard, Penny, Rajesh and Howard are in the queue for a "Double
;; Cola" drink vending machine; there are no other people in the queue. The first
;; one in the queue (Sheldon) buys a can, drinks it and doubles! The resulting two
;; Sheldons go to the end of the queue. Then the next in the queue (Leonard) buys
;; a can, drinks it and gets to the end of the queue as two Leonards, and so on.
;; This process continues ad infinitum.
;;
;; For example, Penny drinks the third can of cola and the queue will look like
;; this: Rajesh, Howard, Sheldon, Sheldon, Leonard, Leonard, Penny, Penny.
;; 
;; Write a program that will print the name of a man who will drink the n-th can.

(defun double-cola (n) 
  (aref #(sheldon leonard penny raj howard)
      (let* ((epsilon 0.0000001d0)
             (nfrac 
               (- (expt 2d0
                     (nth-value 1 
                               (ffloor (log (/ (+ n 4) 5d0) 2d0))))
                  (- 1 epsilon))))
          (cond ((< nfrac 0.2d0) 0)
                ((< nfrac 0.4d0) 1)
                ((< nfrac 0.6d0) 2)
                ((< nfrac 0.8d0) 3)
                (t 4)))))

;; unfortunately I had to deal with some floating-point roundoff issues, but
;; including the epsilon term cleaned that up enough to work for millions of
;; values.

;; so, here's an integer-arthmetic iterative version that divides by 2 over and over
;; rather than using the logarithm:

(defun double-cola-2 (n)
  (aref #(sheldon leonard penny raj howard)
      (do ((x (1- n) (floor (- x 5) 2)))
        ((< x 5) x))))

;; How much of a problem is the floating-point rounding?
;; You can compare that they give the same answers for millions of inputs:
(defun test ()
  (loop for x from 1 to 15000000 
     when (not (eq (double-cola x) (double-cola-2 x))) 
     collect (list x (double-cola x) (double-cola-2 x))))

;; On my machine/lisp it's only off for 2 values in 15 million cases:
;; =>  ((12582907 LEONARD SHELDON) (14680059 PENNY LEONARD))

