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


(defun swm->intern-tf-creater ()
  (let*((gen-pose (swm->get-cartesian-pose-agent "genius"));;(get-genius-pose->map-frame "genius_link")) ;;(instruct-mission::swm->get-cartesian-pose-agent "genius"))
    (pub (cl-tf:make-transform-broadcaster)))
    (cl-tf:send-static-transforms pub 1.0 "meineGeste" (cl-transforms-stamped:make-transform-stamped "map" "genius_link" (roslisp:ros-time)  (cl-transforms:origin gen-pose)(cl-transforms:orientation gen-pose)))))


(defun swm->get-gesture->relative-genius (gesture-vec) 
(let*((pose (cl-transforms-stamped:make-pose-stamped "genius_link" 0.0
                                                            gesture-vec
                                                             (cl-transforms:make-identity-rotation))))
(cl-transforms-stamped:pose-stamped->pose  (cl-tf:transform-pose *tf* :pose pose :target-frame "map"))))

(defun swm->list-values (num point)
  (let*((zet 1.0)
        (iks (cl-transforms:x point))
        (yps (cl-transforms:y point))
        (liste-tr NIL))
    (cond((and (>= iks 0) 
               (<= yps 0))
          (setf liste-tr (func-up-right point iks yps zet num liste-tr)))
         ((and (<= iks 0)
               (<= yps 0))
          (setf liste-tr (func-down-right point iks yps zet num liste-tr)))
         ((and (<= iks 0)
               (>= yps 0))
          (setf liste-tr (func-down-left point iks yps zet num liste-tr)))
         ((and (>= iks 0)
               (>= yps 0))
          (setf liste-tr (func-up-left point iks yps zet num liste-tr)))
         (t()))
    liste-tr))

(defun func-up-left (point iks yps zet num liste-tr)
   (cond((and (> iks 0)
              (<= iks 0.1) 
              (> yps 0))
          (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector  (+ (cl-transforms:x point)  (* 0.1 index))  (+ (cl-transforms:y point) (* 0.5 index))  (+ (cl-transforms:z point) zet))))))))
        ((and (> iks 0.1)
              (<= iks 0.3) 
              (> yps 0))
          (dotimes(index (length num))
            do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector  (+ (cl-transforms:x point)  (* 0.25 index))  (+ (cl-transforms:y point) (* 0.5 index))  (+ (cl-transforms:z point) zet))))))))
        ((and (> iks 0.3)
              (<= iks 0.5) 
              (> yps 0))
         (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector  (+ (cl-transforms:x point)  (* 0.4 index))  (+ (cl-transforms:y point) (* 0.5 index))  (+ (cl-transforms:z point) zet))))))))
        ((and (> iks 0.5)
              (<= iks 0.7) 
              (> yps 0))
         (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector  (+ (cl-transforms:x point)  (* 0.6 index))  (+ (cl-transforms:y point) (* 0.4 index))  (+ (cl-transforms:z point) zet))))))))
        ((and (> iks 0.7)
              (<= iks 0.8) 
              (> yps 0))
         (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector  (+ (cl-transforms:x point)  (* 0.7 index))  (+ (cl-transforms:y point) (* 0.3 index))  (+ (cl-transforms:z point) zet))))))))
        ((and (> iks 0.8)
              (<= iks 0.9) 
              (> yps 0))
         (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector  (+ (cl-transforms:x point)  (* 0.8 index))  (+ (cl-transforms:y point) (* 0.2 index))  (+ (cl-transforms:z point) zet))))))))
        ((and (> iks 0.9)
              (<= iks 1) 
              (> yps 0))
         (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector  (+ (cl-transforms:x point)  (* 0.9 index))  (+ (cl-transforms:y point) (* 0.1 index))  (+ (cl-transforms:z point) zet))))))))
        (t()))
  liste-tr
  )

  (defun func-down-left (point iks yps zet num liste-tr)
    (cond((and (< iks 0) 
               (> yps 0)
               (<= yps 0.1))
          (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.85) index))  (+ (cl-transforms:y point)(* 0.1 index))  (+ (cl-transforms:z point) zet))))))))
         ((and (< iks 0) 
               (> yps 0.1)
               (<= yps 0.3))
          (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.7) index))  (+ (cl-transforms:y point)(* 0.25 index))  (+ (cl-transforms:z point) zet))))))))
         ((and (< iks 0) 
               (> yps 0.3)
               (<= yps 0.4))
          (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.6) index))  (+ (cl-transforms:y point)(* 0.4 index))  (+ (cl-transforms:z point) zet))))))))
    ((and (< iks 0) 
               (> yps 0.4)
               (<= yps 0.5))
          (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.4) index))  (+ (cl-transforms:y point)(* 0.6 index))  (+ (cl-transforms:z point) zet))))))))
    ((and (< iks 0) 
               (> yps 0.5)
               (<= yps 0.6))
     (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.3) index))  (+ (cl-transforms:y point)(* 0.7 index))  (+ (cl-transforms:z point) zet))))))))
    ((and (< iks 0) 
          (> yps 0.6)
          (<= yps 0.7))
     (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.2) index))  (+ (cl-transforms:y point)(* 0.8 index))  (+ (cl-transforms:z point) zet))))))))
    ((and (< iks 0) 
          (> yps 0.7)
          (<= yps 0.9))
     (dotimes(index (length num))
       do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.1) index))  (+ (cl-transforms:y point)(* 0.9 index))  (+ (cl-transforms:z point) zet))))))))
    ((and (= iks 0) 
          (> yps 0))
     (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (cl-transforms:x point)  (+ (cl-transforms:y point)(* 0.5 index))  (+ (cl-transforms:z point) zet))))))))
             (t ()))
             liste-tr)
 
(defun func-down-right (point iks yps zet num liste-tr)
  (format t "func down rohjt ~%")
  (cond((and (< iks 0) 
             (= yps 0))
        (dotimes(index (length num))
        do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.5) index))  (cl-transforms:y point)  (+ (cl-transforms:z point) zet))))))))
       ((and (< iks 0) 
             (> yps -1)
             (<= yps -0.9))
        (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.1) index))  (+ (cl-transforms:y point)(* (- 0.9) index))  (+ (cl-transforms:z point) zet))))))))
       ((and (< iks 0) 
             (> yps -1)
             (> yps -0.9)
             (<= yps -0.8))
        (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.2) index))  (+ (cl-transforms:y point)(* (- 0.8) index))  (+ (cl-transforms:z point) zet))))))))
              ((and (< iks 0) 
             (> yps -1)
             (> yps -0.8)
             (<= yps -0.6))
               (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.3) index))  (+ (cl-transforms:y point)(* (- 0.7) index))  (+ (cl-transforms:z point) zet))))))))
              ((and (< iks 0) 
             (> yps -1)
             (> yps -0.6)
             (<= yps -0.5))
          (dotimes(index (length num))
            do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.4) index))  (+ (cl-transforms:y point)(* (- 0.6) index))  (+ (cl-transforms:z point) zet))))))))
               ((and (< iks 0) 
             (> yps -1)
             (> yps -0.5)
             (<= yps -0.4))
                (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.5) index))  (+ (cl-transforms:y point)(* (- 0.5) index))  (+ (cl-transforms:z point) zet))))))))
               ((and (< iks 0) 
                     (> yps -1)
                     (> yps -0.4)
                     (<= yps -0.3))
                (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.6) index))  (+ (cl-transforms:y point)(* (- 0.4) index))  (+ (cl-transforms:z point) zet))))))))
                    ((and (< iks 0) 
                     (> yps -1)
                     (> yps -0.3)
                     (<= yps -0.2))
                     (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.7) index))  (+ (cl-transforms:y point)(* (- 0.3) index))  (+ (cl-transforms:z point) zet))))))))
                         ((and (< iks 0) 
                     (> yps -1)
                     (> yps -0.2)
                     (<= yps -0.1))
                          (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* (- 0.85) index))  (+ (cl-transforms:y point)(* (- 0.15) index))  (+ (cl-transforms:z point) zet))))))))                    
             (t ()))
             liste-tr)
  
(defun func-up-right (point iks yps zet num liste-tr)
  (cond((and (> iks 0) 
             (= yps 0))
        (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (cl-transforms:y point)  (+ (cl-transforms:z point) zet))))))))
         ((and (> iks 0) ;;ok
               (< yps 0)
               (>= yps (- 0.2)))
          (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.8 index))  (+ (cl-transforms:y point)(* (- 0.12) index))  (+ (cl-transforms:z point) zet))))))))        
         ((and (> iks 0) ;;ok
               (< yps 0)
               (< yps (- 0.2))
               (>= yps (- 0.4)))
          (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.8 index))  (+ (cl-transforms:y point)(* (- 0.25) index))  (+ (cl-transforms:z point) zet))))))))
         ((and (> iks 0) ;;ok
               (< yps 0)
               (< yps (- 0.4))
               (>= yps (- 0.5)))
          (dotimes(index (length num))
            do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (+ (cl-transforms:y point)(* (- 0.265) index))  (+ (cl-transforms:z point) zet))))))))
          ((and (> iks 0) ;;ok
               (< yps 0)
               (< yps (- 0.5))
               (>= yps (- 0.6)))
           (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (+ (cl-transforms:y point)(* (- 0.35) index))  (+ (cl-transforms:z point) zet))))))))
          ((and (> iks 0) ;;ok
                (< yps 0)
                (< yps (- 0.6))
                (>= yps (- 0.7)))
          (dotimes(index (length num))
           do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (+ (cl-transforms:y point)(* (- 0.55) index))  (+ (cl-transforms:z point) zet))))))))
          ((and (> iks 0) ;;ok
                (< yps 0)
                (< yps (- 0.7))
                (> yps (- 0.8)))
           (dotimes(index (length num))
             do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.5 index))  (+ (cl-transforms:y point)(* (- 0.6) index))  (+ (cl-transforms:z point) zet))))))))
          ((and (> iks 0) ;;ok
                (< yps 0)
               (<= yps (- 0.8))
               (> yps (- 0.9)))
           (dotimes(index (length num))
             do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.35 index))  (+ (cl-transforms:y point)(* (- 0.7) index))  (+ (cl-transforms:z point) zet))))))))
               ((and (> iks 0) ;;ok
                     (< yps 0)
               (<= yps (- 0.9))
               (>= yps (- 1)))
                (dotimes(index (length num))
                  do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) (* 0.2 index))  (+ (cl-transforms:y point)(*  (- 0.99) index))  (+ (cl-transforms:z point) zet))))))))             
             ((and (= iks 0) ;;ok
                   (< yps 0))
             (dotimes(index (length num))
                do (setf liste-tr (append liste-tr (list (swm->get-gesture->relative-genius (cl-transforms:make-3d-vector (cl-transforms:x point)  (+ (cl-transforms:y point)(* (- 0.4) index))  (+ (cl-transforms:z point) zet))))))))
             (t ()))
             liste-tr)
         

(defun swm->get-names (swm-liste)
  (let*((swm-names NIL))
    (dotimes(jo (list-length swm-liste))
          (setf swm-names (append swm-names (list (first (nth jo swm-liste))))))
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


(defun sem-map->give-obj-pointed-at (point)
  (setf *pub* (swm->intern-tf-creater))
 (let*((elem NIL)
       (num (make-list 300))
       (eps 0)(var 0)
       (sem-map (swm->initialize-semantic-map)) ;;change the method
       (sem-hash (slot-value sem-map 'sem-map-utils:parts))
       (sem-keys (hash-table-keys sem-hash))
       (liste-tr (swm->list-values num point))
       (liste-up (all-ups liste-tr))
       (liste-down (all-downs liste-tr))
       (liste-right (all-rights liste-tr))
       (liste-left (all-lefts liste-tr))
       (liste-front (all-fronts liste-tr))
       (liste-back (all-backs liste-tr))
       (value NIL))
   (format t "TEEEEEEEEEEEEEEEEEEEEEEST (car liste-tr) ~a~%" (car liste-tr))
   (dotimes (jindex (length liste-tr))
     do ;(format t "nth index ~a~%" (cl-transforms:origin (nth jindex liste-tr)))
     ;(if (equal elem NIL)
            (dotimes(jo (length sem-keys))
              do(let* ((all (swm->get-bbox-as-aabb (nth jo sem-keys) sem-hash))
                       (elem1 (first all))
                       (elem2 (second all))
                       (npoint (cl-transforms:origin (nth jindex liste-tr)))
                       (upoint (cl-transforms:origin (nth jindex liste-up)))
                       (dpoint (cl-transforms:origin (nth jindex liste-down)))
                       (rpoint (cl-transforms:origin (nth jindex liste-right)))
                       (lpoint (cl-transforms:origin (nth jindex liste-left)))
                       (fpoint (cl-transforms:origin (nth jindex liste-front)))
                       (bpoint (cl-transforms:origin (nth jindex liste-back)))
                       (value (semantic-map-costmap::inside-aabb elem1 elem2 npoint))
                       (uvalue (semantic-map-costmap::inside-aabb elem1 elem2 upoint))
                       (dvalue (semantic-map-costmap::inside-aabb elem1 elem2 dpoint))
                       (rvalue (semantic-map-costmap::inside-aabb elem1 elem2 rpoint))
                       (lvalue (semantic-map-costmap::inside-aabb elem1 elem2 lpoint))
                       (fvalue (semantic-map-costmap::inside-aabb elem1 elem2 fpoint))
                       (bvalue (semantic-map-costmap::inside-aabb elem1 elem2 bpoint)))
                 (cond ((and (or (equal value T)
                                 (equal uvalue T)
                                 (equal dvalue T)
                                 (equal rvalue T)
                                 (equal lvalue T)
                                 (equal fvalue T)
                                 (equal bvalue T))
                             (not (equal (nth jo sem-keys)
                                         (find (nth jo sem-keys)
                                           elem :test #'equal))))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-tr)) :id (+ (+ jo jindex) 1000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-right)) :id (+ (+ jo jindex) 2000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-left)) :id (+ (+ jo jindex) 3000))
                         (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-front)) :id (+ (+ jo jindex) 4000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-back )) :id (+ (+ jo jindex) 5000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-up)) :id (+ (+ jo jindex) 6000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-down)) :id (+ (+ jo jindex) 7000))
                        (setf elem (append (list (nth jo sem-keys)) elem)))
                        
                       (t
                    ;    (format t "~a~% und ~a~%" rpoint lpoint)
                         (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-tr)) :id (+ (+ jo jindex) 11000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-right)) :id (+ (+ jo jindex) 22000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-left)) :id (+ (+ jo jindex) 33000))
                         (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-front)) :id (+ (+ jo jindex) 44000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-back )) :id (+ (+ jo jindex) 55000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-up)) :id (+ (+ jo jindex) 66000))
                        (location-costmap:publish-point  (cl-transforms:origin (nth jindex liste-down)) :id (+ (+ jo jindex) 77000))                      
                          )))))
            ;(return)))
     
              (swm->intern-tf-remover)
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
  (cram-semantic-map-costmap::get-aabb min-vec max-vec)))
         
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
                 
      
;; getting all the objects close to the rescuer...
(defun give-objs-close-to-human (distance position)
  (format t "Give objs close to human ~%")
  (sem-map-utils:get-semantic-map)
  (let*((liste-name NIL)
        (liste-pose NIL)
        (liste-dim NIL)
        (list-all NIL)
        (var 0)
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
;; (defun give-obj-pointed-at (vec)
;;   (let*((*gesture* vec)
;;         (ret NIL))
;;     (give-objs-close-to-human *distance* (get-genius-pose->map-frame "genius_link"))
;;     (setf ret (get-the-direction vec))
;;     (car ret)))



;; visualization in rviz and computation of the gesture 
(defun get-the-direction (point)
 ;; (format t "pointi ~a~%" point)
(let*((elem NIL)
      (eps 0)
      (var 0)
      (value NIL))
  (loop for index in '(0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 10.5 11 11.5 12 12.5 13 13.5 14 14.5 15 15.5 16 16.5 17 17.5 18 18.5 19 19.5 20 20.5 21 21.5 22)
        do(let*((new-point (get-gesture->relative-genius (cl-transforms:make-3d-vector (+ (cl-transforms:x point) index)
                                                                                       (cl-transforms:y point)
                                                                                       (+ (cl-transforms:z point) 1.5)))))
            (setf eps (+ eps 1))
          ;;  (format t "new-pint ~a~%" new-point)
            (if (equal elem NIL)
                (set-my-marker new-point eps)
                (setf var 1))
            (dotimes(jo (list-length *liste-name*))
               (let* ((elem1 (first (get-bbox-as-aabb jo)))
                      (elem2 (second (get-bbox-as-aabb jo))))
                    (setf value
                     (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point)))
                 (cond ((and (equal value T)
                             (not (equal (car (nthcdr jo *liste-name*))
                                         (find (car (nthcdr jo *liste-name*))
                                               elem :test #'equal))))
                        (setf *collision-point* new-point)
                        (setf elem (append (list (car (nthcdr jo *liste-name*))) elem)))
                       (t (setf var 0)))))))
            elem))

(defun set-my-marker (pose index)
;; (format t "set marker with point is ~a~%" pose)
  (location-costmap::publish-pose pose :id (+ 500 index)))                           

(defun visualize-world()
  (let* ((liste (swm->geopose-elements))
         (pose NIL)(pose1 NIL)(pose2 NIL))
    (loop for index from 0 to (- (length liste) 1)
          do(setf pose (cl-transforms:origin (third (nth index liste))))
            (setf pose1 (cl-transforms:make-3d-vector (cl-transforms:x pose)
                                                      (cl-transforms:y pose)
                                                      (+ 0.5 (cl-transforms:z pose))))
            (setf pose2 (cl-transforms:make-3d-vector (cl-transforms:x pose)
                                                      (cl-transforms:y pose )
                                                      (+ 1.0 (cl-transforms:z pose))))
        ;  (format t "pose ~a~%" pose)            (format t "pose2 ~a~%" pose2)            (format t "pose1 ~a~%" pose1)
          (setf instruct-mission::*geo-list* liste)
            (location-costmap::publish-point pose :id (+ 5000 index))
            (location-costmap::publish-point pose1 :id (+ 5100 index))
            (location-costmap::publish-point pose2 :id (+ 5110 index)))))

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





(defun all-ups (liste)
  (format t "all-ups~%")
  (let*((test '()))
     (format t "all-ups2~%")
    (dotimes (index (length liste))
       (format t "all-ups2 ~a~%"(nth index liste))
      (setf test (cons 
            (cl-transforms:make-pose
             (cl-transforms:make-3d-vector (cl-transforms:x (cl-transforms:origin (nth index liste)))
                                           (cl-transforms:y (cl-transforms:origin (nth index liste)))
                                           (+ (cl-transforms:z (cl-transforms:origin (nth index liste))) 1))
             (cl-transforms:orientation (nth index liste))) test))
       (format t "all-upwewews~%"))
    (reverse test)))
                                          
            

(defun all-downs (liste)
    (format t "all-downs~%")
   (let*((test '()))
    (dotimes (index (length liste))
      (setf test (cons 
            (cl-transforms:make-pose
             (cl-transforms:make-3d-vector (cl-transforms:x (cl-transforms:origin (nth index liste)))
                                           (cl-transforms:y (cl-transforms:origin (nth index liste)))
                                           (- (cl-transforms:z (cl-transforms:origin (nth index liste))) 1))
             (cl-transforms:orientation (nth index liste))) test)))
    (reverse test)))

(defun all-rights (liste)
  (format t "all-rights~%")
    (let*((test '()))
    (dotimes (index (length liste))
      (setf test (cons 
            (cl-transforms:make-pose
             (cl-transforms:make-3d-vector (cl-transforms:x (cl-transforms:origin (nth index liste)))
                                           (+ (cl-transforms:y (cl-transforms:origin (nth index liste))) 1)
                                           (cl-transforms:z (cl-transforms:origin (nth index liste))))
             (cl-transforms:orientation (nth index liste))) test))
      (format t "END MORPG~%")
      )
    (reverse test)))

(defun all-lefts (liste)
  (format t "all-lefts~%")
    (let*((test '()))
    (dotimes (index (length liste))
      (setf test (cons 
            (cl-transforms:make-pose
             (cl-transforms:make-3d-vector (cl-transforms:x (cl-transforms:origin (nth index liste)))
                                           (- (cl-transforms:y (cl-transforms:origin (nth index liste))) 1)
                                           (cl-transforms:z (cl-transforms:origin (nth index liste))))
             (cl-transforms:orientation (nth index liste))) test)))
    (reverse test)))

(defun all-fronts (liste)
  (format t "all-fronts~%")
  (let*((test '()))
    (dotimes (index (length liste))
      (setf test (cons 
            (cl-transforms:make-pose
             (cl-transforms:make-3d-vector (+ (cl-transforms:x (cl-transforms:origin (nth index liste))) 1)
                                           (cl-transforms:y (cl-transforms:origin (nth index liste)))
                                           (cl-transforms:z (cl-transforms:origin (nth index liste))))
            (cl-transforms:orientation (nth index liste))) test)))
    (reverse test)))

(defun all-backs (liste)
  (format t "all-backs~%")
    (let*((test '()))
    (dotimes (index (length liste))
      (setf test (cons 
            (cl-transforms:make-pose
             (cl-transforms:make-3d-vector (- (cl-transforms:x (cl-transforms:origin (nth index liste))) 1)
                                           (cl-transforms:y (cl-transforms:origin (nth index liste)))
                                           (cl-transforms:z (cl-transforms:origin (nth index liste))))
             (cl-transforms:orientation (nth index liste))) test)))
    (reverse test)))
