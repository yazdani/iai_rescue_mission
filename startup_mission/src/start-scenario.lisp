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
(defparameter *swm-liste* NIL)
(defparameter *gesture*  (cl-transforms:make-pose (cl-transforms:make-3d-vector 2 3 4) (cl-transforms:make-quaternion 0 0 0 1)))


(defun service-call ()
  (roslisp-utilities:startup-ros :name "service_node")
  (roslisp:register-service "multimodal_lisp" 'instruct_mission-srv:multimodal_lisp)
  (roslisp:ros-info (basics-system) "the msg."))

 (defun start-mission ()
   (format t "start-mission ~%")
   (service-call))

(roslisp:def-service-callback instruct_mission-srv:multimodal_lisp (selected type command gesture location)
  (format t "in sevice callback command ~a~%" command)
  (let*((agent (substitute #\_ #\Space selected))
        (type (read-from-string type))
        (icmd command)
        (msg NIL)
        (ge-vector (cl-transforms::make-3d-vector (svref gesture 0)
                                                  (* (svref gesture 1) (- 1))
                                                   (* (svref gesture 2) (- 1))))      
         ;; (gps-vector (cl-transforms::make-3d-vector (svref location 0)
         ;;                                            (svref location 1)
         ;;                                            (svref location 2)))
         (gesture-elem  (swm->give-obj-pointed-at ge-vector))
       (desig-list  (instruct-mission::create-the-msg agent type icmd gesture-elem))  
  ;; (format t " what is desig-list ~a~%" desig-list)
     (tmp (instruct-mission::create-mhri-msg desig-list)))
   (format t "desiglist ~a~% and tmp ~a~%" desig-list tmp)
    (cond ((= (length tmp) 1)
           (setf msg  (roslisp:make-message "mhri_msgs/multimodal" :action (vector (first tmp)))))
          ((= (length tmp) 2)
         (setf msg  (roslisp:make-message "mhri_msgs/multimodal" :action (vector (first tmp) (second tmp)))))

          ((= (length tmp) 3)
         (setf msg  (roslisp:make-message "mhri_msgs/multimodal" :action (vector (first tmp) (second tmp) (third tmp))))))
    (roslisp:make-response :interpretation msg)))

    ;; (format t "desig: ~a~%" desig)
   ;; (format t "desig2: ~a~%" (instruct-mission::designator-into-mhri-msg desig))
   ;; (roslisp:make-response :action (instruct-mission::designator-into-mhri-msg desig))))

;; (defun service-call ()
;; (let*((index 0))
;;   (loop while (= index 0)
;;         do(;; (roslisp:with-ros-node ("starting_ros_node" :spin t)
;;            (roslisp:register-service "multimodal_lisp" 'instruct_mission-srv:multimodal_lisp)
;;     (roslisp:ros-info (basics-system) "the msg.")
;;    ))))



;; (defun parse-cmd-into-designator (selected type command gesture location)
;;   (let* ((agent (read-from-string (substitute #\- #\Space selected)))
;;          (type (read-from-string type))
;;          (icmd command)
;;          (ge-vector (cl-transforms::make-3d-vector (svref gesture 0)
;;                                                    (svref gesture 1)
;;                                                    (svref gesture 2)))         
;;          ;; (gps-vector (cl-transforms::make-3d-vector (svref location 0)
;;          ;;                                            (svref location 1)
;;          ;;                                            (svref location 2)))
;;          (gesture-elem  (swm->give-obj-pointed-at ge-vector)))
;;          ;;   (gesture-elem  (give-obj-pointed-at ge-vector)))
;;     (format t "gesture elem ~a~%" gesture-elem)
;;     (instruct-mission::count-actions type agent icmd gesture-elem)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DCM STUFF;;;;;;;;;;;;;;;;;;;;;;;;
