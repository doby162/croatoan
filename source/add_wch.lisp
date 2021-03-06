(in-package :de.anvi.croatoan)

(defun add-wide-char-utf-8 (window char &key attributes color-pair y x n)
  "Add the wide (multi-byte) char to the window, then advance the cursor.

If the destination coordinates y and x are given, move the cursor to the
destination first and then add the character.

If n is given, write n chars. If n is -1, as many chars will be added
as will fit on the line."
  (when (and y x) (move window y x))
  (let ((count  (if n
                   (if (= n -1)
                       (- (.width window) (cadr (.cursor-position window)))
                       n)
                   1))
        (code-point (typecase char
                      (integer char)
                      (character (char-code char)))))
    (typecase char
      (complex-char
       ;; if we have a complex char, use its own attributes and colors.
       (loop repeat count do
            (mapc #'(lambda (ch) (add-char window ch :attributes (.attributes char) :color-pair (.color-pair char)))
                  (unicode-to-utf-8 (char-code (.simple-char char))))))
      ;; if we have a lisp char or an integer, use the attributes and colors passed as arguments.
      (t
       (loop repeat count do
            (mapc #'(lambda (ch) (add-char window ch :attributes attributes :color-pair color-pair))
                  (unicode-to-utf-8 code-point)))))))

(defun add-wide-char (window char &key attributes color-pair y x n)
  "Add the wide (multi-byte) char to the window, then advance the cursor.

If the destination coordinates y and x are given, move the cursor to the
destination first and then add the character.

If n is given, write n chars. If n is -1, as many chars will be added
as will fit on the line."
  (when (and y x) (move window y x))
  (let ((winptr (.winptr window))
        (attr (if attributes (attrs2chtype attributes) 0))
        (color-pair-number (if color-pair (pair->number color-pair) 0))
        (count  (if n
                   (if (= n -1)
                       (- (.width window) (cadr (.cursor-position window)))
                       n)
                   1)))
    (typecase char
      ;; if we have a lisp char or an integer, use the attributes and colors passed as arguments.
      (integer (loop repeat count do (add-cchar_t winptr char attr color-pair-number)))
      (character (loop repeat count do (add-cchar_t winptr (char-code char) attr color-pair-number)))
      ;; if we have a complex char, use its own attributes and colors.
      (complex-char (loop repeat count do
                         (add-cchar_t winptr
                                      (char-code (.simple-char char))
                                      (if (.attributes char) (attrs2chtype (.attributes char)) 0)
                                      (if (.color-pair char) (pair->number (.color-pair char)) 0)))))))

(defun add-cchar_t (winptr char attr_t color-pair-number)
  "Create and display a cchar_t to the window.

cchar_t is a C struct representing a wide complex-char in ncurses.

This function is a wrapper around %setcchar and should not be used elsewhere."
  (with-foreign-objects ((ptr '(:struct cchar_t))
                         (wch 'wchar_t 5))
    (dotimes (i 5) (setf (mem-aref wch 'wchar_t i) 0))
    (setf (mem-aref wch 'wchar_t) char)
    (%setcchar ptr wch attr_t color-pair-number (null-pointer))
    (%wadd-wch winptr ptr)))
