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

(defvar *tf* NIL)
(defvar *pub* NIL)

(defun init-tf ()
  (setf *tf* (make-instance 'cl-tf:transform-listener))
  (setf *pub* (cl-tf:make-transform-broadcaster)))

(roslisp-utilities:register-ros-init-function init-tf)

(defun make-new-function-right (human-pose object-pose)
  (format t "object-pose ~a~%" object-pose)
  (let*((h-qz (cl-transforms:z (cl-transforms:orientation human-pose)))
         (h-qw (cl-transforms:w (cl-transforms:orientation human-pose)))
         (o-x (cl-transforms:x (cl-transforms:origin object-pose)))
         (o-y (cl-transforms:y (cl-transforms:origin object-pose)))
         (o-z (cl-transforms:z (cl-transforms:origin object-pose)))
         (pose NIL))
     (format t "hqz ~a und hqw ~a~%" h-qz h-qw)
     (cond((and (plusp h-qz)
                (plusp h-qw)
                (> 1.1 h-qw)
                (<= 0.5 h-qw))
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector (+ o-x 0.2) (- o-y 0.3) o-z)
                       (cl-transforms:orientation human-pose))))
           ((and (= 0 h-qz)
                  (= 1 h-qw))
             (format t "Entering~%")
            (setf pose (cl-transforms:make-pose
                        (cl-transforms:make-3d-vector (+ o-x 0.1) (- o-y 0.8) o-z)
                        (cl-transforms:orientation human-pose))))
          ((and (plusp h-qz)
                (> 0.5 h-qw))
           (format t "entering~%")
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector (+ o-x 0.3) (+ o-y 0.3) o-z)
                       (cl-transforms:orientation human-pose))))
          ((and (minusp h-qz)
                (plusp h-qw)
                (> 1.1 h-qw)
                (<= 0.5 h-qw))
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector (- o-x 0.5) (- o-y 0.5) o-z)
                       (cl-transforms:orientation human-pose))))
          ((and (minusp h-qz)
                (> 0.5 h-qw))
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector (- o-x 0.5) (+ o-y 0.5) o-z)
                       (cl-transforms:orientation human-pose))))
          (t (format t "Something went wrong in costfunction-right~%")))
    (format t "POSE IS ~a~%" pose)
    (set-my-marker pose 10000)
     pose))

(defun make-new-function-left (human-pose object-pose)
  (let*((h-qz (cl-transforms:z (cl-transforms:orientation human-pose)))
         (h-qw (cl-transforms:w (cl-transforms:orientation human-pose)))
         (o-x (cl-transforms:x (cl-transforms:origin object-pose)))
         (o-y (cl-transforms:y (cl-transforms:origin object-pose)))
         (o-z (cl-transforms:z (cl-transforms:origin object-pose)))
         (pose NIL))
     (format t "hqz ~a und hqw ~a~%" h-qz h-qw)
     (cond((and (plusp h-qz)
                (plusp h-qw)
                (> 1.1 h-qw)
                (<= 0.5 h-qw))
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector (- o-x 0.2) (+ o-y 0.3) o-z)
                       (cl-transforms:orientation human-pose))))
           ((and (= 0 h-qz)
                 (= 1 h-qw))
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector o-x (+ o-y 0.5) o-z)
                       (cl-transforms:orientation human-pose))))
          ((and (plusp h-qz)
                (> 0.5 h-qw))
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector (- o-x 0.3) (- o-y 0.3) o-z)
                       (cl-transforms:orientation human-pose))))
          ((and (minusp h-qz)
                (plusp h-qw)
                (> 1.1 h-qw)
                (<= 0.5 h-qw))
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector (+ o-x 0.5) (+ o-y 0.5) o-z)
                       (cl-transforms:orientation human-pose))))
          ((and (minusp h-qz)
                (> 0.5 h-qw))
           (setf pose (cl-transforms:make-pose
                       (cl-transforms:make-3d-vector (+ o-x 0.5) (- o-y 0.5) o-z)
                       (cl-transforms:orientation human-pose))))
          (t (format t "Something went wrong in costfunction-right~%")))
     pose))


;; wenn z rotation == 0
     
(defun make-reasoning-cost-function (location axis pred threshold)
  (roslisp:ros-info (sherpa-spatial-relations) "calculate the costmap")
  (let* ((new-loc (cl-transforms:make-pose
                   (cl-transforms:origin location)
                   (cl-transforms:make-identity-rotation)))
         (transformation (cl-transforms:pose->transform new-loc)) ;;location
         (world->location-transformation (cl-transforms:transform-inv transformation)))
    (lambda (x y)
      (let* ((point (cl-transforms:transform-point world->location-transformation
                                                   (cl-transforms:make-3d-vector x y 0)))
             (coord (ecase axis
                      (:x (cl-transforms:x point))
                      (:y (cl-transforms:y point))))
             (mode (sqrt (+   (* (cl-transforms:x point) (cl-transforms:x point))
                             (* (cl-transforms:y point) (cl-transforms:y point))))))
       ;; (format t "pred: ~a~% coord: ~a~%" pred coord)
        (if (funcall pred coord 0.0d0)
            (if (> (abs (/ coord mode)) threshold)
                (abs (/ coord mode))
                0.0d0)
            0.0d0)))))

(defun make-bb-height-function (obj-name height)
  (sem-map-utils::get-semantic-map)
  (let* ((sem-hash (slot-value semantic-map-utils::*cached-semantic-map* 'sem-map-utils:parts))
         (dim  (slot-value (gethash obj-name sem-hash) 'sem-map-utils:dimensions)))
    (setf height (/ (cl-transforms:z dim) 2))
    (if (< height 1)
	(setf height 1.5)
	(setf height height))
    (lambda (x y)
      (declare (ignore x y))
      (list height))))

(defun swm->make-height-human (pose height)
   (setf height (+ 1 4))
  (format t "inside human height~%")
  (lambda (x y)
    (declare (ignore x y))
    (list height)))

(defun swm->make-constant-height-function (obj-name height &optional (sem-map (swm->initialize-semantic-map)))
  (let* ((sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (dim  (slot-value (gethash obj-name sem-hash) 'sem-map-utils:dimensions)))
    (setf height  (+ (cl-transforms:z dim) 10));;0.5))
    (lambda (x y)
      (declare (ignore x y))
      (list height))))

(defun make-constant-height-function (obj-name height)
  (sem-map-utils::get-semantic-map)
  (let* ((sem-hash (slot-value semantic-map-utils::*cached-semantic-map* 'sem-map-utils:parts))
         (dim  (slot-value (gethash obj-name sem-hash) 'sem-map-utils:dimensions)))
    (setf height  (+ (cl-transforms:z dim) 1))
    (lambda (x y)
      (declare (ignore x y))
      (list height))))

(defun make-costmap-bbox-gen (objs &key invert padding)
(force-ll objs)
 ;;(format t "objs ~a jdjddsj~%" objs)
  (when objs
    (let ((aabbs (loop for obj in (cut:force-ll objs)
                       collecting (btr:aabb obj))))
      (lambda (x y)
        (block nil
          (dolist (bounding-box aabbs (if invert 1.0d0 0.0d0))
            (let* ((bb-center (cl-bullet:bounding-box-center bounding-box))
                   (dimensions-x/2
                     (+ (/ (cl-transforms:x (cl-bullet:bounding-box-dimensions bounding-box)) 2)
                        padding))
                   (dimensions-y/2
                     (+ (/ (cl-transforms:y (cl-bullet:bounding-box-dimensions bounding-box)) 2)
                        padding)))
              (when (and
                     (< x (+ (cl-transforms:x bb-center) dimensions-x/2))
                     (> x (- (cl-transforms:x bb-center) dimensions-x/2))
                     (< y (+ (cl-transforms:y bb-center) dimensions-y/2))
                     (> y (- (cl-transforms:y bb-center) dimensions-y/2)))
                (return (if invert 0.0d0 1.0d0)))))))))) 

(defun make-costmap-bbox-gen-obj (obj-name &key invert padding)
  (let*((sem-hash (slot-value semantic-map-utils::*cached-semantic-map* 'sem-map-utils:parts))
        (sem-obj (gethash obj-name sem-hash))
        (pose (slot-value sem-obj 'cram-semantic-map-utils:pose))
        (dim (slot-value sem-obj 'cram-semantic-map-utils:dimensions))
        (z/2-dim (/ (cl-transforms:z (slot-value sem-obj 'cram-semantic-map-utils:dimensions)) 2)))
    (lambda (a b)
      (block nil
        (let*((bb-center (cl-transforms:make-3d-vector 
                           (cl-transforms:x (cl-transforms:origin pose)) (cl-transforms:y (cl-transforms:origin pose)) (+ (cl-transforms:z (cl-transforms:origin pose)) z/2-dim)))
              (dim-x/2 (+ (/ (cl-transforms:x dim) 2) padding))
              (dim-y/2 (+ (/ (cl-transforms:y dim) 2) padding)))
          (format t "edli~%")
          (format t "x ~a and y~a~%" a b)
          (format t "bb-center ~a~%" bb-center)
          (format t "~a~%" (+ (cl-transforms:x bb-center) dim-x/2))
          (format t "~a~%" (+ (cl-transforms:x bb-center) dim-y/2))
          (when (and
                 (< a (+ (cl-transforms:x bb-center) dim-x/2))
                 (> a (- (cl-transforms:x bb-center) dim-x/2))
                 (< b (+ (cl-transforms:y bb-center) dim-y/2))
                 (> b (- (cl-transforms:y bb-center) dim-y/2)))
            (return (if invert 0.0d0 1.0d0))))))))

(defun make-location-cost-function (loc std-dev)
  (let ((loc (cl-transforms:origin loc)))
    (make-gauss-cost-function loc `((,(float (* std-dev std-dev) 0.0d0) 0.0d0)
                                    (0.0d0 ,(float (* std-dev std-dev)))))))

(defun get-sem-object-pose->map (object &optional (semantic-map (swm->initialize-semantic-map)));(sem-map-utils::get-semantic-map)))
  (let*((obj (sem-map-utils::semantic-map-part semantic-map object))
       (obj-pose (slot-value obj 'sem-map-utils:pose))
       (obj-pstamped (cl-transforms-stamped:ensure-pose-stamped
                      obj-pose "/map" 0.0)))
       (get-sem-object-transform->relative-map obj-pstamped)))

(defun get-sem-object-pose->genius (object &optional (semantic-map (sem-map-utils::get-semantic-map)))
  (let*((obj (sem-map-utils::semantic-map-part semantic-map object))
       (obj-pose (slot-value obj 'sem-map-utils:pose))
       (obj-pstamped (cl-transforms-stamped:ensure-pose-stamped
                      obj-pose "/map" 0.0)))
       (get-model-pose->relative-genius obj-pstamped)))

(defun get-genius-pose->map-frame (frame-id)
  (roslisp:ros-info (STARTUP-MISSION::cost-functions) "Get the position of the genius a link in relation with the world_frame")
 ;; (roslisp-utilities:startup-ros)
  (let((*tf* (make-instance 'cl-tf:transform-listener)))
    (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" frame-id :timeout 2.0))))
  ;;  (cl-transforms-stamped:transform->pose transform)))

(defun get-sem-object-transform->relative-map (obj-stamped)
  (roslisp:ros-info (STARTUP-MISSION::cost-functions) "Get the position of the object in relation with the map_frame")
 ;; (roslisp-utilities:startup-ros)
    (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose  *tf* :pose obj-stamped :target-frame "map")))
                                                          
(defun get-model-pose->relative-genius (obj-pst)
  (roslisp:ros-info (STARTUP-MISSION::cost-functions) "Get the position of a link in relation with the world_frame")
 ;; (roslisp-utilities:startup-ros)
     (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose  *tf* :pose obj-pst :target-frame "genius_link")))

(defun semantic-map->geom-object (geom-objects object-name)
(let*((geom-list geom-objects)
      (object NIL))
  (loop while (and (/= (length geom-list) 0) (equal object NIL))
	do(cond ((string-equal (slot-value (car geom-list) 'sem-map-utils:name) object-name)
		 (setf object (car geom-list)))
		(t (setf geom-list (cdr geom-list)))))
(list object)))


(defun get-gesture->relative-genius (gesture-vec) 
  (let*((pose (cl-transforms-stamped:make-pose-stamped "genius_link" 0.0
                                                        gesture-vec
                                                        (cl-transforms:make-quaternion 0 0 -1 1))))
    (cl-transforms-stamped:pose-stamped->pose  (cl-tf:transform-pose *tf* :pose pose :target-frame "map"))))


(defun semantic-map->geom-objects (geom-objects param object-pose)
;;  (format t "method semantic map ~a ~%" geom-objects)
(let*((geom-list geom-objects)
      (objects NIL))
  (loop while (/= (length geom-list) 0) 
	do;;(format t "inital ~a~%" geom-list)
     (cond ((and T
                (compare-distance-of-objects (slot-value (car geom-list) 'sem-map-utils:pose) object-pose param))
      ;;      (format t "tester ~a~%" geom-list)
		 (setf objects
           (append objects (list (first geom-list))))
            (setf geom-list (cdr geom-list)))
          (t (setf geom-list (cdr geom-list)))))
 ;; (format t "und objects sind ~a~%" objects)
objects))

(defun compare-distance-of-objects (genius_position pose param)
  (let*((vector (cl-transforms:origin pose))
        (x-vec (cl-transforms:x vector))
        (y-vec (cl-transforms:y vector))
        (z-vec (cl-transforms:z vector))
        (ge-vector (cl-transforms:origin genius_position))
        (x-ge (cl-transforms:x ge-vector))
        (y-ge (cl-transforms:y ge-vector))
        (z-ge (cl-transforms:z ge-vector))
        (test NIL))
    (if (> param (sqrt (+ (square (- x-vec x-ge))
                          (square (- y-vec y-ge))
                          (square (- z-vec z-ge)))))
     (setf test T)
     (setf test NIL))
    test))

;; spatial reasoning functions for right, left, behindin-front-of and next

(defun preposition-right (human-pose)
  (let*((pred NIL)
        (axis NIL)
        (h-qz (cl-transforms:z (cl-transforms:orientation human-pose)))
        (h-qw (cl-transforms:w (cl-transforms:orientation human-pose))))

        (cond ((>= h-qw 0.8)
               (setf pred '<)
               (setf axis :Y))
              ((and(< h-qw 0.8)
                   (>= h-qw 0.19)
                   (plusp h-qz))
               (setf pred '>)
               (setf axis :X))
              ((and (< h-qw 0.19)
                    (>= h-qw -0.1))
               (setf pred '>)
               (setf axis :Y))
              ((or (< h-qw -0.1)
                   (minusp h-qz))
               (setf pred '<)
               (setf axis :X))
              (t (format t "Something went wrong inside preposition right~%")
                 (setf pred '<)
                 (setf axis :Y)))
    (list axis pred)))

(defun preposition-left (human-pose)
  (let*((pred NIL)
        (axis NIL)
        (h-qz (cl-transforms:z (cl-transforms:orientation human-pose)))
        (h-qw (cl-transforms:w (cl-transforms:orientation human-pose))))
        (cond ((>= h-qw 0.8)
               (setf pred '>)
               (setf axis :Y))
              ((and(< h-qw 0.8)
                   (>= h-qw 0.19)
                   (plusp h-qz))
               (setf pred '<)
               (setf axis :X))
              ((and (< h-qw 0.19)
                    (>= h-qw -0.1))
               (setf pred '<)
               (setf axis :Y))
              ((or (< h-qw -0.1)
                   (minusp h-qz))
               (setf pred '>)
               (setf axis :X))
              (t (format t "Something went wrong inside preposition left~%")
                 (setf pred '>)
                 (setf axis :Y)))
    (list axis pred)))

(defun preposition-behind (human-pose)
  (let*((pred NIL)
        (axis NIL)
        (h-qz (cl-transforms:z (cl-transforms:orientation human-pose)))
        (h-qw (cl-transforms:w (cl-transforms:orientation human-pose))))
        (cond ((>= h-qw 0.8)
               (setf pred '>)
               (setf axis :X))
              ((and(< h-qw 0.8)
                   (>= h-qw 0.19)
                   (plusp h-qz))
               (setf pred '>)
               (setf axis :Y))
              ((and (< h-qw 0.19)
                    (>= h-qw -0.1))
               (setf pred '<)
               (setf axis :X))
              ((or (< h-qw -0.1)
                   (minusp h-qz))
               (setf pred '<)
               (setf axis :Y))
              (t (format t "Something went wrong inside preposition behind~%")
                 (setf pred '<)
                 (setf axis :X)))
    (list axis pred)))

(defun preposition-front (human-pose)
  (let*((pred NIL)
        (axis NIL)
        (h-qz (cl-transforms:z (cl-transforms:orientation human-pose)))
        (h-qw (cl-transforms:w (cl-transforms:orientation human-pose))))
        (cond ((>= h-qw 0.8)
               (setf pred '<)
               (setf axis :X))
              ((and(< h-qw 0.8)
                   (>= h-qw 0.19)
                   (plusp h-qz))
               (setf pred '<)
               (setf axis :Y))
              ((and (< h-qw 0.19)
                    (>= h-qw -0.1))
               (setf pred '>)
               (setf axis :X))
              ((or (< h-qw -0.1)
                   (minusp h-qz))
               (setf pred '>)
               (setf axis :Y))
              (t (format t "Something went wrong inside preposition front~%")
                 (setf pred '>)
                 (setf axis :X)))
    (list axis pred)))

(defun right-direction (human-pose obj-pose)
  (let*((pred NIL)
        (axis NIL))
    (cond((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose))))
           (<=  (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose)))
                 -0.3))
          (setf pred '<)
          (setf axis :X)
       (format t "eins ~a ~a~%" pred axis))        
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose))))
           (>  (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose)))
               -0.3))
          (setf pred '<)
          (setf axis :Y)
(format t "zwei ~a  ~a~%" pred axis))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                (cl-transforms:orientation human-pose))) 0))
          (setf pred '<)
           (setf axis :Y)
               (format t "drei ~a ~a~%" pred axis))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (plusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                    (cl-transforms:orientation human-pose))))
            (<= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.3))
          (setf pred '<)
          (setf axis :Y)
      (format t "vier ~a ~a~%" pred axis))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (<= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '>)
           (setf axis :X)
        (format t "fuenf ~a ~a~%" pred axis))        
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (plusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                    (cl-transforms:orientation human-pose))))
            (> (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '>)
           (setf axis :Y)
        (format t "sechs ~a ~a~%" pred axis))
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (< (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '<)
           (setf axis :X)
          (format t "sieben ~a ~a~%" pred axis))
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (>= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.9))
          (setf pred '>)
          (setf axis :Y)))
         (list axis pred)))
  
(defun left-direction (human-pose obj-pose)
            (format t "cl-transforms:z ~a" (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose))))
  (let*((pred NIL)
        (axis NIL))
    (cond((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose))))
           (<=  (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose)))
                 -0.3))
          (setf pred '>)
          (format t "cl-transforms:z ~a" (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose))))
          (setf axis :X)) ;;:X
          ;;(format t "eins ~a ~a~%" pred axis))        
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose))))
           (>  (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose)))
               -0.3))
          (setf pred '>)
          (setf axis :Y))
      ;;    (format t "zwei ~a  ~a~%" pred axis))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                (cl-transforms:orientation human-pose))) 0))
          (setf pred '>)
           (setf axis :Y))
         ;;         (format t "drei ~a ~a~%" pred axis))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (plusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                    (cl-transforms:orientation human-pose))))
            (<= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.3))
          (setf pred '>)
          (setf axis :Y))
          ;; (format t "vier ~a ~a~%" pred axis))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (<= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '<)
           (setf axis :X))
         ;;    (format t "fuenf ~a ~a~%" pred axis))        
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (plusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                    (cl-transforms:orientation human-pose))))
            (> (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '<)
           (setf axis :Y))
         ;; (format t "sechs ~a ~a~%" pred axis))
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (< (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '>)
          (format t "moun moun~%")
           (setf axis :X))
       ;;    (format t "sieben ~a ~a~%" pred axis))
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (>= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.9))
          (setf pred '<)
          (setf axis :Y)))
     ;;      (format t "Acht ~a ~a~%" pred axis)))
         (list axis pred)))
  
(defun behind-direction-pose ()
  (list '> :Y))

(defun front-direction-pose ()
  (list '< :Y))

(defun left-direction-pose ()
  (list '> :X))

(defun right-direction-pose ()
  (list '< :X))

(defun right-new-direction-pose (obj-pose)
  (let*((pose (cl-transforms:make-pose 
	       (cl-transforms:make-3d-vector (+ (cl-transforms:x (cl-transforms:origin obj-pose)) 6)
					     (cl-transforms:y (cl-transforms:origin obj-pose))
					     (cl-transforms:z (cl-transforms:origin obj-pose)))
	       (cl-transforms:make-quaternion 0 0 0 1))))
    pose))

(defun left-new-direction-pose (obj-pose)
  (let*((pose (cl-transforms:make-pose 
	       (cl-transforms:make-3d-vector (- (cl-transforms:x (cl-transforms:origin obj-pose)) 6)
					     (cl-transforms:y (cl-transforms:origin obj-pose))
					     (cl-transforms:z (cl-transforms:origin obj-pose)))
	       (cl-transforms:make-quaternion 0 0 0 1))))
    pose))

(defun front-new-direction-pose (obj-pose)
  (let*((pose (cl-transforms:make-pose 
	       (cl-transforms:make-3d-vector (cl-transforms:x (cl-transforms:origin obj-pose))
					     (- (cl-transforms:y (cl-transforms:origin obj-pose)) 15)
					     (cl-transforms:z (cl-transforms:origin obj-pose)))
	       (cl-transforms:make-quaternion 0 0 0 1))))
    pose))   

(defun behind-new-direction-pose (obj-pose)
  (let*((pose (cl-transforms:make-pose 
	       (cl-transforms:make-3d-vector (cl-transforms:x (cl-transforms:origin obj-pose))
					     (+ (cl-transforms:y (cl-transforms:origin obj-pose)) 15)
					     (cl-transforms:z (cl-transforms:origin obj-pose)))
	       (cl-transforms:make-quaternion 0 0 0 1))))
    pose)) 

(defun behind-direction (human-pose obj-pose)
  (let*((pred NIL)
        (axis NIL))
    (cond((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                     (cl-transforms:orientation human-pose))))
           (<=  (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose)))
                 -0.3))
          (setf pred '<)
           (format t "eins ~a ~a~%" pred axis)
          (setf axis :Y))        
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                     (cl-transforms:orientation human-pose))))
           (>  (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose)))
               -0.3))
          (setf pred '>)
           (format t "zwei ~a ~a~%" pred axis)

          (setf axis :X))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                (cl-transforms:orientation human-pose))) 0))
          (setf pred '>)
           (format t "drei ~a ~a~%" pred axis)
          (setf axis :X))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (plusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                    (cl-transforms:orientation human-pose))))
            (<= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.3))
          (setf pred '>)
           (format t "vier ~a ~a~%" pred axis)
          (setf axis :X))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (<= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '>)
           (setf axis :Y))        
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (plusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                    (cl-transforms:orientation human-pose))))
            (> (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '<)
           (setf axis :X))
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (< (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '>)
           (setf axis :Y))
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (>= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.9))
          (setf pred '<)
          (setf axis :X)))
         (list axis pred)))


(defun front-direction (human-pose obj-pose)
  (let*((pred NIL)
        (axis NIL))
    (cond((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                     (cl-transforms:orientation human-pose))))
           (<=  (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose)))
                 -0.3))
          (setf pred '>)
           (format t "eins ~a ~a~%" pred axis)
          (setf axis :Y))        
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                     (cl-transforms:orientation human-pose))))
           (>  (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose)))
               -0.3))
          (setf pred '<)
           (format t "zwei ~a ~a~%" pred axis)

          (setf axis :X))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                (cl-transforms:orientation human-pose))) 0))
          (setf pred '<)
           (format t "drei ~a ~a~%" pred axis)
          (setf axis :X))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (plusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                    (cl-transforms:orientation human-pose))))
            (<= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.3))
          (setf pred '<)
           (format t "vier ~a ~a~%" pred axis)
          (setf axis :X))
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (<= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '<)
           (setf axis :Y))        
         ((and 
           (< (- (cl-transforms:y (cl-transforms:origin human-pose))
                 (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (plusp (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                    (cl-transforms:orientation human-pose))))
            (> (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '>)
           (setf axis :X))
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (< (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                 (cl-transforms:orientation human-pose))) 0.9))
           (setf pred '<)
           (setf axis :Y))
         ((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
            (>= (cl-transforms:z (cl-transforms:quaternion->axis-angle
                                  (cl-transforms:orientation human-pose))) 0.9))
          (setf pred '>)
          (setf axis :X)))
         (list axis pred)))


(defun determine-relations (key humanpose)
  (let* ((axis NIL)
         (pred NIL)
         (npose NIL)
         (cvector NIL))
    (cond((equal key :right)
          (setf npose (swm->get-direction-based-on-genius (cl-transforms:make-3d-vector 0 -1 0)))
          (setf cvector (cl-transforms:make-3d-vector (- (cl-transforms:x (cl-transforms:origin npose)) (cl-transforms:x (cl-transforms:origin humanpose)))
                (- (cl-transforms:y (cl-transforms:origin npose)) (cl-transforms:y (cl-transforms:origin humanpose)))
                (- (cl-transforms:z (cl-transforms:origin npose)) (cl-transforms:z (cl-transforms:origin humanpose)))))
          (cond ((and (plusp (cl-transforms:x cvector))
                      (> (cl-transforms:x cvector) 0.7)
                      (< (cl-transforms:y cvector) 0.6))
                 (setf axis :X)
                 (setf pred '>))
                ((and (minusp (cl-transforms:x cvector))
                      (< (cl-transforms:x cvector) -0.7)
                      (< (cl-transforms:y cvector) 0.6))
                 (setf axis :X)
                 (setf pred '<))
                ((and (plusp (cl-transforms:y cvector))
                      (> (cl-transforms:y cvector) 0.7)
                      (< (cl-transforms:x cvector) 0.6))
                 (setf axis :Y)
                 (setf pred '>))
                ((and (minusp (cl-transforms:y cvector))
                      (< (cl-transforms:y cvector) -0.7)
                      (< (cl-transforms:x cvector) 0.6))
                 (setf axis :Y)
                 (setf pred '<))
                (t ())))                                 
         ((equal key :left)
          (setf npose (swm->get-direction-based-on-genius (cl-transforms:make-3d-vector 0 1 0)))
          (setf cvector (cl-transforms:make-3d-vector (- (cl-transforms:x (cl-transforms:origin npose)) (cl-transforms:x (cl-transforms:origin humanpose)))
                (- (cl-transforms:y (cl-transforms:origin npose)) (cl-transforms:y (cl-transforms:origin humanpose)))
                (- (cl-transforms:z (cl-transforms:origin npose)) (cl-transforms:z (cl-transforms:origin humanpose)))))
          (cond ((and (plusp (cl-transforms:x cvector))
                      (> (cl-transforms:x cvector) 0.7)
                       (< (cl-transforms:y cvector) 0.6))
                 (setf axis :X)
                 (setf pred '>))
                ((and (minusp (cl-transforms:x cvector))
                      (< (cl-transforms:x cvector) -0.7)
                      (< (cl-transforms:y cvector) 0.6))
                 (setf axis :X)
                 (setf pred '<))
                ((and (plusp (cl-transforms:y cvector))
                      (> (cl-transforms:y cvector) 0.7)
                      (< (cl-transforms:x cvector) 0.6))
                 (setf axis :Y)
                 (setf pred '>))
                ((and (minusp (cl-transforms:y cvector))
                      (< (cl-transforms:y cvector) -0.7)
                      (< (cl-transforms:x cvector) 0.6))
                 (setf axis :Y)
                 (setf pred '<))
                (t ())))
        ((equal key :front)
          (setf npose (swm->get-direction-based-on-genius (cl-transforms:make-3d-vector 1 0 0)))
          (setf cvector (cl-transforms:make-3d-vector (- (cl-transforms:x (cl-transforms:origin npose)) (cl-transforms:x (cl-transforms:origin humanpose)))
                (- (cl-transforms:y (cl-transforms:origin npose)) (cl-transforms:y (cl-transforms:origin humanpose)))
                (- (cl-transforms:z (cl-transforms:origin npose)) (cl-transforms:z (cl-transforms:origin humanpose)))))
          (cond ((and (plusp (cl-transforms:x cvector))
                      (> (cl-transforms:x cvector) 0.7)
                      (< (cl-transforms:y cvector) 0.6))
                 (setf axis :X)
                 (setf pred '>))
                ((and (minusp (cl-transforms:x cvector))
                      (< (cl-transforms:x cvector) -0.7)
                      (< (cl-transforms:y cvector) 0.6))
                 (setf axis :X)
                 (setf pred '<))
                ((and (plusp (cl-transforms:y cvector))
                      (> (cl-transforms:y cvector) 0.7)
                      (< (cl-transforms:x cvector) 0.6))
                 (setf axis :Y)
                 (setf pred '>))
                ((and (minusp (cl-transforms:y cvector))
                      (< (cl-transforms:y cvector) -0.7)
                      (< (cl-transforms:x cvector) 0.6))
                 (setf axis :Y)
                 (setf pred '<))
                (t ())))      
         ((equal key :behind)
          (setf npose (swm->get-direction-based-on-genius (cl-transforms:make-3d-vector -1 0 0)))
          (setf cvector (cl-transforms:make-3d-vector (- (cl-transforms:x (cl-transforms:origin npose)) (cl-transforms:x (cl-transforms:origin humanpose)))
                (- (cl-transforms:y (cl-transforms:origin npose)) (cl-transforms:y (cl-transforms:origin humanpose)))
                (- (cl-transforms:z (cl-transforms:origin npose)) (cl-transforms:z (cl-transforms:origin humanpose)))))
          (cond ((and (plusp (cl-transforms:x cvector))
                      (> (cl-transforms:x cvector) 0.7)
                      (< (cl-transforms:y cvector) 0.6))
                 (setf axis :X)
                 (setf pred '>))
                ((and (minusp (cl-transforms:x cvector))
                      (< (cl-transforms:x cvector) -0.7)
                      (< (cl-transforms:y cvector) 0.6))
                 (setf axis :X)
                 (setf pred '<))
                ((and (plusp (cl-transforms:y cvector))
                      (> (cl-transforms:y cvector) 0.7)
                      (< (cl-transforms:x cvector) 0.6))
                 (setf axis :Y)
                 (setf pred '>))
                ((and (minusp (cl-transforms:y cvector))
                      (< (cl-transforms:y cvector) -0.7)
                      (< (cl-transforms:x cvector) 0.6))
                 (setf axis :Y)
                 (setf pred '<))
                (t ())))
         (t (format t "func(): determine-relations~%")))
    (list axis pred)))
