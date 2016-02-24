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

(defvar *swm-bbx* NIL)
(defvar *swm-pose* NIL)
(defparameter *swm-liste* NIL)

(defun swm->get-geopose-agent (agent)
  (let* ((array (json-prolog:prolog  `("swm_AgentsData" ,agent ?agent)))
         (str-pose (symbol-name (cdaar array)))
         (seq (cddr (split-sequence:split-sequence #\[ str-pose)))
         (a-seq (first (split-sequence:split-sequence #\] (first seq))))
         (b-seq (first (split-sequence:split-sequence #\] (second seq))))
         (a-nums (split-sequence:split-sequence #\, a-seq))
         (b-nums (split-sequence:split-sequence #\, b-seq)))
    (format t "(typeof) ~a and ~a ~%" b-nums a-nums)
        (cl-transforms:make-pose (cl-transforms:make-3d-vector
                                        (read-from-string (first a-nums))
                                        (read-from-string (second a-nums))
                                        (read-from-string (third a-nums)))
                                       (cl-transforms:make-quaternion
                                        (read-from-string (first b-nums))
                                        (read-from-string (second b-nums))
                                        (read-from-string (third b-nums))
                                        (read-from-string (fourth b-nums))))))

(defun swm->get-cartesian-pose-agent (agent)
  (let* ((pose (swm->get-geopose-agent agent)) ;;(cl-transforms:make-pose (cl-transforms:make-3d-vector 44.1533088684 12.2414226532 42.7000007629) (cl-transforms:make-quaternion 0 0 0 1))) ;;(swm->get-geopose-agent agent))
        (call (roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg pose))))
   (splitgeometry->pose call)))

(defun swm->elem-name->position (name)
  (format t "swm->elem-name->position~%")
 (let*((pose NIL)
       (liste (swm->geopose-elements)))
   (format t "~a name is~%" name)
   (format t "~a liste is~%" liste)
                   (loop for i from 0 to (- (length liste) 1)
                         do(cond ((and (string-equal name (car (nth i liste)))
                                       (equal pose NIL))
                                  (setf pose (third (nth i liste))))
                                 (t (format t "Didn't found position~%"))))
                   pose))

(defun swm->elem-name->type (name)
 (let*((pose NIL)
       (liste (swm->geopose-elements)))
                   (loop for i from 0 to (length liste)
                         do(cond ((string-equal name (car (nth i liste)))
                                (setf pose (second (nth i liste))))
                               (t (format t "Didn't found type~%"))))
                   pose))

(defun swm->geopose-elements ()
  (setf *swm-liste* NIL)
  (format t "inside geoposes collection~%")
  (let* ((array (json-prolog:prolog `("swm_EntitiesData" ?A)))
          (comp (symbol-name (cdaar array)))
          (seq  (split-sequence:split-sequence #\( comp))
          (a-seq (cddr seq)))
    (format t "inside geoposes collection2~%")
 (loop for i from 0 to  (length a-seq)
       do (cond ((not (equal (length a-seq) 0))
                 (setf *swm-liste* (append *swm-liste* (list (internal-function (car a-seq)))))
                 (setf a-seq (cdr a-seq)))))
    *swm-liste*))

(defun internal-function(tmp)
  (format t "tmp ~a~%" tmp)
  (let*((seq (split-sequence:split-sequence #\, (car (split-sequence:split-sequence #\) tmp))))
        (seq-name (car seq))
        (seq-type (second seq))
        (tmp (cddr seq))
        (c1 (third (split-sequence:split-sequence #\[ (car tmp))))
        (c2 (second tmp))
        (c3 (car (split-sequence:split-sequence #\] (third tmp))))
        (q1 (second (split-sequence:split-sequence #\[ (fourth tmp))))
        (q2 (first (cddddr tmp)))
        (q3 (second (cddddr tmp)))
        (q4 (car (split-sequence:split-sequence #\] (third (cddddr tmp)))))
        (center (cl-transforms:make-pose (cl-transforms:make-3d-vector (read-from-string c1) (read-from-string c2) (read-from-string c3))
                             (cl-transforms:make-quaternion (read-from-string q1) (read-from-string q2) (read-from-string q3) (read-from-string q4))))
   (tmp (cdddr (cddddr tmp)))
         (b1 (third (split-sequence:split-sequence #\[ (car tmp))))
        (b2 (second tmp))
        (b3 (car (split-sequence:split-sequence #\] (third tmp))))
        (bq1 (second (split-sequence:split-sequence #\[ (fourth tmp))))
        (bq2 (first (cddddr tmp)))
        (bq3 (second (cddddr tmp)))
        (bq4 (car (split-sequence:split-sequence #\] (third (cddddr tmp)))))
        (bbox1 (cl-transforms:make-pose (cl-transforms:make-3d-vector (read-from-string b1) (read-from-string b2) (read-from-string b3))
                             (cl-transforms:make-quaternion (read-from-string bq1) (read-from-string bq2) (read-from-string bq3) (read-from-string bq4))))
        (tmp (cdddr (cddddr tmp)))
        (bb1 (third (split-sequence:split-sequence #\[ (car tmp))))
        (bb2 (second tmp))
        (bb3 (car (split-sequence:split-sequence #\] (third tmp))))
        (bbq1 (second (split-sequence:split-sequence #\[ (fourth tmp))))
        (bbq2 (first (cddddr tmp)))
        (bbq3 (second (cddddr tmp)))
        (bbq4 (car (split-sequence:split-sequence #\] (third (cddddr tmp)))))
        (bbox2 (cl-transforms:make-pose (cl-transforms:make-3d-vector
                                         (read-from-string bb1)
                                         (read-from-string bb2)
                                         (read-from-string bb3))
                                        (cl-transforms:make-quaternion
                                         (read-from-string bbq1)
                                         (read-from-string bbq2)
                                         (read-from-string bbq3)
                                         (read-from-string bbq4)))))
    (list seq-name seq-type 
          (splitgeometry->pose (roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg  center)))
          (splitgeometry->pose(roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg  bbox1)))
          (splitgeometry->pose(roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg  bbox2))))))
        

(defun splitGeometry->pose (test)
  (let* ((sum (slot-value test 'WORLD_MISSION-SRV:SUM))
         (position (slot-value sum 'GEOMETRY_MSGS-MSG:POSITION))
         (ori-x (slot-value position 'GEOMETRY_MSGS-MSG:X))
         (ori-y (slot-value position 'GEOMETRY_MSGS-MSG:Y))
         (ori-z (slot-value position 'GEOMETRY_MSGS-MSG:Z))
         (orientation (slot-value sum 'GEOMETRY_MSGS-MSG:ORIENTATION))
         (qua-x (slot-value orientation 'GEOMETRY_MSGS-MSG:X))
         (qua-y (slot-value orientation 'GEOMETRY_MSGS-MSG:Y))
         (qua-z (slot-value orientation 'GEOMETRY_MSGS-MSG:Z))
         (qua-w (slot-value orientation 'GEOMETRY_MSGS-MSG:W)))
    (cl-transforms:make-pose
     (cl-transforms:make-3d-vector ori-x ori-y ori-z)
     (cl-transforms:make-quaternion qua-x qua-y qua-z qua-w))))

(defun swm->publish-elements-tf ()
  (let*((elems (swm->geopose-elements))
        (pub (cl-tf:make-transform-broadcaster)))
    (loop for i from 0 to (- 1 (length elems))
          do(let*((frame-id (nth 0 (nth i elems)))
                  (ori (cl-transforms:origin (nth 1 (nth i elems))))
                  (qua (cl-transforms:orientation (nth 1 (nth i elems)))))
             (cl-tf:send-transforms pub (cl-transforms-stamped:make-transform-stamped "map"  frame-id (roslisp:ros-time) ori qua))))))
        
  
