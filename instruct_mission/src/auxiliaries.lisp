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
  (format t "count actions~%")
  (let* ((mlist (split-cmd cmd))
         (mmlist NIL)
         (desig NIL))
     (format t "count2 actions mlist ~a~%" mlist)
    (cond ((= 1 (length mlist))
           (format t "count2 erereactions~%")
           (setf mmlist (list (instruct-mission::get-action (first mlist))))
            (format t "count2 erereactions~%")

           (setf desig (test-action mmlist type agent mlist gesture)))
          ((= 2 (length mlist))
            (format t "codsdsdunt2 actions~%")
           (setf mmlist (list (instruct-mission::get-action (first mlist)) (instruct-mission::get-action (second mlist))))
            (format t "codsdsdunt2 actions~%")
            (setf desig (test-actions mmlist type agent mlist gesture)))
          (t (format t "Something is wrong~%")))
    desig))
    
    
         

(defun split-cmd (cmd)
   (format t "split actions~%")
  (split-sequence:split-sequence #\; cmd))

(defun get-action (cmd-part)
  (car (split-sequence:split-sequence #\( cmd-part)))

(defun get-dir (cmd-part)
(cadr (split-sequence:split-sequence #\( (car (split-sequence:split-sequence #\,  cmd-part)))))

(defun get-dir-one (cmd-part)
(cadr (split-sequence:split-sequence #\( (car (split-sequence:split-sequence #\)  cmd-part)))))

(defun get-dir-cntnt (cmd-part)
 (car (split-sequence:split-sequence #\( (car (cdr (split-sequence:split-sequence #\,  cmd-part))))))

(defun get-dir-cntnt2 (cmd-part)
(first (split-sequence:split-sequence #\) (second (split-sequence:split-sequence #\( (car (cdr (split-sequence:split-sequence #\, cmd-part))))))))

(defun get-dir-cntnt3 (cmd-part)
(first (split-sequence:split-sequence #\) (second (split-sequence:split-sequence #\, cmd-part)))))


;;; all the action designator

(defun action-move-designator (type agent cmd gesture)
  (let*((act (instruct-mission::get-action (first cmd)))
        (dir (instruct-mission::get-dir (first cmd)))
        (loc (make-designator :location `((,(instruct-mission::direction-symbol dir) ,gesture)))))
    (setf ref (reference loc))    
    (make-designator :action `((:cmd ,type)
                               (:agent ,agent)
                               (:type ,act)
                               (:loc ,ref)))))

(defun action-detect-designator (type agent cmd)
  (let*((act (instruct-mission::get-action (first cmd)))
        (col (instruct-mission::get-dir (first cmd)))
        (obj (instruct-mission::get-dir-cntnt3 (first cmd)))
        (loc (make-designator :location `((:to :see)
                                          (:color ,col)
                                          (:type ,obj)))))
    (setf ref (reference loc))    
    (make-designator :action `((:cmd ,type)
                               (:agent ,agent)
                               (:type ,act)
                               (:loc ,ref)))))

(defun action-move-detect-designator (type agent cmd gesture)
  (let*((act (instruct-mission::get-action (first cmd)))
        (dir (instruct-mission::get-dir (first cmd)))
        ;;  (act2 (instruct-mission::get-action (second cmd)))
        (col (instruct-mission::get-dir (second cmd)))
        (obj (instruct-mission::get-dir-cntnt3 (second cmd)))
        (loc (make-designator :location `((,(instruct-mission::direction-symbol dir) ,gesture)
                                          (:to :see)
                                          (:type ,obj)
                                          (:color ,col)))))
   ;; (setf ref (reference loc))    
    (make-designator :action `((:cmd ,type)
                               (:agent ,agent)
                               (:type ,(read-from-string act))
                               (:loc ,loc)))))

;; (defun action-double-move-designator (type agent cmd gesture)
;;   (let*((act (instruct-mission::get-action (first cmd)))
;;         (col (instruct-mission::get-dir (first cmd)))
;;         (obj (instruct-mission::get-dir-cntnt3 (first cmd)))
;;         (loc (make-designator :location `((:to :see)
;;                                           (:color ,col)
;;                                           (:type ,obj)))))
;;     (setf ref (reference loc))    
;;     (make-designator :action `((:cmd ,type)
;;                                (:agent ,agent)
;;                                (:type ,act)
;;                                (:loc ,ref)))))

 (defun action-move-take-designator (type agent cmd gesture)
  (let*((act (instruct-mission::get-action (first cmd)))
        (dir (instruct-mission::get-dir (first cmd)))
        (act2 (instruct-mission::get-action (second cmd)))
        (object (instruct-mission::get-dir-one (second cmd)))
        (loc (make-designator :location `((,(instruct-mission::direction-symbol dir) ,gesture))))
        (obj (make-designator :object `((:a ,(read-from-string object)))))
        (act-desig NIL))
   ;; (setf ref (reference loc))
    (list  (make-designator :action `((:cmd ,type)
                                      (:agent ,agent)
                                      (:type ,(read-from-string act))
                                      (:loc ,loc)))
           (make-designator :action `((:cmd ,type)
                                      (:agent ,agent)
                                      (:type ,(read-from-string act2))
                                      (:obj  ,obj))))))
