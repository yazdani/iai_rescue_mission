;;; Copyright (c) 2014, Fereshta Yazdani <yazdani@cs.uni-bremen.de>
;;; All rights reserved.
;; 
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;; 
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;     * Redistributions in binary form must reproduce the above copyright
;;;       notice, this list of conditions and the following disclaimer in the
;;;       documentation and/or other materials provided with the distribution.
;;;     * Neither the name of the Institute for Artificial Intelligence/
;;;       Universitaet Bremen nor the names of its contributors may be used to 
;;;       endorse or promote products derived from this software without 
;;;       specific prior written permission.
;;; 
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.

(in-package :instruct-mission)

(defun count-actions (type agent cmd gesture)
  (let* ((desig NIL))
    (cond ((= 1 (length (split-cmd cmd)))
           (setf desig (method-with-one-seq type agent cmd gesture)))
          ((= 2 (length (split-cmd cmd)))
           (setf desig (method-with-two-seqs type agent cmd gesture)))
          (t (format t "Something is wrong~%")))

    desig))
    
    
;;split instructions by semicolon in order to describe
;;sequences of actions
(defun split-cmd (cmd)
  (split-sequence:split-sequence #\; cmd))

;;
(defun get-action (cmd-part)
  (car (split-sequence:split-sequence #\( cmd-part)))

(defun get-dir (cmd-part)
(cadr (split-sequence:split-sequence #\( (car (split-sequence:split-sequence #\,  cmd-part)))))

(defun get-dir-one (cmd-part)
(cadr (split-sequence:split-sequence #\( (car (split-sequence:split-sequence #\)  cmd-part)))))

(defun get-dir-cntnt (cmd-part)
 (car (split-sequence:split-sequence #\( (car (cdr (split-sequence:split-sequence #\,  cmd-part))))))

(defun get-inside-list (cmd-part)
  (let* ((var (split-sequence:split-sequence #\= cmd-part))
         (ret NIL))
    (if (equal (second var) NIL)
        (setf ret NIL)
        (setf ret (list (second var))))))

(defun get-dir-cntnt2 (cmd-part)
(first (split-sequence:split-sequence #\) (second (split-sequence:split-sequence #\( (car (cdr (split-sequence:split-sequence #\, cmd-part))))))))

(defun get-dir-cntnt3 (cmd-part)
(first (split-sequence:split-sequence #\) (second (split-sequence:split-sequence #\, cmd-part)))))

