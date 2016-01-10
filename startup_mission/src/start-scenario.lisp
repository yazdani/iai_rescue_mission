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

(in-package :startup-mission)

(defvar *obj-pose*)
(defparameter *liste-name* NIL)
(defparameter *liste-pose* NIL)
(defparameter *liste-dim* NIL)
(defparameter *distance* 25)
(defparameter *gesture*  (cl-transforms:make-pose (cl-transforms:make-3d-vector 2 3 4) (cl-transforms:make-quaternion 0 0 0 1)))


 (defun start-mission ()
   (instruct-mission::init-base)
   (let* ((x 1))
   (loop while (= 1 x)
         do (let* ((desig NIL))
              (loop while (equal NIL instruct-mission::*stored-result*)
                    do (setf var "Hello, don't forget me, I am still waiting"))
              (format t "~a great it worked ~%" instruct-mission::*stored-result*)
              (setf desig (parse-cmd-into-designator))
              (setf instruct-mission::*stored-result* NIL)
              (format t "UUUUUUUUUUUUnd~a~%" desig)
              (instruct-mission::pub-msg desig)))))

;;; INTERPRETATION OF INSTRUCTION ;;;

(defun parse-cmd-into-designator ()
  (let* ((cntnt (instruct-mission::content instruct-mission::*stored-result*))
         (agent (read-from-string (substitute #\- #\Space (slot-value cntnt 'instruct_mission-msg::agent))))
       ;;  (cmd (coerce (slot-value cntnt 'instruct_mission-msg::command) 'string))
         (icmd (coerce (slot-value cntnt 'instruct_mission-msg::icommand) 'string))
         (type (read-from-string (slot-value cntnt 'instruct_mission-msg::type)))
         (gesture (slot-value cntnt 'instruct_mission-msg::gesture))
         (ge-vector (cl-transforms::make-3d-vector (svref gesture 0)
                                                   (svref gesture 1)
                                                   (svref gesture 2)))         
         ;;  (gps (slot-value cntnt 'instruct_mission-msg::gps))
         ;; (gps-vector (cl-transforms::make-3d-vector (svref gps 0)
         ;;                                            (svref gps 1)
         ;;                                            (svref gps 2)))
         (gesture-elem  (give-obj-pointed-at ge-vector)))
    (instruct-mission::count-actions type agent icmd gesture-elem)))
   
