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


(roslisp:def-service-callback instruct_mission-srv:multimodal_lisp (selected type command gesture location)
  (let* ((action (make-designator :action `((:type move)
                                            (:loc ,(cl-transforms:make-pose 
                                                    (cl-transforms:make-3d-vector 14 0 1)
                                                    (cl-transforms:make-quaternion 0 0 0 1)))))))
    (format t "end ~%")
    (roslisp:make-response :mlisp (instruct-mission::designator-into-mhri-msg action))))            
(defun multimodal_func ()
  (roslisp:with-ros-node ("two_ints_server" :spin t)
    (roslisp:register-service "multimodal_lisp" 'instruct_mission-srv:multimodal_lisp)
    (roslisp:ros-info (basics-system) "the msg.")))


;;(roslisp:def-service-callback instruct_mission-srv:msgCallback (a b)
  ;;(roslisp:ros-info (basics-system) "Returning [~a + ~a = ~a]" a b (+ a b))
  ;;(roslisp:make-response :mlisp (+ a b)))

;;(defun add-two-ints-server ()
;;  (roslisp:with-ros-node ("two_ints_server" :spin t)
;;    (roslisp:register-service "add_two_ints" 'AddTwoInts)
;;    (roslisp:ros-info (basics-system) "Ready to add two ints.")))

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
   (roslisp:subscribe "many_msgs"
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
   (format t "endlich gehts voranCDE ~a~%" desig) 
(let* ((combiner NIL)
       (msg NIL)
       (msg2 NIL))
  (cond ((equal 'cons (type-of desig))
         (setf combiner (make-array (length desig) :fill-pointer 0))
         (format t "length of combiner ~a~%" (length combiner))
         (loop while (/=  (length desig) 0)
               do(format t "length ~a~%" (length desig))
                  (let*((descriptive (first desig))
                        (elem (desig:description descriptive))
                        (pose (second (assoc ':loc elem)))
                        (type (string (second (assoc ':type elem)))))
                    (setf desig (cdr desig))
                    (setf str (cl-transforms-stamped::make-msg "std_msgs/String"
                                                               :data  type))
                    (setf msg (roslisp:make-message "mhri_msgs/interpretation"
                                                    :type str
                                                    :pose (cl-transforms-stamped::to-msg pose)))
                    (format t "msg ~a~%" msg)
                    (vector-push msg combiner)
                    (format t "whats combiner ~a~%" combiner)))
         (setf msg combiner))
        (t (let*((description (desig:description desig))
                 (pose (second (assoc ':loc description)))
                 (type (string (second (assoc ':type description)))))
             (setf str (cl-transforms-stamped::make-msg "std_msgs/String"
                                                        :data  type))
             (setf msg (vector (roslisp:make-message "mhri_msgs/interpretation"
                                             :type str
                                             :pose (cl-transforms-stamped::to-msg pose)))))))
  ;;(format t "ääääääää +~a~%" msg)
  (setf msg2 (roslisp:make-message "mhri_msgs/multimodal"
                                   :action   msg))
  ;;(format t "new tests +~a~%" msg2)
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
