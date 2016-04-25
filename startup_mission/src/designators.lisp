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

(in-package :startup-mission)

(defun create-the-desiglist (robot type cmd pelem)
  (let*((adjective NIL)
        (desig NIL))
    (dotimes (index (length cmd))
      (cond ((string-equal (first (nth index cmd)) "take")
             (format t "take is inside~%")
             (setf desig (cons "This is take" desig)))
            ((string-equal (first (nth index cmd)) "move")
             (setf desig (cons (move-desig (nth index cmd) pelem) desig)))      
            (t (format t "take and move is it not ~%"))))
    desig))




(defun move-desig (cmd pelem)
  (let*((desig NIL)
        (object NIL))
    (cond ((string-equal "nil" (third cmd))
           (setf object (swm->find-elem-in-map (fourth cmd)))
           (setf desig (make-designator :location `((,(direction-symbol (second cmd)) ,object)))))
          ((string-equal "small" (third cmd))
           (setf object (calculate-small-object (fourth cmd)))
           (setf desig (make-designator :location `((,(direction-symbol (second cmd)) ,object)))))
          ((string-equal "big" (third cmd))
           (setf object (calculate-big-object (fourth cmd)))
           (setf desig (make-designator :location `((,(direction-symbol (second cmd)) ,object)))))
          ((string-equal "pointed_at" (third cmd))
           (setf desig (make-designator :location `((,(direction-symbol (second cmd)) ,pelem)))))
          (t (format t "something went wrong in create-the-desiglist~%")))
    desig))
