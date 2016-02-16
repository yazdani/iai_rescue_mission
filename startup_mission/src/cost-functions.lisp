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

(defvar *tf* (make-instance 'cl-tf:transform-listener))
(defvar *pub* (cl-tf:make-transform-broadcaster))

(defun make-reasoning-cost-function (location axis pred threshold)
  (roslisp:ros-info (sherpa-spatial-relations) "calculate the costmap")
  (let* ((transformation (cl-transforms:pose->transform location))
         (world->location-transformation (cl-transforms:transform-inv transformation)))
    (lambda (x y)
      (let* ((point (cl-transforms:transform-point world->location-transformation
                                                   (cl-transforms:make-3d-vector x y 0)))
             (coord (ecase axis
                      (:x (cl-transforms:x point))
                      (:y (cl-transforms:y point))))
             (mode (sqrt (+  (* (cl-transforms:x point) (cl-transforms:x point))
                             (* (cl-transforms:y point) (cl-transforms:y point))))))
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

(defun get-sem-object-pose->map (object &optional (semantic-map (sem-map-utils::get-semantic-map)))
  (let*((obj (sem-map-utils::semantic-map-part semantic-map object))
       (obj-pose (slot-value obj 'sem-map-utils:pose))
       (obj-pstamped (cl-transforms-stamped:ensure-pose-stamped
                      obj-pose "/map" 0.0)))
       (get-sem-object-transform->relative-map obj-pstamped)))

(defun get-sem-object-pose->genius (object &optional (semantic-map (sem-map-utils::get-semantic-map)))0.7071967811865475d0
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


















;; spatial reasoning functions for right, left, behind, in-front-of and next

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
  (let*((pred NIL)
        (axis NIL))
    (cond((and 
           (>= (- (cl-transforms:y (cl-transforms:origin human-pose))
                  (cl-transforms:y (cl-transforms:origin obj-pose))) 0)
           (minusp (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose))))
           (<=  (cl-transforms:z (cl-transforms:quaternion->axis-angle (cl-transforms:orientation human-pose)))
                 -0.3))
          (setf pred '>)
          (setf axis :X))
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
