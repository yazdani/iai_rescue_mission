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
        






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (defun check-if-gesture-collides-with-obj-in-list (gesture)
;;   (getting-all-objs-closeto-human-as-list 4)
;;   (let*((liiist NIL))
;;     (loop for i in '(1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10
;;                      10.5 11 11.5 12 12.5 13 13.5 14 14.5 15 15.5 16)
;;           do (setf liiist
;;                    (append (list (list (test-function i gesture))))))
;;     liiist))

;; (defun test-function (i gesture)
;;   (format t "i ~a~%" i)
;;   (list-length *liste-pose*)
;;     (loop for jo from 0 to (- (list-length *liste-pose*) 1)
;;           do (format t "jo ~a~%" jo)
;;              (cond((equal (get-gesture-plane gesture i
;;                                              (cl-transforms:z
;;                                               (car (nthcdr jo *liste-dim*)))
;;                                              (cl-transforms:origin (car (nthcdr jo *liste-pose*)))) 0) (format t "nix"))
;;                 (t (return (car (nthcdr jo *liste-name*)))))))


;; (defun func-for-obj-equation (obj-vector dim-z)
;;   (format t "func-for")
;;   (let*((obj-x (cl-transforms:x obj-vector))
;;         (obj-y (cl-transforms:y obj-vector))
;;         (obj-z (cl-transforms:z obj-vector))
;;         (sec-x (- (cl-transforms:x obj-vector) 1))
;;         (sec-y (- (cl-transforms:y obj-vector) 1))
;;         (sec-z (+ (cl-transforms:z obj-vector) dim-z)))
;;     (cl-transforms:make-3d-vector (- sec-x obj-x) (- sec-y obj-y) (- sec-z obj-z)))) 
        
;; ;; Return the normal vector for the plane                    
;; (defun get-gesture-plane (gesture-vector param z-dimension obj-vector)
;; (format t "get gesture")
;;   (let*((A-point (cl-transforms:make-3d-vector (* (cl-transforms:x gesture-vector) param)
;;                                                (* (cl-transforms:y gesture-vector) param)
;;                                                (* (cl-transforms:z gesture-vector) param)))
;;         (B-point (cl-transforms:make-3d-vector (* (cl-transforms:x gesture-vector) param)
;;                                                (- (* (cl-transforms:y gesture-vector) param) param)
;;                                                (* (cl-transforms:z gesture-vector) param)))
;;         (first-vec (cl-transforms:make-3d-vector (- (cl-transforms:x gesture-vector)
;;                                                     (cl-transforms:x A-point))
;;                                                  (- (cl-transforms:y gesture-vector)
;;                                                     (cl-transforms:y A-point))
;;                                                  (- (cl-transforms:z gesture-vector)
;;                                                     (cl-transforms:z A-point))))
;;         (second-vec (cl-transforms:make-3d-vector (- (cl-transforms:x gesture-vector)
;;                                                     (cl-transforms:x B-point))
;;                                                  (- (cl-transforms:y gesture-vector)
;;                                                     (cl-transforms:y B-point))
;;                                                  (- (cl-transforms:z gesture-vector)
;;                                                     (cl-transforms:z B-point)))))
;;     (format t "hallo")
;;     (+ (get-value-of-normal-vector-rightSide (get-normal-vector first-vec second-vec) A-point)

;;       (get-value-of-normal-vector-leftside (get-normal-vector first-vec second-vec)
;;                                             (func-for-obj-equation obj-vector z-dimension)))))

;;   (defun get-value-of-normal-vector-leftSide (n-vector equation)
;; (format t "get-value-of")
;; (let*((n1 (cl-transforms:x n-vector))
;;         (n2 (cl-transforms:y n-vector))
;;         (n3 (cl-transforms:z n-vector))
;;         (e1 (cl-transforms:x equation))
;;         (e2 (cl-transforms:y equation))
;;         (e3 (cl-transforms:z equation))
;;         (n-e-value (+ (+ (* e1 n1) (* e2 n2)) (* e3 n3))))
;;     n-e-value))

;; (defun get-value-of-normal-vector-rightSide (n-vector A-point)
;; (format t "get value of right")
;;   (let*((n1 (cl-transforms:x n-vector))
;;         (n2 (cl-transforms:y n-vector))
;;         (n3 (cl-transforms:z n-vector))
;;         (a1 (cl-transforms:x A-point))
;;         (a2 (cl-transforms:y A-point))
;;         (a3 (cl-transforms:z A-point))
;;         (n-a-value (- (+ (+ (* a1 n1) (* a2 n2)) (* a3 n3)))))
;;     n-a-value))

;; (defun check-intersection-point (n-vector e-vector)
;; (format t "check inter" )
;;   (let*((x (* (cl-transforms:x n-vector) (cl-transforms:x e-vector)))
;;          (y (* (cl-transforms:y n-vector) (cl-transforms:y e-vector)))
;;          (z (* (cl-transforms:z n-vector) (cl-transforms:z e-vector))))
;;      (+ (+ x y) z)))

;; (defun get-normal-vector (first-vec second-vec)
;; (format t "get vector")
;;   (let*((normal-vec (cl-transforms:make-3d-vector
;;                        (- (* (cl-transforms:y first-vec)
;;                              (cl-transforms:z second-vec))
;;                           (* (cl-transforms:z first-vec)
;;                              (cl-transforms:y second-vec)))
;;                        (- (* (cl-transforms:z first-vec)
;;                              (cl-transforms:x second-vec))
;;                           (* (cl-transforms:x first-vec)
;;                              (cl-transforms:z second-vec)))
;;                        (- (* (cl-transforms:x first-vec)
;;                              (cl-transforms:y second-vec))
;;                           (* (cl-transforms:y first-vec)
;;                              (cl-transforms:x second-vec))))))
;;       normal-vec))


;; ;; (defun get-direction-vector (dimension-z)
;; ;;   (cl-transforms:make-3d-vector 0 0 dimension-z))


;; ;; (defun check-intersection-point (n-vector e-vector)
;; ;;   (let*((x (* (cl-transforms:x n-vector) (cl-transforms:x e-vector)))
;; ;;         (y (* (cl-transforms:y n-vector) (cl-transforms:y e-vector)))
;; ;;         (z (* (cl-transforms:z n-vector) (cl-transforms:z e-vector))))
;; ;;     (+ (+ x y) z)))

;; ;; (defun get-value-of-normal-vector-leftSide (n-vector equation)
;; ;;   (let*((n1 (cl-transforms:x n-vector))
;; ;;         (n2 (cl-transforms:y n-vector))
;; ;;         (n3 (cl-transforms:z n-vector))
;; ;;         (e1 (cl-transforms:x equation))
;; ;;         (e2 (cl-transforms:y equation))
;; ;;         (e3 (cl-transforms:z equation))
;; ;;         (n-e-value (+ (+ (* e1 n1) (* e2 n2)) (* e3 n3))))
;; ;;     n-e-value))


;; ;; (defun get-value-of-normal-vector-rightSide (n-vector A-point)
;; ;;   (let*((n1 (cl-transforms:x n-vector))
;; ;;         (n2 (cl-transforms:y n-vector))
;; ;;         (n3 (cl-transforms:z n-vector))
;; ;;         (a1 (cl-transforms:x A-point))
;; ;;         (a2 (cl-transforms:y A-point))
;; ;;         (a3 (cl-transforms:z A-point))
;; ;;         (n-a-value (- (+ (+ (* a1 n1) (* a2 n2)) (* a3 n3)))))
;; ;;     n-a-value))

;; ;;(defun is-obj-in-plane (plane obj-pose)
;; ;; (let*((
    
    
;; ;;(defun create-plane-of-genius-pose (width)  
;; ;;  (let*((pose (cl-transforms:origin (get-genius-pose->world-model "genius_link")))
;; ;;        (o-point (cl-transforms:make-3d-vector (- (cl-transforms:x pose) 3)
;; ;;                                               (cl-transforms:y pose)
;; ;;                                               (+ (cl-transforms:z pose) 1)))
;; ;;        (a-point (cl-transforms:make-3d-vector (+ (cl-transforms:x pose) width)
;; ;;                                               (+ (cl-transforms:y pose) width)
;; ;;                                               (+ (cl-transforms:z pose) 1)))
;; ;;        (b-point (cl-transforms:make-3d-vector (+ (cl-transforms:x pose) width)
;; ;;                                               (- (cl-transforms:y pose) width)
;; ;;                                               (+ (cl-transforms:z pose) 1)))
;; ;;        (dir-vec1 (cl-transforms:make-3d-vector (- (cl-transforms:x a-point)
;; ;;                                               (cl-transforms:x o-point))
;; ;;                                            (- (cl-transforms:y a-point)
;; ;;                                               (cl-transforms:y o-point))
;; ;;                                            (- (cl-transforms:z a-point)
;; ;;                                               (cl-transforms:z o-point))))
;; ;;        (dir-vec2 (cl-transforms:make-3d-vector (- (cl-transforms:x b-point)
;; ;;                                               (cl-transforms:x o-point))
;; ;;                                            (- (cl-transforms:y b-point)
;; ;;                                               (cl-transforms:y o-point))
;; ;;                                             (- (cl-transforms:z b-point)
;; ;;                                                (cl-transforms:z o-point))))    
;; ;;        (normal-vec (cl-transforms:make-3d-vector (- (* (cl-transforms:y dir-vec1)
;; ;;                                                        (cl-transforms:z dir-vec2))
;; ;;                                                     (* (cl-transforms:z dir-vec1)
;; ;;                                                        (cl-transforms:y dir-vec2)))
;; ;;                                                  (- (* (cl-transforms:z dir-vec1)
;; ;;                                                        (cl-transforms:x dir-vec2))
;; ;;                                                     (* (cl-transforms:x dir-vec1)
;; ;;                                                        (cl-transforms:z dir-vec2)))
;; ;;                                                  (- (* (cl-transforms:x dir-vec1)
;; ;;                                                        (cl-transforms:y dir-vec2))
;; ;;                                                     (* (cl-transforms:y dir-vec1)
;; ;;                                                        (cl-transforms:x dir-vec2))))))
;; ;;     (format t "vecs ~a ~a~%" dir-vec1 dir-vec2)
;; ;;    (format t "points ~a ~a ~a~%" o-point a-point b-point)
;; ;;    (format t "normal-vec ~a~%" normal-vec)))


;; ;; This method returns three differents lists which stores the different values and  ;; distinguish them into names, poses and dimensions. It return a completed list with
;; ;; a combination of all these different lists
;; (defun getting-all-objs-closeTo-human-as-list (distance)
;;   (let*((sem-hash (slot-value (sem-map-utils:get-semantic-map) 'sem-map-utils:parts))
;;         (liste-name NIL)
;;         (liste-pose NIL)
;;         (liste-dim NIL)
;;         (list-all NIL)
;;         (position (get-genius-pose->world-model "genius_link"))
;;         (keys (hash-keys sem-hash)))
;;     (loop for i in keys
;;           do (cond ((and T (compare-distance-with-genius-position position
;;                                                                 (slot-value (gethash i sem-hash) 'sem-map-utils:pose) distance))
;;                     (setf liste-name (append liste-name
              
;;                                        (list i)))
;;                     (setf liste-pose (append liste-pose
                                 
;;                                        (list 
;;                                              (slot-value (gethash i sem-hash) 'sem-map-utils:pose))))

;;                     (setf liste-dim (append liste-dim
;;                                         (list 
;;                                              (slot-value (gethash i sem-hash) 'sem-map-utils:dimensions))))
;;                     (setf list-all (append list-all
;;                                             (list
;;                                              (list i 
;;                                               (slot-value (gethash i sem-hash) 'sem-map-utils:pose)
;;                                               (slot-value (gethash i sem-hash) 'sem-map-utils:dimensions))))))
;;                    (t (format t ""))))
;;     (setf *liste-dim* liste-dim)
;;     (setf *liste-pose* liste-pose)
;;     (setf *liste-name* liste-name)
;;     list-all))
                           
        
;; (defun hash-keys (hash-table)
;;   (loop for key being the hash-keys of hash-table collect key))

;; (defun compare-distance-with-genius-position (genius_position pose param)
;;   (let*((vector (cl-transforms:origin pose))
;;         (x-vec (cl-transforms:x vector))
;;         (y-vec (cl-transforms:y vector))
;;         (ge-vector (cl-transforms:origin genius_position))
;;         (x-ge (cl-transforms:x ge-vector))
;;         (y-ge (cl-transforms:y ge-vector))
;;         (test NIL))
;;     (if (or (and (> param (- x-vec x-ge))
;;                  (> param (- y-vec y-ge)))
;;             (and (> (- param) (- x-vec x-ge))
;;                  (> (- param) (- y-vec y-ge))))
;;      (setf test T)
;;      (setf test NIL))
;;     test))
  
;; ;; (defun compare-objs-with-gesture (liste)
;; ;;   (format t "we will create now of each obj inside the list a level and afterwards compare it with the level given by the human direction. ~a~%" liste))
      
