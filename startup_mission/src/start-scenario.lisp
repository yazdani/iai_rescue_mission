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
;;(defun get-world-entities ()
;; (roslisp:call-service "/gazebo/get_world_properties" 'gazebo_msgs-srv:getworldproperties))

(defun get-urdf-map ()
   (cl-urdf:parse-urdf (roslisp:get-param "mountain_description")))

(defun start-world-with-robot ()
  (roslisp:ros-info (sherpa-mission) "START WORLD!")
 ;; (setf cram-transforms-stamped:*tf-default-timeout* 0)
  (setf *list* nil)
  (let* ((sem-urdf (cl-urdf:parse-urdf (roslisp:get-param "mountain_description"))))
        ;; (quad01-urdf (cl-urdf:parse-urdf (roslisp:get-param "robot_description"))))
    (roslisp:ros-info (sherpa-mission) "START WORLD!")
    (setf *list*
          (car 
           (btr::force-ll
            (btr::prolog
             `(and
               (clear-bullet-world)
               (bullet-world ?w)
               (cram-robot-interfaces::robot  ?robot)
               (assert (object ?w :static-plane floor ((0 0 0) (0 0 0 1))
                               :normal (0 0 1) :constant 0 :disable-collisions-with (?robot)))
               (debug-window ?w)
               (assert (object ?w :semantic-map sem-map ((0 0 0) (0 0 0 1)) :urdf ,sem-urdf)))))))))


;;(defun get-frame ()
;;  (instruct-mission::init-base)
;;  (let*((msg (instruct-mission::content instruct-mission::*stored-result*))
;;        (trans-stamped (cl-tf:tf-msg->transforms msg)))
;;    trans-stamped))
    
        
            ;;  (assert (object ?w :urdf quadrotor01 ((22 0 0)(0 0 0 1)) :urdf ,quad01-urdf))
             ;;(btr::robot quadrotor01))))))))


(defun create-desig-as-tester( obj1-name obj2-name)
;  (let* ((map (sem-map-utils::get-semantic-map)))
       ;;  (obj1-part (sem-map-utils::semantic-map-part map obj1-name))
      ;;   (obj2-part (sem-map-utils::semantic-map-part map obj2-name))
      ;;   (obj1-pose (slot-value obj1-part 'sem-map-utils:pose))
    ;;     (obj2-pose (slot-value obj2-part 'sem-map-utils:pose)))
    (make-designator :location `((:behind-of ,obj1-name)
                                 (:next-to ,obj2-name))))

(defun create-action-desig1 ()
  (if (string-equal (instruct-mission::get-item) "")
      (make-designator :action `((agent ,(instruct-mission::get-agent))
                                 (cmd-type ,(instruct-mission::get-cmd-type))
                                 (action ,(instruct-mission::get-action))
                                 (:loc ,(instruct-mission::get-direction))))
      (make-designator :action `((agent ,(instruct-mission::get-agent))
                                 (cmd-type ,(instruct-mission::get-cmd-type))
                                 (action ,(instruct-mission::get-action))
                                 (:loc ,(make-designator :location `((,(instruct-mission::get-direction) ,(instruct-mission::get-location)))))))))


(defun spawn-object()
  (roslisp:ros-info (sherpa-mission) "landmarks!")
  (btr::prolog
   `(and
     (bullet-world ?w)
     (assert (object ?w :mesh victim ((-3.57 0 0) (0 0 0 1)) ;; (1 0 0)red
                     :mesh :victim
                     :color (1 0 0)  :mass 2)))))

(defun spawn-pose()
  (btr::prolog
   `(and
     (bullet-world ?w)
     (assert (object ?w :mesh genius04 ((16 0 0) (0 0 -1 1)) ;; (1 0 0)red
                     :mesh :genius :color (0 0 0)  :mass 2)))))

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
 ;;(make-object-desig 'quadrotor01 'col03 'jacket02)
  )
;;(prolog `(and (bullet-world ?w) (assert (object ?w :mesh tanne ((-6.4 -3 0) (0 0 0 1))
         ;;            :mesh :tanne :color (1 0 0)  :mass 3))))
;(defun make-object-desig (quadrotor env-obj manmade-obj)
 ;   (let* ((liste (force-ll (prolog `(and (bullet-world ?w)
  ;                                     (contact ?w sem-map ,env-obj ?link)))))
   ;        (urdf-map (object *current-bullet-world* 'sem-map))
    ;       (hash-table (btr:links urdf-map))
     ;      (link (cdadar liste))
    ;       (obj-pose (pose (gethash link hash-table))))
   ;   (setf *obj-pose* obj-pose)
   ; (make-designator :location `(;(agent ,quadrotor)
    ;                             (rightOf ,obj-pose)
     ;                            (lookFor ,manmade-obj)))))



;;; INTERPRETATION OF INSTRUCTION ;;;

;; (defun parse-cmd-into-designator ()
;;   ;;query 
;;   (let* ((cntnt (instruct-mission::content instruct-mission::*stored-result*))
;;          (agent (read-from-string (substitute #\- #\Space (slot-value cntnt 'instruct_mission-msg::agent))))
;;          (cmd (coerce (slot-value cntnt 'instruct_mission-msg::command) 'string))
;;          (type (read-from-string (slot-value cntnt 'instruct_mission-msg::type)))
;;          (gesture (slot-value cntnt 'instruct_mission-msg::gesture))
;;          (ge-vector (cl-transforms::make-3d-vector (svref gesture 0)
;;                                                    (svref gesture 1)
;;                                                    (svref gesture 2)))         
;;          (gps (slot-value cntnt 'instruct_mission-msg::gps))
;;          (gps-vector (cl-transforms::make-3d-vector (svref gps 0)
;;                                                     (svref gps 1)
;;                                                     (svref gps 2)))
;;          (desig (func-designator type agent cmd))
;;          )
;;     ;; (make-designator :action `((:cmd-type ,type)
;;     ;;                            (:agent ,agent)
;;     ;;                            (:type move)
;;     ;;                            (:loc ,(make-designator :location `((...)
;;     ;;                                                                (:to :see)
;;     ;;                                                                (loc,,
;;     (format t "cmd: ~a~% agent: ~a~% type: ~a~% gesture: ~a~% ge-vector: ~a~% gps: ~a~% gps-vector: ~a~%" cmd agent type gesture ge-vector gps gps-vector)
;;     cmd)) 

;; (defun func-designator (action-type agent cmd)
;;   )
                       
                  




;;;;;;;;;;;;;PROJECTION;;;;;;;;;;;;;;
;;(cpl-impl:def-cram-function detect-obj-jacket (jacket-obj-desig)
;; (cram-language-designator-support:with-designators
  ;;   ((left-side :location `((rightOf *obj-pose*)
    ;;                        (lookFor ,jacket-obj-desig))))
;;  (cpl-impl:top-level                   ;
  ;;  (cram-projection:with-projection-environment
    ;;    projection-process-modules::quadrotor-bullet-projection-environment
     ;;  (let ((obj (find-object type)))
;; obj))))


;; (defun func*()
;;   (let* ((liste (force-ll (prolog `(and (bullet-world ?w)
;;                                         (contact ?w sem-map col03 ?link)))))
;;          (urdf-map (object *current-bullet-world* 'sem-map))
;;          (hash-table (btr:links urdf-map))
;;          (link (cdadar liste))
;;          (obj-pose (pose (gethash link hash-table)))
;;          (loc  (make-designator :location `((rightOf ,obj-pose))))                                    
;;          (obj (make-designator :object `((:name jacket02)
;;                                          (:type cram-bullet-reasoning::manmade-object)
;;                                          (:at ,loc))))) obj))                    
;; (defun check-pointed-gesture-and-give-position (gesture-vector)
;;   (let* ((liste (getting-all-objs-closeto-human-as-list 4))
         
;;         (test (+
;;                (+ (* (cl-transforms:x n-vector) (cl-transforms:x derPunkt))
;;                   (* (cl-transforms:y n-vector) (cl-transforms:y derPunkt))
;;                   (* (cl-trransforms:z n-vector) (cl-transforms_z derPunkt)))
;;                (+ (- (* (cl-transforms:x n-vector) (cl-transforms:x A-point)))
;;                   (- (* (cl-transforms:y n-vector) (cl-transforms:y A-point)))
;;                   (- (* (cl-transforms:z n-vector) (cl-transforms:z A-point))))))
        






