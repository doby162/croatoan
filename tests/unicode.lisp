(in-package :de.anvi.croatoan.tests)

;; Tested in xterm and Gnome Terminal.
;; Doesn't work in the Linux console and aterm.

;; Unicode strings are supported by the default non-unicode ncurses API (addstr) as long as libncursesw is used.
;; Special wide-char string functions (addwstr, add_wchstr) do not have to be used.
(defun ut01 ()
  (%initscr)

  (%mvaddstr 2 2 "ččććššđđžž")
  (%mvaddstr 4 6 "öäüüüßß")
  (%mvaddstr 6 8 "Без муки нет науки - no pain, no gain")
  (%mvaddstr 8 10 "指鹿為馬 - point deer, make horse")
  (%mvaddstr 10 12 "μολὼν λαβέ / ΜΟΛΩΝ ΛΑΒΕ - come and get it")
  
  (%refresh)
  (%getch)
  (%endwin))

;; For displaying single unicode chars, addch functions do not work, and we have to use add_wch explicitly.
;; The data type also changes, from the integral chtype for addch, to the cchar_t struct for add_wch.
(defun ut02 ()
  (let ((scr (%initscr)))

    ;; %add-wch
    ;; Add #\CYRILLIC_SMALL_LETTER_SHA = #\ш to the stdscr.
    (with-foreign-object (ptr '(:struct cchar_t))
      (setf ptr (convert-to-foreign (list 'cchar-attr 0 'cchar-chars (char-code #\ш))
                                    '(:struct cchar_t)))
      (%add-wch ptr))

    ;; %wadd-wch
    ;; #\CYRILLIC_CAPITAL_LETTER_LJE = #\Љ
    (with-foreign-object (ptr '(:struct cchar_t))
      (setf ptr (convert-to-foreign (list 'cchar-attr 0 'cchar-chars (char-code #\Љ))
                                    '(:struct cchar_t)))
      (%wadd-wch scr ptr))

    (%wrefresh scr)
    (%wgetch scr)
    (%endwin)))
