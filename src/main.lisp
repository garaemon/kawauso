(in-package #:kawauso)

(defun main ()
  (let ((args clap-sys:*argv*))
    (multiple-value-bind
          (option args) (parse-arguments args)
      )))

(defun parse-arguments (args)
  )

(defun make ()
  (format t "Hello, World~%")
  )
