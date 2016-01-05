;;; Copyright (c) 2016, Fereshta Yazdani <yazdani@cs.uni-bremen.de>
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

(defun direction-symbol (sym)
  (intern (string-upcase sym) "KEYWORD"))
  
(defun look-list-size (mlist type agent cmd gesture)
  (if(= 1 mlist)
     (test-action mlist type agent cmd gesture)
     (test-actions mlist type agent cmd gesture)))

(defun test-action (mlist type agent cmd gesture)
 (format t "test action ~%")
  (let*((desig NIL))
    (cond ((string-equal "move" (first mlist))
           (setf desig (action-move-designator type agent cmd gesture)))
          ((string-equal "detect" (first mlist))
           (setf desig (action-detect-designator type agent cmd)))
          (t (format t "test-action not given~%")))
    desig))

(defun test-actions (mlist type agent cmd gesture)
  (format t "test actions ~%")
  (let*((desig NIL))
    (cond ((and (string-equal "move" (first mlist))
                (string-equal "detect" (second mlist)))
           (setf desig (action-move-detect-designator type agent cmd gesture)))
       ;;   ((and (string-equal "move" (first mlist))
       ;;         (string-equal "move" (second mlist)))
       ;;    (setf desig (action-double-move-designator type agent cmd gesture)))
          ((and (string-equal "move" (first mlist))
                (string-equal "take" (second mlist)))
           (setf desig (action-move-take-designator type agent cmd gesture)))
          (t (format t "test-actions is not given~%")))
    desig))

