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

(in-package :startup-mission)

(defun swm->intern-tf-creater ()
  (format t "swm->intern-tf-creater~%")
  (let*((gen-pose (instruct-mission::swm->get-cartesian-pose-agent "genius"))
        (pub (cl-tf:make-transform-broadcaster)))
    (cl-tf:send-transforms pub (cl-transforms-stamped:make-transform-stamped "map" "genius_link" (roslisp:ros-time)  (cl-transforms:origin gen-pose) (cl-transforms:orientation gen-pose)))))

(defun swm->get-gesture->relative-genius (gesture-vec)
  (swm->intern-tf-creater)
  (let*( (obj-stamped (cl-transforms-stamped:make-pose-stamped "genius_link" 0.0 gesture-vec (cl-transforms:make-identity-rotation))))
     (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose  *tf* :pose obj-stamped :target-frame "map"))))

(defun swm->give-obj-pointed-at (point)
  (format t "point ~a~%" point)
  (let*((elem NIL)
        (new-point (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector
                                                      (cl-transforms:x point)
                                                       (cl-transforms:y point)
                                                       (cl-transforms:z point) 0.5)))            
        (eps 0)
        (var 0)
        (value NIL)
        (swmliste *swm-liste*))
    (loop for index in '(0 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3 3.25 3.5 3.75 4 4.25 4.5 4.75 5 5.25 5.5 5.75 6 6.25 6.5 6.75 7 7.25 7.5 7.75 8 8.25 8.5 8.75 9 9.25 9.5 9.75 10 10.25 10.5 10.75 11 11.25 11.5 11.75)
	  do(let*((new-pointer (cl-transforms:origin new-point))
                  (new-orient (cl-transforms:orientation new-point)))
             (cond ((and (= (cl-transforms:y point) 0)
                        (> (cl-transforms:x point) 0))
                 (setf new-point (cl-transforms:make-pose (cl-transforms:make-3d-vector (+ (cl-transforms:x new-pointer) index)
                                                               (cl-transforms:y new-pointer)
                                                               (+ (cl-transforms:z new-pointer) 0.0)) new-orient))
                    (format t "here in x plus~%"))
                   ((and (= (cl-transforms:x point) 0)
                        (< (cl-transforms:y point) 0))
                    (setf new-point (cl-transforms:make-pose (cl-transforms:make-3d-vector (+ (cl-transforms:x new-pointer) 0)
                                                                  (+ (cl-transforms:y new-pointer) (- index))
                                                                  (+ (cl-transforms:z new-pointer) 0.0)) new-orient)))
                   ((and (> (cl-transforms:y point) 0)
                           (= (cl-transforms:x point) 0))
                      (setf new-point (cl-transforms:make-pose (cl-transforms:make-3d-vector (+ (cl-transforms:x new-pointer) 0)
                                                                    (+(cl-transforms:y new-pointer) index)
                                                                    (+ (cl-transforms:z new-pointer) 0.0)) new-orient)))))
            (setf eps (+ eps 1))
            (format t "new-point ~a~%" new-point)
            (if (equal elem NIL)
             (set-my-marker new-point eps)
                (setf var 1))
                  (format t "new-point2 ~a~%" new-point)
            (dotimes(jo (list-length swmliste))
              (let* ((elem1 (cl-transforms:origin (third (nth jo swmliste))))
                     (elem2 (cl-transforms:origin (fourth (nth jo swmliste)))))
                    (setf value
                     (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point)))
                 (cond ((and (equal value T)
                             (not (equal (car (nth jo swmliste))
                                         (find (car (nth jo swmliste))
                                               elem :test #'equal))))
                        (setf *collision-point* new-point)
                        (setf elem (append (list (car (nth jo swmliste))) elem)))
                       (t (setf var 0))))))
            (car elem)))

;; getting all the objects close to the rescuer...
(defun swm->give-objs-close-to-human (distance position)
  (let*((var 0)
	(list-elem *swm-liste*))
    (loop for i from 0 to (- (length list-elem) 1)
          do (cond ((and T
                         (compare-distance-with-genius-position
                          position (nth 2 (nth i list-elem)))
                          distance))))
    *swm-liste*))

(defun swm->compare-distance-with-genius-position (genius_position pose param)
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
  
