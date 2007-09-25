(in-package #:kp6-cl)

(define-condition kp6-condition ()
  ((interpreter :reader kp6-interpreter :initarg :interpreter)))

(define-condition kp6-warning (kp6-condition warning)
  ((message :reader kp6-message :initarg :message))
  (:report (lambda (c s)
	     (write-string (kp6-prefixed-error-message (c (kp6-message c))) s))))

(define-condition kp6-error (kp6-condition error)
  ()
  (:report (lambda (c s)
	     (write-string (kp6-prefixed-error-message (c "Unhandled error")) s))))

(macrolet ((define-kp6-error-function (name function type)
	       (let ((interpreter (gensym))
		     (information (gensym)))
		 `(defgeneric ,name (,interpreter &rest ,information)
		   (:documentation ,(format nil "Call the builtin ~S function with a KP6-specific condition class and information." function))
		   (:method ((,interpreter kp6-interpreter) &rest ,information)
		     (apply #',(intern (symbol-name function) 'cl) ,type (append (list :interpreter ,interpreter) ,information)))))))
  (define-kp6-error-function kp6-signal signal 'kp6-condition)
  (define-kp6-error-function kp6-warn warn 'kp6-warning)
  (define-kp6-error-function kp6-error error 'kp6-error))

(defun kp6-prefixed-error-message (condition datum &rest arguments)
  (format nil "In ~S: ~?" (kp6-interpreter condition) datum arguments))
