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

(defparameter *buffer-vector* (make-array 4 :fill-pointer 0))
(defvar *stored-result* nil)
;;
;; declaration of class
;;
(defclass command-result ()
  ((content :reader content :initarg :content)
   (time-received :reader time-received :initarg :time-received)))

;;
;; Listen to topic /interpreted_command
;;
;;(defun init-base ()
 ;; (setf *result-subscriber*
  ;; (roslisp:subscribe "/cmd_vel"
   ;; "geometry_msgs/Twist"
   ;; #'cb-result)))

(defun init-base ()
  (setf *result-subscriber*
   (roslisp:subscribe "/tf"
    "tf/tfMessage"
    #'cb-result)))

(defun cb-result (msg)
  (setf *stored-result*
        (make-instance 'command-result
                       :content msg
                       :time-received (roslisp:ros-time))))

;;(defun send-msg ()
   ;;(let ((pub (advertise "sendMsg" "designator_integration_msgs/Designator")))
      ;;(roslisp:publish pub (designator-integration-lisp::designator->msg (command-into-designator)))))

;;(defun set-buffer ()
;;  (let ((in (open "~/work/ros/indigo/catkin_ws/src/iai_rescue_mission/instruct_mission/src/tmp/tmp.txt" :if-does-not-exist nil)))
;;    (if (< 0 (array-total-size instruct-mission::*buffer-vector*))
;;        (setf *buffer-vector* (make-array 6 :fill-pointer 0)))
;;    (when in
;;      (loop for line = (read-line in nil)
;;            while line do
;;              (format t "~a~%" line)
;;              (if (string-not-equal  line "")
;;                  (vector-push line *buffer-vector*)))  
;;      (close in))))

