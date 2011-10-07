;;; popup+.el -- Enhancement of `popup.el'

;; Copyright (C) 2011 Seung Cheol Jung

;; Author: Seung Cheol Jung
;; Version: 0.1
;; Keywords: Tooltip

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.

;; It is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.

;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
;; MA  02110-1301 USA

;;; Commentary:

;; TODO

(require 'popup)

(defconst popup+-version "0.1")

(defgroup popup+ nil
  "Enhancement of `popup'"
  :tag "popup+"
  :prefix "popup+-"
  :group 'convenience)

(defcustom popup+-func-alist
  '((emacs-lisp-mode (popup+-emacs-variable popup+-emacs-function)))
  "Alist of functions, which returns a tip string, for each major modes"
  :type '(alist :key-type symbol
                :value-type (repeat function))
  :group 'popup+)

(defcustom popup+-normal-foreground "black"
  "Foreground color of normal tips"
  :type 'color
  :group 'popup+)

(defcustom popup+-normal-background "khaki1"
  "Background color of normal tips"
  :type 'color
  :group 'popup+)

(defcustom popup+-error-foreground "white"
  "Foreground color of error tips"
  :type 'color
  :group 'popup+)

(defcustom popup+-error-background "dark red"
  "Background color of error tips"
  :type 'color
  :group 'popup+)

(defun popup+-error (string)
  "Show an error tip"
  (set-face-foreground 'popup-tip-face popup+-error-foreground)
  (set-face-background 'popup-tip-face popup+-error-background)
  (popup-tip string))

(defun popup+-normal (string)
  "Show an normal tip"
  (set-face-foreground 'popup-tip-face popup+-normal-foreground)
  (set-face-background 'popup-tip-face popup+-normal-background)
  (popup-tip string))

(defun popup+-dwim ()
  "Display proper tooltip for the current context."
  (interactive)
  (let ((funcs (cadr (assoc major-mode popup+-func-alist))))
    (if funcs
        (catch 'endloop
          (dolist (popup-func funcs nil)
            (let ((tip (call-interactively popup-func)))
              (when tip
                (popup+-normal tip)
                (throw 'endloop nil))))
          (popup+-error "No proper tips"))
      (popup+-error (format "No tips for %s" major-mode)))))

(defun popup+-emacs-function (function)
  "Return the full documentation of FUNCTION (a symbol) in tooltip."
  (interactive (list (function-called-at-point)))
  (if (null function)
      nil
    (with-temp-buffer
      (let ((standard-output (current-buffer)))
        (prin1 function)
        (princ " is ")
        (describe-function-1 function)
        (buffer-string)))))

(defun popup+-emacs-variable (variable)
  "Return the full documentation of VARIABLE (a symbol) in tooltip."
  (interactive (list (variable-at-point)))
  (if (equal 0 variable)
      nil
    (save-excursion
      (save-window-excursion
        (describe-variable variable)
        (set-buffer (help-buffer))
        (buffer-string)))))

(global-set-key (kbd "M-/") 'popup+-dwim)

(provide 'popup+)
