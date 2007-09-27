(in-package #:kp6-cl)

(defclass kp6-Pad (kp6-Hash)
  ((parent :accessor kp6-parent :initarg :parent)))

(define-condition kp6-variable-error (kp6-error)
  ((name :accessor kp6-name)))

(define-condition kp6-variable-exists (kp6-variable-error)
  ()
  (:report (lambda (c s)
	     (write-string (kp6-prefixed-error-message c "Variable ~A already exists." (kp6-name c)) s))))

(define-condition kp6-variable-not-found (kp6-variable-error)
  ()
  (:report (lambda (c s)
	     (write-string (kp6-prefixed-error-message c "Variable ~A does not exist." (kp6-name c)) s))))

(defgeneric kp6-pad-has-parent (pad)
  (:documentation "Test whether PAD has a parent pad.")
  (:method ((pad kp6-Pad))
    (slot-boundp pad 'parent)))

(defun kp6-generate-variable (sigil name)
  (cons (find-symbol sigil 'kp6-cl) name))

(dolist (sigil '($ @ % & |::|))
  (intern (string sigil) 'kp6-cl))

(defmacro with-kp6-pad ((interpreter) &body body)
  (with-unique-names (pad interpreter-var)
    `(let ((,interpreter-var ,interpreter))
      (let ((,pad (make-instance 'kp6-Pad :parent (when (fboundp ',(interned-symbol 'enclosing-pad)) (funcall (symbol-function ',(interned-symbol 'enclosing-pad)))))))
	(flet ,(kp6-with-pad-functions pad interpreter-var)
	  (declare (ignorable ,@(mapcar #'(lambda (name) `#',(interned-symbol name)) '(enclosing-pad outer-pad define-lexical-variable set-lexical-variable lookup-lexical-variable lookup-lexical-variable/p))))
	  ,@body)))))

(defun kp6-with-pad-functions (pad interpreter-var)
  (mapcar
   #'(lambda (func) `(,(interned-symbol (car func)) ,@(cdr func)))
   `((enclosing-pad () ,pad)
     (outer-pad () (kp6-parent ,pad))
     (define-lexical-variable (name &optional value type)
	 "Create a new lexical variable."
       (declare (ignore type))
       (when (kp6-lookup ,pad name)
	 (kp6-error ,interpreter-var 'kp6-variable-exists :name name))
       (setf (kp6-lookup ,pad name) (or value (kp6-default (car name)))))
     (set-lexical-variable (name value)
      "Set the value of a lexical variable."
      (unless (kp6-lookup ,pad name)
	(kp6-warn ,interpreter-var 'kp6-variable-not-found :name name)))
     (lookup-lexical-variable (name)
      "Get the value of NAME in *this* pad."
      (unless (kp6-exists ,pad name)
	(kp6-error ,interpreter-var 'kp6-variable-not-found :name name))
      (kp6-lookup ,pad name))
     (lookup-lexical-variable/p (name)
      "Get the value of NAME in any enclosing pad."
      (if (kp6-exists ,pad name)
	  (kp6-lookup ,pad name)
	  (if (slot-boundp ,pad 'parent)
	      (,(interned-symbol 'lookup-lexical-variable) name)
	      (kp6-error ,interpreter-var 'kp6-variable-not-found :name name)))))))
