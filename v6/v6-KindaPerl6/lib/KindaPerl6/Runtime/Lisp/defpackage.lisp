(in-package #:cl-user)

(defpackage #:kp6-cl
  (:use #:cl)
  (:export
   ;; Classes (types)
   #:kp6-Array #:kp6-Bit #:kp6-Code #:kp6-Hash #:kp6-Int #:kp6-Str #:kp6-Package #:kp6-Object #:kp6-Value #:kp6-Num #:kp6-Container #:kp6-Undef #:kp6-Char #:kp6-Pad #:kp6-Interpreter
   
   ;; Accessors
   #:kp6-value

   ; Hash.lisp
   #:kp6-STORE
   #:kp6-LOOKUP
   #:kp6-DELETE
   #:kp6-CLEAR
   #:kp6-pairs
   #:kp6-elems

   #:kp6-apply-function
   
   ; foreign.lisp
   #:cl->perl
   #:perl->cl

   #:kp6-packages

   #:kp6-generate-variable
   #:kp6-signal
   #:kp6-warn
   #:kp6-error

   #:with-kp6-package
   #:with-kp6-interpreter))
