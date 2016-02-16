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
  (let*((gen-pose (get-genius-pose->map-frame "genius_link")) ;;(instruct-mission::swm->get-cartesian-pose-agent "genius"))
        (pub (cl-tf:make-transform-broadcaster)))
    (format t "gen-pose is ~a~%" gen-pose)
    (cl-tf:send-transforms pub (cl-transforms-stamped:make-transform-stamped "map" "genius_link" (roslisp:ros-time)  (cl-transforms:origin gen-pose) (cl-transforms:orientation gen-pose)))))


(defun swm->get-gesture->relative-genius (gesture-vec) 

  (let*((pose (cl-transforms-stamped:make-pose-stamped "genius_link" 0.0
                                                              gesture-vec
                                                              (cl-transforms:make-identity-rotation))))                    
    (cl-transforms-stamped:pose-stamped->pose  (cl-tf:transform-pose *tf* :pose pose :target-frame "map"))))

(defun swm->list-values (num point)
  (let*((iks (cl-transforms:x point))
        (yps (cl-transforms:y point))
      ;;  (zet (cl-transforms:z point))
        (liste-tr NIL))
    (cond((and (> iks 0) ;;ok
               (= yps 0))
          (loop for index from 0 to (- (length num) 1)
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (cl-transforms:y point)  (+ (cl-transforms:z point) 0.2))))))))
         ((and (> iks 0) ;;ok
               (< yps 0)
               (>= yps (- 0.6)))
          (loop for index from 0 to (- (length num) 1)
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.8 index))  (+ (cl-transforms:y point)(* (- 0.1) index))  (+ (cl-transforms:z point) 0.2))))))))
          ((and (> iks 0) ;;ok
               (< yps 0)
               (< yps (- 0.6)))
          (loop for index from 0 to (- (length num) 1)
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (+ (cl-transforms:y point)(* (- 0.8) index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (< iks 0) ;;ok
              (= yps 0))
          (loop for index from 0 to (- (length num) 1)
                    do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.5 index)))  (cl-transforms:y point)  (+ (cl-transforms:z point) 0.2))))))))
         ((and (= iks 0) ;;ok
               (> yps 0))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (cl-transforms:x point) (+ (cl-transforms:y point) (* 0.5 index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (= iks 0) ;;ok
               (< yps 0))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (cl-transforms:x point) (+ (cl-transforms:y point) (* (- 0.5) index))  (+ (cl-transforms:z point) 0.2))))))))      
         ((and (> iks 0) ;;ok
               (<= iks 0.5)
               (> yps 0)
               (<= yps 0.5))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  0.2 index))  (+ (cl-transforms:y point) (* 0.15 index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (> iks 0) ;;ok
               (> iks 0.5)
               (> yps 0)
               (> yps 0.5))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  0.3 index))  (+ (cl-transforms:y point) (*  0.5 index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (> iks 0) ;;ok
               (<= iks 0.5)
               (> yps 0)
               (> yps 0.5))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  0.15 index))  (+ (cl-transforms:y point) (*  0.4 index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (> iks 0) ;;ok
               (> iks 0.5)
               (> yps 0)
               (<= yps 0.5))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  0.6 index))  (+ (cl-transforms:y point) (*  0.2 index))  (+ (cl-transforms:z point) 0.2))))))))
;;ookkk
         ((and (< iks 0) ;;ok
               (>= iks (- 0.5))
               (< yps 0)
               (>= yps (- 0.5)))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.2) index))  (+ (cl-transforms:y point) (* (- 0.15) index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (< iks 0) ;;ok
               (< iks (- 0.5))
               (< yps 0)
               (< yps (- 0.5)))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.3) index))  (+ (cl-transforms:y point) (*  (- 0.5) index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (< iks 0) ;;ok
               (>= iks (- 0.5))
               (< yps 0)
               (< yps (- 0.5)))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.15) index))  (+ (cl-transforms:y point) (*  (- 0.4) index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (< iks 0) ;;ok
               (< iks (- 0.5))
               (< yps 0)
               (>= yps (- 0.5)))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.6) index))  (+ (cl-transforms:y point) (*  (- 0.2) index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (< iks 0) ;;ok
               (< iks (- 0.5))
               (> yps 0))
          (loop for index from 0 to (- (length num) 1)
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.6) index))  (+ (cl-transforms:y point) (*  0.2 index))  (+ (cl-transforms:z point) 0.2))))))))
         ((and (< iks 0)
               (>= iks (- 0.5));;ok
               (> yps 0))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.2) index))  (+ (cl-transforms:y point) (*  0.5 index))  (+ (cl-transforms:z point) 0.2))))))))
         (t (format t "wuat?~%")))
    liste-tr))
         
(defun swm->give-obj-pointed-at (point)
    (swm->intern-tf-creater)
(let*((elem NIL)
      (num (make-list 40))
      (eps 0)
      (var 0)
      (*swm-liste* (instruct-mission::swm->geopose-elements))
      (value NIL)
      (liste-tr (swm->list-values num point)))
  ;;  (format t " und ~a~%" (car liste-tr))
  (loop for jindex from 0 to (- (length liste-tr) 1)
        do(let*((new-point (nth jindex liste-tr)))
            (setf eps (+ eps 1))
            (if (equal elem NIL)
                (set-my-marker new-point eps)
                (setf var 1))
    ;;         (format t "test3~%")
            (dotimes(jo (list-length *swm-liste*))
               (let* ((elem1 (cl-transforms:origin (fourth (nth jo *swm-liste*))))
                     (elem2 (cl-transforms:origin (fifth (nth jo *swm-liste*)))))
      ;;           (format t "test4~%")
                 (setf value
                       (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point)))
        ;;          (format t "test5~%")
                 (cond ((and (equal value T)
                             (not (equal (car (nthcdr jo *swm-liste*))
                                         (find (car (nthcdr jo *swm-liste*))
                                               elem :test #'equal))))
          ;;              (format t "test6 ~a~%" new-point)
                        (setf *collision-point* new-point)
                        (setf elem (append (list (car (nthcdr jo *swm-liste*))) elem)))
                       (t (setf var 1)))))))
            elem))


  

;; getting all the objects close to the rescuer...
(defun swm->semantic-map->geom-objects (geom-objects param object-pose)
  (let*((geom-list geom-objects)
      (objects NIL))
     (loop while (/= (length geom-list) 0) 
	do;;(format t "inital ~a~%" geom-list)
     (cond ((and T
                (swm->compare-distance-of-objects (slot-value (car geom-list) 'sem-map-utils:pose) object-pose param))
      ;;      (format t "tester ~a~%" geom-list)
		 (setf objects
           (append objects (list (first geom-list))))
            (setf geom-list (cdr geom-list)))
          (t (setf geom-list (cdr geom-list)))))
 ;; (format t "und objects sind ~a~%" objects)
objects))

(defun swm->compare-distance-of-objects (genius_position pose param)
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
  
(defun swm->create-semantic-map ()
  (format t "give me back~%")
  (make-instance 'sem-map-utils::semantic-map
                 :parts
                 (hash-function)))

(defun hash-function()
    (let*((sem-liste (instruct-mission::swm->geopose-elements))
        (intern-liste (internal-semantic-map-geom sem-liste))
        (hasht (make-hash-table :test #'eql)))
        (mapc (lambda (key-and-geom)
                         (let ((key (first key-and-geom))
                               (geom (second key-and-geom)))
                           (setf (gethash key hasht) geom)))
                       intern-liste)
    hasht))

(defun internal-semantic-map-geom (*swm-liste*)
  (let*((elem NIL))
    (loop for i from 0 to (- (length *swm-liste*) 1)
          do(setf elem (append (list (list (first (nth i *swm-liste*)) (make-instance
                                                                        sem-map-utils::'semantic-map-geom
                                                                        :type (second (nth i *swm-liste*))
                                                                        :name (first (nth i *swm-liste*))
                                                                        :owl-name "owl-name"
                                                                        :pose (third (nth i *swm-liste*))
                                                                        :dimensions (internal-bboxs (fourth (nth i *swm-liste*)) (fifth (nth i *swm-liste*)))
                                                                        :aliases NIL))) elem)))
    elem))
                              

(defun internal-bboxs (trans1 trans2)
  (let*((cl1-x (cl-transforms:x  (cl-transforms:origin trans1)))
        (cl1-y (cl-transforms:y  (cl-transforms:origin trans1)))
        (cl1-z (cl-transforms:z  (cl-transforms:origin trans1)))
        (cl2-x (cl-transforms:x  (cl-transforms:origin trans2)))
        (cl2-y (cl-transforms:y  (cl-transforms:origin trans2)))               
        (cl2-z (cl-transforms:z  (cl-transforms:origin trans2)))
        (vec (cl-transforms:make-3d-vector (if (minusp cl2-x)
                                               (if (minusp (+ cl1-x (* (- 1) cl2-x)))
                                                   (* (- 1) (+ cl1-x (* (- 1) cl2-x)))
                                                   (+ cl1-x (* (- 1) cl2-x)))
                                               (if (minusp (+ cl1-x  cl2-x))
                                                    (* (- 1) (+ cl1-x  cl2-x))
                                                    (+ cl1-x cl2-x)))
                                            (if (minusp cl2-y)
                                               (if (minusp (+ cl1-y (* (- 1) cl2-y)))
                                                   (* (- 1) (+ cl1-y (* (- 1) cl2-y)))
                                                   (+ cl1-y (* (- 1) cl2-y)))
                                               (if (minusp (+ cl1-y  cl2-y))
                                                    (* (- 1) (+ cl1-y  cl2-y))
                                                    (+ cl1-y cl2-y)))
                                             (if (minusp cl2-z)
                                               (if (minusp (+ cl1-z (* (- 1) cl2-z)))
                                                   (* (- 1) (+ cl1-z (* (- 1) cl2-z)))
                                                   (+ cl1-z (* (- 1) cl2-z)))
                                               (if (minusp (+ cl1-z  cl2-z))
                                                    (* (- 1) (+ cl1-z  cl2-z))
                                                    (+ cl1-z cl2-z))))))
    vec))
