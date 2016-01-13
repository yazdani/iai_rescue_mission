;;; Copyright (c) 2015, Fereshta Yazdani <yazdani@cs.uni-bremen.de>
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

(defparameter *liste-name* NIL)
(defparameter *liste-pose* NIL)
(defparameter *liste-dim* NIL)
(defparameter *list-all* NIL)
(defparameter *gesture* NIL)
(defparameter *collision-point* NIL)
(defparameter *distance* 25)
(defparameter *s* 0)

;;getting the bounding boxes of different elements within the semantic map
(defun get-bbox-as-aabb (index)
(let*((dim-x (cl-transforms:x (car (nthcdr index *liste-dim*))))
      (dim-y (cl-transforms:y (car (nthcdr index *liste-dim*))))
      (dim-z (cl-transforms:z (car (nthcdr index *liste-dim*))))
      (pose-x (cl-transforms:x (cl-transforms:origin (car (nthcdr index *liste-pose*)))))
      (pose-y (cl-transforms:y (cl-transforms:origin (car (nthcdr index *liste-pose*)))))
     ;; (pose-z (cl-transforms:z (car (nthcdr index *liste-pose*))))
      (min-vec (cl-transforms:make-3d-vector (- pose-x (/ dim-x 2))
                                             (- pose-y (/ dim-y 2))
                                             0))
      (max-vec (cl-transforms:make-3d-vector (+ pose-x (/ dim-x 2))
                                             (+ pose-y (/ dim-y 2))
                                             dim-z)))
    (semantic-map-costmap::get-aabb min-vec max-vec)))
         
;;getting the bounding boxes of different elements within the semantic map
(defun get-bbox-as-aabb-obj (obj-name)
(let*((sem-hash (slot-value semantic-map-utils::*cached-semantic-map* 'sem-map-utils:parts))
      (sem-obj (gethash obj-name sem-hash))
      (pose (slot-value sem-obj 'cram-semantic-map-utils:pose))
      (dim (slot-value sem-obj 'cram-semantic-map-utils:dimensions))    
      (dim-x (cl-transforms:x dim))
      (dim-y (cl-transforms:y dim))
      (dim-z (cl-transforms:z dim))
      (pose-x (cl-transforms:x (cl-transforms:origin pose)))
      (pose-y (cl-transforms:y (cl-transforms:origin pose)))
      (min-vec (cl-transforms:make-3d-vector (- pose-x (/ dim-x 2))
                                             (- pose-y (/ dim-y 2))
                                             0))
      (max-vec (cl-transforms:make-3d-vector (+ pose-x (/ dim-x 2))
                                             (+ pose-y (/ dim-y 2))
                                             dim-z)))
    (semantic-map-costmap::get-aabb min-vec max-vec)))
                 
      
;; the parameter is a point which will be given by the human rescuer...
(defun give-objs-close-to-human (distance position)
  (format t "Give objs close to human ~%")
  (sem-map-utils:get-semantic-map)
  (let*((liste-name NIL)
        (liste-pose NIL)
        (liste-dim NIL)
        (list-all NIL)
        (sem-hash (slot-value semantic-map-utils::*cached-semantic-map* 'sem-map-utils:parts))
        (keys (hash-keys sem-hash)))
    (loop for i in keys
          do (cond ((and T
                         (compare-distance-with-genius-position
                          position (slot-value (gethash i sem-hash) 'sem-map-utils:pose)
                          distance))
                  ;;  (format t "not working~%")
                    (setf liste-name
                          (append liste-name
                                  (list i)))
                   ;; (format t "name ~a~%" liste-name)
                    (setf liste-pose
                          (append liste-pose
                                  (list 
                                   (slot-value (gethash i sem-hash) 'sem-map-utils:pose))))
                   ;; (format t "pose ~a~%" liste-pose)
                    
                    (setf liste-dim
                          (append liste-dim
                                  (list 
                                   (slot-value (gethash i sem-hash) 'sem-map-utils:dimensions))))
                   ;; (format t "dim ~a~%" liste-dim)

                    (setf list-all
                          (append list-all
                                  (list
                                   (list i 
                                         (slot-value (gethash i sem-hash) 'sem-map-utils:pose)
                                         (slot-value (gethash i sem-hash) 'sem-map-utils:dimensions)))))
                    ;;(format t "all ~a~%" list-all)

                    )
                   (t (setf var 0))))
    (setf *list-all* list-all)
    (setf *liste-pose* liste-pose)
    (setf *liste-name* liste-name)
    (setf *liste-dim* liste-dim)
    list-all))
 
;; this function gives the name of the object back
(defun give-obj-pointed-at (point)
  (let*((*gesture* point)
        (human-pose (get-genius-pose->world-model "genius_link")) 
        (ret NIL))
    (give-objs-close-to-human *distance* human-pose)
   ;; (format t "~a~% "(give-objs-close-to-human *distance* human-pose))
    (setf ret (get-the-direction point (cl-transforms:origin human-pose)))
    (format t "fertig!~%")
    (car ret)))

;; Go into a negative direction, because x < 0
(defun get-the-direction (point human-origin)
(let*((elem NIL)
      (eps 0))
  (loop for index in '(1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 10.5 11 11.5 12 12.5 13 13.5 14 14.5)
        do(let*((dir-vec (cl-transforms:make-3d-vector (- (cl-transforms:x point)
                                                           (cl-transforms:x human-origin))
                                                        (- (cl-transforms:y point)
                                                           (cl-transforms:y human-origin))
                                                        (- (cl-transforms:z point)
                                                           (cl-transforms:z human-origin))))
                 (new-point (cl-transforms:make-3d-vector (+  (cl-transforms:x human-origin)
                                                              (* (cl-transforms:x dir-vec) index))
                                                          (+  (cl-transforms:y human-origin)
                                                              (* (cl-transforms:y dir-vec) index))
                                                          (+  (cl-transforms:z human-origin)
                                                              (* (cl-transforms:z dir-vec) index)))))
            (setf eps (+ eps 1))
            (set-my-marker new-point eps)
            (dotimes(jo (list-length *liste-name*))
               (let* ((elem1 (first (get-bbox-as-aabb jo)))
                      (elem2 (second (get-bbox-as-aabb jo))))
                    (setf value
                     (semantic-map-costmap::inside-aabb elem1 elem2 new-point))
                 (cond ((and (equal value T)
                             (not (equal (car (nthcdr jo *liste-name*))
                                         (find (car (nthcdr jo *liste-name*))
                                               elem :test #'equal))))
                        (setf *collision-point* new-point)
                        (setf elem (append (list (car (nthcdr jo *liste-name*))) elem)))
                       (t (setf var 0)))))))
            elem))

(defun set-my-marker (point index)
  (location-costmap::publish-point point :id (+ 500 index)))

(defun hash-keys (hash-table)
  (loop for key being the hash-keys of hash-table collect key))

(defun compare-distance-with-genius-position (genius_position pose param)
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
  
(defun square (x)
  (* x x))

