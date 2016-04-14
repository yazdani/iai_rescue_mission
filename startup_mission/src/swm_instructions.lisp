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
(defvar *pub*)
 ;;(roslisp:ros-time)
(defun swm->intern-tf-creater ()
;;  (format t "swm->intern-tf-creater~%")
  (let*((gen-pose (instruct-mission::swm->get-cartesian-pose-agent "genius"));;(get-genius-pose->map-frame "genius_link")) ;;(instruct-mission::swm->get-cartesian-pose-agent "genius"))
    (pub (cl-tf:make-transform-broadcaster)))
 ;;   (format t "gen-pose is ~a~%" gen-pose)
 ;;   (format t "*pub is * ~a~%" pub)
 ;;   (format t "'gen...~a~%" (cl-transforms-stamped:make-transform-stamped "map" "genius_link" (roslisp:ros-time) (cl-transforms:origin gen-pose) (cl-transforms:orientation gen-pose)))
    (cl-tf:send-static-transforms pub 1.0 "meineGeste" (cl-transforms-stamped:make-transform-stamped "map" "genius_link" (roslisp:ros-time)  (cl-transforms:origin gen-pose) (cl-transforms:orientation gen-pose)))))


(defun swm->get-gesture->relative-genius (gesture-vec) 
;;(format t "GESTURE VEC ~a~%" gesture-vec)
(let*((pose (cl-transforms-stamped:make-pose-stamped "genius_link" 0.0
                                                            gesture-vec
                                                             (cl-transforms:make-identity-rotation))))
;  (format t "GENIUS-POOOOSEEE ~a~%" pose)
(cl-transforms-stamped:pose-stamped->pose  (cl-tf:transform-pose *tf* :pose pose :target-frame "map"))))

(defun swm->list-values (num point)
  (let*((zet 1.0)
        (iks (cl-transforms:x point))
        (yps (cl-transforms:y point))
      ;;  (zet (cl-transforms:z point))
        (liste-tr NIL))
    (cond((and (> iks 0) ;;ok
               (= yps 0))
          (loop for index from 0 to (- (length num) 1)
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (cl-transforms:y point)  (+ (cl-transforms:z point) zet))))))))
         ((and (> iks 0) ;;ok
               (< yps 0)
               (>= yps (- 0.6)))
          (loop for index from 0 to (- (length num) 1)
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.8 index))  (+ (cl-transforms:y point)(* (- 0.3) index))  (+ (cl-transforms:z point) zet))))))))
          ((and (> iks 0) ;;ok
               (< yps 0)
               (< yps (- 0.6)))
          (loop for index from 0 to (- (length num) 1)
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (+ (cl-transforms:y point)(* (- 0.8) index))  (+ (cl-transforms:z point) zet))))))))
         ((and (< iks 0) ;;ok
              (= yps 0))
          (loop for index from 0 to (- (length num) 1)
                    do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.5 index)))  (cl-transforms:y point)  (+ (cl-transforms:z point) zet))))))))
         ((and (= iks 0) ;;ok
               (> yps 0))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (cl-transforms:x point) (+ (cl-transforms:y point) (* 0.5 index))  (+ (cl-transforms:z point) zet))))))))
         ((and (= iks 0) ;;ok
               (< yps 0))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (cl-transforms:x point) (+ (cl-transforms:y point) (* (- 0.5) index))  (+ (cl-transforms:z point) zet))))))))      
         ((and (> iks 0) ;;ok
               (<= iks 0.5)
               (> yps 0)
               (<= yps 0.5))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  0.2 index))  (+ (cl-transforms:y point) (* 0.15 index))  (+ (cl-transforms:z point) zet))))))))
         ((and (> iks 0) ;;ok
               (> iks 0.5)
               (> yps 0)
               (> yps 0.5))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  0.3 index))  (+ (cl-transforms:y point) (*  0.5 index))  (+ (cl-transforms:z point) zet))))))))
         ((and (> iks 0) ;;ok
               (<= iks 0.5)
               (> yps 0)
               (> yps 0.5))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  0.15 index))  (+ (cl-transforms:y point) (*  0.4 index))  (+ (cl-transforms:z point) zet))))))))
         ((and (> iks 0) ;;ok
               (> iks 0.5)
               (> yps 0)
               (<= yps 0.5))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  0.6 index))  (+ (cl-transforms:y point) (*  0.2 index))  (+ (cl-transforms:z point) zet))))))))
;;ookkk
         ((and (< iks 0) ;;ok
               (>= iks (- 0.5))
               (< yps 0)
               (>= yps (- 0.5)))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.2) index))  (+ (cl-transforms:y point) (* (- 0.15) index))  (+ (cl-transforms:z point) zet))))))))
         ((and (< iks 0) ;;ok
               (< iks (- 0.5))
               (< yps 0)
               (< yps (- 0.5)))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.3) index))  (+ (cl-transforms:y point) (*  (- 0.5) index))  (+ (cl-transforms:z point) zet))))))))
         ((and (< iks 0) ;;ok
               (>= iks (- 0.5))
               (< yps 0)
               (< yps (- 0.5)))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.15) index))  (+ (cl-transforms:y point) (*  (- 0.4) index))  (+ (cl-transforms:z point) zet))))))))
         ((and (< iks 0) ;;ok
               (< iks (- 0.5))
               (< yps 0)
               (>= yps (- 0.5)))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.6) index))  (+ (cl-transforms:y point) (*  (- 0.2) index))  (+ (cl-transforms:z point) zet))))))))
         ((and (< iks 0) ;;ok
               (< iks (- 0.5))
               (> yps 0))
          (loop for index from 0 to (- (length num) 1)
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.6) index))  (+ (cl-transforms:y point) (*  0.2 index))  (+ (cl-transforms:z point) zet))))))))
         ((and (< iks 0)
               (>= iks (- 0.5));;ok
               (> yps 0))
          (loop for index from 0 to (- (length num) 1)
                     do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (*  (- 0.2) index))  (+ (cl-transforms:y point) (*  0.5 index))  (+ (cl-transforms:z point) zet))))))))
         (t ()))
    liste-tr))

(defun swm->get-names (*swm-liste*)
  (let*((swm-names NIL))
    (dotimes(jo (list-length *swm-liste*))
          (setf swm-names (append swm-names (list (first (nth jo *swm-liste*))))))
    swm-names))

(defun set-height-pose (point param)
  (cl-transforms:make-pose (cl-transforms:make-3d-vector
                            (cl-transforms:x
                             (cl-transforms:origin point))
                            (cl-transforms:y
                             (cl-transforms:origin point))
                            (+ (cl-transforms:z
                                (cl-transforms:origin point)) param))
                           (cl-transforms:make-identity-rotation)))

(defun set-width-pose (point param)
  (cl-transforms:make-pose (cl-transforms:make-3d-vector
                            (cl-transforms:x
                             (cl-transforms:origin point))
                            (+ (cl-transforms:y
                                (cl-transforms:origin point)) param)
                            (cl-transforms:z
                             (cl-transforms:origin point)))
                           (cl-transforms:make-identity-rotation)))


(defun swm->give-obj-pointed-at (point)
  (format t "func():swm->give-obj-pointed-at~%")
  (setf *pub* (swm->intern-tf-creater))
  (location-costmap::remove-markers-up-to-index 50)
 (let*((elem NIL)(num (make-list 200))
       (eps 0)(var 0)(*swm-liste* instruct-mission::*geo-list*)
       (swm-names (swm->get-names *swm-liste*))(value NIL)(sem-map (instruct-mission::swm->create-semantic-map))
       (tester 50)
								  
       (sem-hash (slot-value sem-map 'sem-map-utils:parts))(liste-tr (swm->list-values num point))
      )
    (loop for jindex from 0 to (- (length liste-tr) 1)
          do (let*((new-point (nth jindex liste-tr)))
               (loop while (not (equal tester 200))
                     do(setf new-point+z (set-height-pose new-point tester))
                       (setf new-point-z (set-height-pose new-point (* tester (- 1))))
                       (setf new-point+y2 (set-width-pose new-point 25))
                       (setf new-point-y2 (set-width-pose new-point (- 25)))
                       (setf new-point+y4 (set-width-pose new-point 50))
                       (setf new-point-y4 (set-width-pose new-point (- 50)))
                       (setf new-point+y6 (set-width-pose new-point 75))
                       (setf new-point-y6 (set-height-pose new-point (- 75)))
                       (setf new-point+y8 (set-height-pose new-point 100))
                       (setf new-point-y8 (set-height-pose new-point (- 100)))
                       (setf new-point+y10 (set-width-pose new-point 125))
                       (setf new-point-y10 (set-height-pose new-point (- 125)))
                       (setf new-point+y12 (set-height-pose new-point 150))
                       (setf new-point-y12 (set-height-pose new-point (- 150)))
                       (setf eps (+ eps 1))
                       (setf tester (+ tester 50))
                       (if (equal elem NIL)
                         (set-my-marker new-point eps)
                         (setf var 1)) 
                     (dotimes(jo (list-length *swm-liste*))
                       (let* ((elem1 (first (instruct-mission::swm->get-bbox-as-aabb (nth jo swm-names) sem-hash)))
                              (elem2 (second (instruct-mission::swm->get-bbox-as-aabb (nth jo swm-names) sem-hash))))
                         (setf value
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point))) 
                         (setf value+z
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z)))
                         (setf value-z
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z)))
                         (setf value+y2
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y2)))
                         (setf value-y2
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y2)))
                         (setf value+y4
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y4)))
                         (setf value-y4
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y4)))
                         (setf value+y6
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y6)))
                         (setf value-y6
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y6)))
                         (setf value+y8
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y8)))
                         (setf value-y8
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y8)))
                         (setf value+y10
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y10)))
                         (setf value-y10
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y10)))
                         (setf value+y12
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y12)))
                         (setf value-y12
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y12)))          
                         (cond ((and (or (equal value T)
                                         (equal value+z T)
                                         (equal value-z T)
                                         (equal value+y2 T)
                                         (equal value-y2 T)
                                         (equal value+y4 T)
                                         (equal value-y4 T)
                                         (equal value+y6 T)
                                         (equal value-y6 T)
                                         (equal value+y8 T)
                                         (equal value-y8 T)
                                         (equal value+y10 T)
                                         (equal value-y10 T)
                                         (equal value+y12 T)
                                         (equal value-y12 T))
                         (not (equal (nth jo swm-names)
                                     (find (nth jo swm-names)
                                           elem :test #'equal))))
                                (setf *collision-point* new-point)
                    (set-my-marker new-point 1000)
                                (set-my-marker new-point-z 1222000)
                                 (set-my-marker new-point+z 1333000)
                    (setf elem (append (list (nth jo swm-names)) elem)))
                   (t (set-my-marker new-point (+ 50000 (* jo jindex))))))))
               (setf tester 0)))
              (swm->intern-tf-remover)
   (format t "elements of the poitning list ~a~%" elem)
             (reverse elem)))  


  

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
  

(defun swm->intern-tf-remover ()
  ;; (format t "swm->intern-tf-remover~%")
  ;;(format t "*pub123* ~a~%" *pub*)
  (sb-thread:destroy-thread *pub*))
 ;; (format t "*pub456* ~a~%" *pub*))

;; (defun swm->get-gesture->relative-genius (human-pose gesture-vec)
;;   (format t "object-pose ~a~%" gesture-vec)
;;   (let*((h-ox (cl-transforms:x (cl-transforms:origin human-pose)))
;;          (h-oy (cl-transforms:y (cl-transforms:origin human-pose)))
;;          (h-oz (cl-transforms:z (cl-transforms:origin human-pose)))
;;         (h-qz (cl-transforms:z (cl-transforms:orientation human-pose)))
;;          (h-qw (cl-transforms:w (cl-transforms:orientation human-pose)))
;;          (o-x (cl-transforms:x gesture-vec))
;;          (o-y (cl-transforms:y gesture-vec))
;;          (o-z (cl-transforms:z gesture-vec))
;;          (pose NIL))
;;      (format t "hqz ~a und hqw ~a~%" h-qz h-qw)
;;      (cond((and (plusp h-qz)
;;                 (plusp h-qw)
;;                 (> 1.1 h-qw)
;;                 (<= 0.5 h-qw))
;;            (setf pose (cl-transforms:make-pose
;;                        (cl-transforms:make-3d-vector (+ h-ox o-x) (- h-oy 0.3) h-oz)
;;                        (cl-transforms:orientation human-pose))))
;;            ((and (= 0 h-qz)
;;                   (= 1 h-qw))
;;              (format t "Entering~%")
;;             (setf pose (cl-transforms:make-pose
;;                         (cl-transforms:make-3d-vector (+ h-ox o-x) (+ h-oy o-y) (+ h-oz o-z))
;;                         (cl-transforms:orientation human-pose))))
;;           ((and (plusp h-qz)
;;                 (> 0.5 h-qw))
;;            (format t "entering~%")
;;            (setf pose (cl-transforms:make-pose
;;                        (cl-transforms:make-3d-vector (+ o-x 0.3) (+ o-y 0.3) o-z)
;;                        (cl-transforms:orientation human-pose))))
;;           ((and (minusp h-qz)
;;                 (plusp h-qw)
;;                 (> 1.1 h-qw)
;;                 (<= 0.5 h-qw))           (setf pose (cl-transforms:make-pose
;;                        (cl-transforms:make-3d-vector (- o-x 0.5) (- o-y 0.5) o-z)
;;                        (cl-transforms:orientation human-pose))))
;;           ((and (minusp h-qz)
;;                 (> 0.5 h-qw))
;;            (setf pose (cl-transforms:make-pose
;;                        (cl-transforms:make-3d-vector (- o-x 0.5) (+ o-y 0.5) o-z)
;;                        (cl-transforms:orientation human-pose))))
;;           (t (format t "Something went wrong in costfunction-right~%")))
;;     (format t "POSE IS ~a~%" pose)
;;     (set-my-marker pose 10000)
;;      pose))
