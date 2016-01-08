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
   (roslisp:subscribe "multimodal_msgs"
    "instruct_mission/multimodal_values"
    #'cb-result)))

(defun cb-result (msg)
  (setf *stored-result*
        (make-instance 'command-result
                       :content msg
                       :time-received (roslisp:ros-time))))

(defun pub-msg (desig)
(let ((pub (roslisp:advertise "sendMsgToServer" "mhri_msgs/multimodal")))
   (format t "endlich gehts voranCDE ~a~%" desig) 
  (roslisp:publish pub (designator-into-mhri-msg desig))))

(defun designator-into-mhri-msg (desig)
  (let*(;;(combiner NIL)
        ;;(vec-msgs NIL)
        (msg NIL)
        (pose NIL)
        (type NIL)
        (msg2 NIL)
        (str NIL))
    ;; (if(equal 'cons (type-of desig))
    ;;    (loop while (/= 0 (length desig))
    ;;          do (format t "haa~%")
    ;;             (let*((elem (first desig))
    ;;                   (description (desig:description elem))
    ;;                   (pose (second (assoc ':loc description)))
    ;;                   (type (string (second (assoc ':type description)))))
    ;;               (setf combiner (cons (list pose type) combiner))
    ;;               (setf desig (cdr desig))
    ;;               (format t "endlich gehts voranC ~a~%" combiner)))
       (let*((description (desig:description desig))
             (po (second (assoc ':loc description)))
             (ty (string (second (assoc ':type description)))))
         (setf pose po)
         (setf type ty)
         (format t "nooo come on ~a~%"(type-of  ty))
    (format t "endlich gehts voranAA ~a and ~a~%" type pose))
        ;; (setf combiner (list type pose))))
   ;; (setf vec-msgs (map 'vector #'identity combiner))
    (setf str (cl-transforms-stamped::make-msg "std_msgs/String"
                                                                           :data  type))
    (setf msg (roslisp:make-message "mhri_msgs/interpretation"
                                    :type str
                                    :pose (cl-transforms-stamped:to-msg pose)))
        (format t "endlich gehts voran........ ~%" )
    (setf msg2 (roslisp:make-message "mhri_msgs/multimodal"
                          :action  (vector msg)))
     (format t "endlich gehts voran........ ~a~%"  msg2)
     msg2))
;;(defun designator-into-mhri-msg (desig)
;;(let*((combiner NIL))
;;(if(equal 'cons (type-of desig))
;;(loop while (/= 0 (length desig))
;; do
;;(let*((elem (first desig))
;;      (desig (cdr desig))
;;      (description (desig:description elem))
;;      (loc (second (assoc ':loc description)))
;;      (pose (second (assoc ':loc description)))
;;      (type (string (second (assoc ':type description))))
;;      (combiner (cons (list pose type) combiner))
;;   (format t "endlich einmal durch)))
;;   (let*((description (desig:description desig))
;;         (loc (second (assoc ':loc description)))
;;      (pose (second (assoc ':loc description)))
;;      (type (string (second (assoc ':type description))))
;;      (combiner (cons (list pose type) combiner))))
;;      (vec (map 'vector #'identity combiner))
;; (roslisp:make-message
;;  "mhri_msgs/multimodal"
;;     :action vec)))
;;(roslisp:publish pub (instruct-mission::designator-into-mhri-msg (command-into-designator)))))
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
