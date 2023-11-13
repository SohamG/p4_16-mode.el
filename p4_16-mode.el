;;; p4_16-mode.el --- Support for the P4_16 programming language -*- lexical-binding: t; -*-

;; Author: Soham S Gumaste <sohamg2@gmail.com>
;; Maintainer: Soham S Gumaste <sohamg2@gmail.com>
;; Created: 11 Nov 2023
;; Original Source: https://github.com/p4lang/tutorials/blob/master/vm/p4_16-mode.el
;; Original License: Apache 2.0
;; Original Author: Vladimir Gurevich <vladimir.gurevich@barefootnetworks.com>
;; Modifications bylicensed under the same license OR the MIT License.

;; Keywords: languages p4_16

;; This file is not part of GNU Emacs.

;; This file is free software…
;; …
;; along with this file.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; P4 (Programming Protocol Independent Packet Processors) is a domain
;; specific language designed to program network fabric devices.
;; This mode has preliminary support for P4_16. It covers the core language,
;; but it is not clear yet, how we can highlight the indentifiers, defined
;; for a particular architecture. Core library definitions are included


;;; Code:
(defvar p4_16-mode-hook nil)

;; Define the keymap (for now it is pretty much default)
(defvar p4_16-mode-map
  (let ((map (make-keymap)))
    (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for P4_16 major mode")

;; Syntactic HighLighting

;; Main keywors (declarations and operators)
(defconst p4_16-keywords
      '("action" "apply"
        "control"
        "default"
        "else" "enum" "extern" "exit"
        "header" "header_union"
        "if"
        "match_kind"
        "package" "parser"
        "return"
        "select" "state" "struct" "switch"
        "table"  "transition" "tuple" "typedef"
        "verify"
        ))

(defconst p4_16-annotations
      '("@name" "@metadata" "@alias"
        ))

(defconst p4_16-attributes
      '("const" "in" "inout" "out"
        ;; Tables
        "key" "actions" "default_action" "entries" "implementation"
        "counters" "meters"
        ))

(defconst p4_16-variables
      '("packet_in" "packet_out"
       ))

(defconst p4_16-operations
      '("&&&" ".." "++" "?" ":"))

(defconst p4_16-constants
      '(
        ;;; Don't care
        "_"
        ;;; bool
        "false" "true"
        ;;; error
        "NoError" "PacketTooShort" "NoMatch" "StackOutOfBounds"
        "OverwritingHeader" "HeaderTooShort" "ParserTiimeout"
        ;;; match_kind
        "exact" "ternary" "lpm" "range"
        ;;; We can add constants for supported architectures here
        ))

(defconst p4_16-types
      '("bit" "bool" "int" "varbit" "void" "error"
        ))

(defconst p4_16-primitives
      '(
        ;;; Header methods
        "isValid" "setValid" "setInvalid"
        ;;; Table Methods
        "hit" "action_run"
        ;;; packet_in methods
        "extract" "lookahead" "advance" "length"
        ;;; packet_out methods
        "emit"
        ;;; Known parser states
        "accept" "reject"
        ;;; misc
        "NoAction"
        ))

(defconst p4_16-cpp
      '("#include"
        "#define" "#undef"
        "#if" "#ifdef" "#ifndef"
        "#elif" "#else"
        "#endif"
        "defined"
        "#line" "#file"))

(defconst p4_16-cppwarn
      '("#error" "#warning"))

;; Optimize the strings
(setq p4_16-keywords-regexp    (regexp-opt p4_16-keywords   'words))
(setq p4_16-annotations-regexp (regexp-opt p4_16-annotations     1))
(setq p4_16-attributes-regexp  (regexp-opt p4_16-attributes 'words))
(setq p4_16-variables-regexp   (regexp-opt p4_16-variables  'words))
(setq p4_16-operations-regexp  (regexp-opt p4_16-operations 'words))
(setq p4_16-constants-regexp   (regexp-opt p4_16-constants  'words))
(setq p4_16-types-regexp       (regexp-opt p4_16-types      'words))
(setq p4_16-primitives-regexp  (regexp-opt p4_16-primitives 'words))
(setq p4_16-cpp-regexp         (regexp-opt p4_16-cpp        1))
(setq p4_16-cppwarn-regexp     (regexp-opt p4_16-cppwarn    1))


;; create the list for font-lock.
;; each category of keyword is given a particular face
(defconst p4_16-font-lock-keywords
  (list
   (cons p4_16-cpp-regexp         font-lock-preprocessor-face)
   (cons p4_16-cppwarn-regexp     font-lock-warning-face)
   (cons p4_16-types-regexp       font-lock-type-face)
   (cons p4_16-constants-regexp   font-lock-constant-face)
   (cons p4_16-attributes-regexp  font-lock-builtin-face)
   (cons p4_16-variables-regexp   font-lock-variable-name-face)
   ;;; This is a special case to distinguish the method from the keyword
   (cons "\\.apply"               font-lock-function-name-face)
   (cons p4_16-primitives-regexp  font-lock-function-name-face)
   (cons p4_16-operations-regexp  font-lock-builtin-face)
   (cons p4_16-keywords-regexp    font-lock-keyword-face)
   (cons p4_16-annotations-regexp font-lock-keyword-face)
   (cons "\\(\\w*_t +\\)"      font-lock-type-face)
   (cons "[^A-Z_][A-Z] "       font-lock-type-face) ;; Total hack for templates
   (cons "<[A-Z, ]*>"          font-lock-type-face)
   (cons "\\(<[^>]+>\\)"       font-lock-string-face)
   (cons "\\([^_A-Za-z]\\([0-9]+w\\)?0x[0-9A-Fa-f]+\\)" font-lock-constant-face)
   (cons "\\([^_A-Za-z]\\([0-9]+w\\)?0b[01]+\\)"        font-lock-constant-face)
   (cons "\\([^_A-Za-z][+-]?\\([0-9]+w\\)?[0-9]+\\)"    font-lock-constant-face)
   ;;(cons "\\(\\w*\\)"        font-lock-variable-name-face)
   )
  "Default Highlighting Expressions for P4_16")

(defvar p4_16-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry  ?_  "w"      st)
    (modify-syntax-entry  ?/  ". 124b" st)
    (modify-syntax-entry  ?*  ". 23"   st)
    (modify-syntax-entry  ?\n  "> b"   st)
    st)
  "Syntax table for p4_16-mode")

;;; Indentation
(defvar p4_16-indent-offset 4
  "Indentation offset for `p4_16-mode'.")

(defun p4_16-indent-line ()
  "Indent current line for any balanced-paren-mode'."
  (interactive)
  (let ((indent-col 0)
        (indentation-increasers "[{(]")
        (indentation-decreasers "[})]")
        )
    (save-excursion
      (beginning-of-line)
      (condition-case nil
          (while t
            (backward-up-list 1)
            (when (looking-at indentation-increasers)
              (setq indent-col (+ indent-col p4_16-indent-offset))))
        (error nil)))
    (save-excursion
      (back-to-indentation)
      (when (and (looking-at indentation-decreasers)
                 (>= indent-col p4_16-indent-offset))
        (setq indent-col (- indent-col p4_16-indent-offset))))
    (indent-line-to indent-col)))

;;; Imenu support
(defun p4_16-imenu ()
  (let (p4_16-imenu-generic-expression
        '(("Controls"      "^ *control +\\([A-Za-z0-9_]*\\)"      1)
          ("Externs"       "^ *extern +\\([A-Za-z0-9_]*\\) *\\([A-Za-z0-9_]*\\)" 2)
          ("Tables"        "^ *table +\\([A-Za-z0-9_]*\\)"        1)
          ("Actions"       "^ *action +\\([A-Za-z0-9_]*\\)"       1)
          ("Parsers"       "^ *parser +\\([A-Za-z0-9_]*\\)"       1)
          ("Parser States" "^ *state +\\([A-Za-z0-9_]*\\)"        1)
          ("Headers"       "^ *header +\\([A-Za-z0-9_]*\\)"       1)
          ("Header Unions" "^ *header_union +\\([A-Za-z0-9_]*\\)" 1)
          ("Structs"       "^ *struct +\\([A-Za-z0-9_]*\\)"       1)))
    (setq imenu-generic-expression p4_16-imenu-generic-expression))
  (imenu-add-to-menubar "P4_16"))

;; Put everything together
(defun p4_16-mode ()
  "Major mode for editing P4_16 programs"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table p4_16-mode-syntax-table)
  (use-local-map p4_16-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(p4_16-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'p4_16-indent-line)
  (setq major-mode 'p4_16-mode)
  (setq mode-name "P4_16")
  (with-eval-after-load "imenu" (p4_16-imenu))
  (with-eval-after-load "xcscope" (cscope-minor-mode))
  (run-hooks 'p4_16-mode-hook))

;; The most important line
(provide 'p4_16-mode)