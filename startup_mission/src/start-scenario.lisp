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

(defun start-world ()
  (roslisp:ros-info (sherpa-mission) "START WORLD!")
 ;; (roslisp-utilities:startup-ros)
  (setf *list* nil)
  (let* ((sem-urdf (cl-urdf:parse-urdf (roslisp:get-param "area_description")))
         (quad01-urdf (cl-urdf:parse-urdf (roslisp:get-param "robot_description01")))
         (quad02-urdf (cl-urdf:parse-urdf (roslisp:get-param "robot_description02")))
        ;; (human-urdf (cl-urdf:parse-urdf (roslisp:get-param "human_description")))
         )
    (setf *list*
          (car 
           (btr::force-ll
            (btr::prolog
             `(and
               (clear-bullet-world)
               (bullet-world ?w)
               (btr::robot ?robot)
               (assert (object ?w :static-plane floor ((0 0 0) (0 0 0 1))
                               :normal (0 0 1) :constant 0 :disable-collisions-with (?robot)))
               (debug-window ?w)
              (assert (object ?w :semantic-map sem-map ((0 0 0) (0 0 0 1)) :urdf ,sem-urdf))
              
              (assert (object ?w :urdf quadrotor01 ((2 -11 1)(0 0 0 1)) :urdf ,quad01-urdf))
             
             
              (assert (object ?w :urdf quadrotor02 ((3 -11 2)(0 0 0 1)) :urdf ,quad02-urdf))
               (btr::robot quadrotor01)
               (btr::robot quadrotor02)
              ;;  (assert (object ?w :urdf human ((0 -13 0)(0 0 -4 1)) :urdf ,human-urdf))
               (assert (object ?w :mesh mountainarea ((2 -10 0) (0 0 -1 1))
                     :mesh :berg :color (0.7 0.7 0.7)  :mass 2))
             )))))))

(defun spawn-manmade-objects()
  (roslisp:ros-info (sherpa-mission) "Add landmarks!")
  (btr::prolog
   `(and
     (bullet-world ?w)
     (assert (object ?w :mesh jacket01 ((-3 2 0) (0 0 0 1)) ;; (1 0 0)red
                     :mesh :jacket :color (1 0 0)  :mass 2))
     (assert (object ?w :mesh capt01 ((5.5 3.7 0) (0 0 0 1)) ;; (1 0 0)red
                     :mesh :cap :color (0 0 1)  :mass 2))
     (assert (object ?w :mesh jacket02 ((-8.5 -3 0) (0 0 0 1)) ;;(0 0 1)blue
                      :mesh :jacket :color (0 0 1)  :mass 2)))))

(defun spawn-cone-and-manmade-object()
   (btr::prolog
   `(and
     (bullet-world ?w)
     (assert (object ?w :mesh jacket03
                     ((-7 -8 0) (0 0 0 1)) 
                     :mesh :jacket :color (1 0 0)  :mass 2))
     (assert (object ?w :mesh cone ((-2.5 -10.3 -0.5) (0.1 0 -2.2 1))
                     :mesh :cone :color (0.5 0.4 0.7)  :mass 2)))))
(defun add-pointers()
  (roslisp:ros-info (sherpa-mission) "Add pointer!")
  (btr::prolog
   `(and
     (bullet-world ?w)
     (assert (object ?w :sphere col01 ((-1.5 -1.5 3) (0 0 0 1)) ;;blue--right-of
                     :color (1 0 1)  :mass 0.2 :radius 0.2))
     (assert (object ?w :sphere col02 ((3 -0.2 3) (0 0 0 1)) ;;yellow
                     :color (1 0 1)  :mass 0.2 :radius 0.2))
      (assert (object ?w :sphere col03 ((-5.2 -3.5 3) (0 0 0 1)) ;;red
                      :color (1 0 1)  :mass 0.2 :radius 0.2))))
 (make-object-desig 'quadrotor01 'col03 'jacket02)
  )
;;(prolog `(and (bullet-world ?w) (assert (object ?w :mesh tanne ((-6.4 -3 0) (0 0 0 1))
         ;;            :mesh :tanne :color (1 0 0)  :mass 3))))
(defun make-object-desig (quadrotor env-obj manmade-obj)
    (let* ((liste (force-ll (prolog `(and (bullet-world ?w)
                                       (contact ?w sem-map ,env-obj ?link)))))
           (urdf-map (object *current-bullet-world* 'sem-map))
           (hash-table (btr:links urdf-map))
           (link (cdadar liste))
           (obj-pose (pose (gethash link hash-table))))
      (setf *obj-pose* obj-pose)
    (make-designator :location `(;(agent ,quadrotor)
                                 (rightOf ,obj-pose)
                                 (lookFor ,manmade-obj)))))
;;;;;;;;;;;;;PROJECTION;;;;;;;;;;;;;;
(cpl-impl:def-cram-function detect-obj-jacket (jacket-obj-desig)
;; (cram-language-designator-support:with-designators
  ;;   ((left-side :location `((rightOf *obj-pose*)
    ;;                        (lookFor ,jacket-obj-desig))))
  (cpl-impl:top-level
    (cram-projection:with-projection-environment
        projection-process-modules::quadrotor-bullet-projection-environment
       (let ((obj (find-object type)))
 obj))))

(defun func*()
  (let* ((liste (force-ll (prolog `(and (bullet-world ?w)
                                        (contact ?w sem-map col03 ?link)))))
         (urdf-map (object *current-bullet-world* 'sem-map))
         (hash-table (btr:links urdf-map))
         (link (cdadar liste))
         (obj-pose (pose (gethash link hash-table)))
         (loc  (make-designator :location `((rightOf ,obj-pose))))                                    
         (obj (make-designator :object `((:name jacket02)
                                         (:type cram-bullet-reasoning::manmade-object)
                                         (:at ,loc))))) obj))                                           
