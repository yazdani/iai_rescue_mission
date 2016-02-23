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

(defparameter *cmd-alpha* NIL)
(defparameter *sel-alpha* NIL)
(defparameter *type-alpha* NIL)
(defparameter *gest-alpha* NIL)
(defparameter *loc-alpha* NIL)
(defparameter *desig* NIL)
(defvar *stored-result* nil)


;;; INTERPRETATION OF INSTRUCTION ;;;

;;WURDE UMGEÄNDERT FÜR SWM->Integration

(defun create-mhri-msgs (desig-list)
  (let* ((boolean (cl-transforms-stamped::make-msg "std_msgs/Bool" :data  (first desig-list)))
         (error-msg (cl-transforms-stamped::make-msg "std_msgs/String" :data  (second desig-list)))
         (action-msg (cl-transforms-stamped::make-msg "std_msgs/String" :data  (third desig-list)))
         (pose-msg (cl-transforms-stamped::to-msg (fourth desig-list))))
  ))

(defun designator-into-mhri-msg (desig)
 ;;  (format t "endlich gehts voranCDE------> ~a~%" desig) 
(let* ((combiner NIL)
       (msg NIL)
       (msg2 NIL))
  (cond ((equal 'cons (type-of desig))
         (setf combiner (make-array (length desig) :fill-pointer 0))
        ;; (format t "length of combiner ~a~%" (length combiner))
         (loop while (/=  (length desig) 0)
               do;;(format t "length ~a~%" (length desig))
                  (let*((descriptive (first desig))
                        (elem (desig:description descriptive))
                        (pose (second (assoc ':loc elem)))
                        (type (string (second (assoc ':type elem)))))
                      ;; (format t "pose is : ~a~%" pose)
                 ;;   (format t "pose is a : ~a~%" (cl-transforms-stamped::to-msg pose))
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
          ;;   (format t "pose is : ~a~%" pose)
          ;;    (format t "pose is a : ~a~%" (cl-transforms-stamped::to-msg pose))
             (setf str (cl-transforms-stamped::make-msg "std_msgs/String"
                                                        :data  type))
             (setf msg (vector (roslisp:make-message "mhri_msgs/interpretation"
                                             :type str
                                             :pose
                                             (slot-value (roslisp:call-service "myned2wgs_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg pose)) 'WORLD_MISSION-SRV:SUM)))))))
            ;;(cl-transforms-stamped::to-msg pose)))))))
  ;;(format t "ääääääHAAAAAALLOOOää +~a~%" msg)
  (setf msg2 (roslisp:make-message "mhri_msgs/multimodal"
                                   :action   msg))
  ;;(format t "new tests +~a~%" msg2)
    msg2))

