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
 ;; (location-costmap::publish-point (first  (semantic-map-costmap::get-aabb min-vec max-vec)) :id (+ (+ 200 *s*) 0))
  ;; (location-costmap::publish-point (second (semantic-map-costmap::get-aabb min-vec max-vec)) :id (+ (+ 200 *s*) 1))
  ;;(setf *s* (+ *s* 1))
    (semantic-map-costmap::get-aabb min-vec max-vec)))
         
         
      
;; the parameter is a point which will be given by the human rescuer...
(defun give-objs-close-to-human (distance position)
  (let*((liste-name NIL)
        (liste-pose NIL)
        (liste-dim NIL)
        (list-all NIL)
        (sem-hash (slot-value (sem-map-utils:get-semantic-map) 'sem-map-utils:parts))
        (keys (hash-keys sem-hash)))
    (loop for i in keys
          do (cond ((and T
                         (compare-distance-with-genius-position
                          position (slot-value (gethash i sem-hash) 'sem-map-utils:pose)
                          distance))
                    (setf liste-name
                          (append liste-name
                                  (list i)))
                    (setf liste-pose
                          (append liste-pose
                                  (list 
                                   (slot-value (gethash i sem-hash) 'sem-map-utils:pose))))
                    (setf liste-dim
                          (append liste-dim
                                  (list 
                                   (slot-value (gethash i sem-hash) 'sem-map-utils:dimensions))))
                    (setf list-all
                          (append list-all
                                  (list
                                   (list i 
                                         (slot-value (gethash i sem-hash) 'sem-map-utils:pose)
                                         (slot-value (gethash i sem-hash) 'sem-map-utils:dimensions))))))
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
        (x-point (cl-transforms:x
                  (cl-transforms:origin human-pose)))
        (ret NIL))
    ;; (format t "getting *gesture* ~a~%" *gesture*)
    (give-objs-close-to-human 50 human-pose)
    (cond ((> x-point (cl-transforms:x point))  
           (setf ret (go-into-neg-direction point (cl-transforms:origin human-pose))))
          ((< x-point (cl-transforms:x point))   
           (setf ret (go-into-pos-direction point (cl-transforms:origin human-pose))))
          ((= x-point (cl-transforms:x point))   
           (setf ret (go-into-pos-direction2 point (cl-transforms:origin human-pose))))
          (t (format t "fertig!~%")))
    (car ret)))

;; Go into a negative direction, because x < 0
(defun go-into-neg-direction (point human-origin)
(let*((elem NIL)
      (eps 0))
  (loop for index in  '(-1 -2 -3 -4 -5
                       -6 -7 -8 -9 -10
                       -11 -12 -13 -14
                       -15 -16 -17 -18 -19)
        do(cond((= (cl-transforms:y human-origin) (cl-transforms:y point))
                (setf eps 0))
                ((< (cl-transforms:y human-origin) (cl-transforms:y point))
                 (setf eps (+ 0.8 eps)))
                 (t (setf eps (- eps 0.8))))
           (let*((new-point (cl-transforms:make-3d-vector (+ (cl-transforms:x point) index)
                                                          (+ (cl-transforms:y point) eps)
                                                          (cl-transforms:z point))))
             (dotimes(jo (list-length *liste-name*))
               (let* ((elem1 (first (get-bbox-as-aabb jo)))
                      (elem2 (second (get-bbox-as-aabb jo))))
                 (set-my-markers new-point human-origin index)
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


(defun go-into-pos-direction2 (point human-origin)
(let*((elem NIL)
      (eps 0))
  (loop for index in '(1 2 3 4 5
                       6 7 8 9 10
                       11 12 13 14
                       15 16 17 18)
        do(cond((= (cl-transforms:y human-origin) (cl-transforms:y point))
                (setf eps 0))
                ((< (cl-transforms:y human-origin) (cl-transforms:y point))
                 (setf eps (+ 0.8 eps)))
                 (t (setf eps (- eps 0.8))))
           (let*((new-point (cl-transforms:make-3d-vector (cl-transforms:x point)
                                                          (+ (cl-transforms:y point) eps)
                                                          (cl-transforms:z point))))
             (dotimes(jo (list-length *liste-name*))
               (let* ((elem1 (first (get-bbox-as-aabb jo)))
                      (elem2 (second (get-bbox-as-aabb jo))))
           ;      (format t "what is new ppoint ~a~%" new-point)
                 (set-my-markers new-point human-origin index)
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

(defun go-into-pos-direction (point human-origin)
(let*((elem NIL)
      (eps 0))
  (loop for index in '(1 2 3 4 5
                       6 7 8 9 10
                       11 12 13 14
                       15 16 17 18)
       do(cond((= (cl-transforms:y human-origin) (cl-transforms:y point))
                (setf eps 0))
                ((< (cl-transforms:y human-origin) (cl-transforms:y point))
                 (setf eps (+ 0.8 eps)))
                 (t (setf eps (- eps 0.8))))
           (let*((new-point (cl-transforms:make-3d-vector (+ (cl-transforms:x point) index)
                                                          (+ (cl-transforms:y point) eps)
                                                          (cl-transforms:z point))))
             (dotimes(jo (list-length *liste-name*))
               (let* ((elem1 (first (get-bbox-as-aabb jo)))
                      (elem2 (second (get-bbox-as-aabb jo))))
           ;      (format t "what is new ppoint ~a~%" new-point)
                 (set-my-markers new-point human-origin index)
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

(defun set-my-markers (A-point human-origin i)
 ;; (format t "A-point ~a and index ~a~%" A-point i)
  (cond ((and (> (cl-transforms:x human-origin) (cl-transforms:x A-point)) 
              (= (cl-transforms:y human-origin) (cl-transforms:y A-point)))
         (x-smaller-marker i A-point))
        ((and (< (cl-transforms:x human-origin) (cl-transforms:x A-point)) 
              (= (cl-transforms:y human-origin) (cl-transforms:y A-point)))
         (x-taller-marker i A-point))
        ((and (> (cl-transforms:x human-origin) (cl-transforms:x A-point))
              (> (cl-transforms:y human-origin) (cl-transforms:y A-point)))
         (x-smaller-y-smaller-marker i A-point))
        ((and (> (cl-transforms:x human-origin) (cl-transforms:x A-point))
              (< (cl-transforms:y human-origin) (cl-transforms:y A-point)))
         (x-smaller-y-taller-marker i A-point))
        ((and (< (cl-transforms:x human-origin) (cl-transforms:x A-point))
              (> (cl-transforms:y human-origin) (cl-transforms:y A-point)))
         (x-taller-y-smaller-marker i A-point))
        ((and (< (cl-transforms:x human-origin) (cl-transforms:x A-point))
              (< (cl-transforms:y human-origin) (cl-transforms:y A-point)))
         (x-taller-y-taller-marker i A-point))
        ((and (= (cl-transforms:x human-origin) (cl-transforms:x A-point))
              (> (cl-transforms:y human-origin) (cl-transforms:y A-point)))
         (x-fix-y-smaller-marker i A-point))
        ((and (= (cl-transforms:x human-origin) (cl-transforms:x A-point))
              (< (cl-transforms:y human-origin) (cl-transforms:y A-point)))
         (x-fix-y-taller-marker i A-point))
        (t (format t "Please give another gesture~%"))))

(defun x-smaller-marker (index A-point)
;;(format t "x-straight-marker~%")  
  (let* ((iks (* index (- 1))))
     (loop for j from 0 to iks
           do(let* ((posi-a (cl-transforms:make-3d-vector (- (cl-transforms:x *gesture*) j)
                                                          (cl-transforms:y *gesture*)
                                                          (cl-transforms:z A-point))))
               (location-costmap::publish-point posi-a :id (+ 500 j))))))

(defun x-taller-marker (index A-point)
;;(format t "x-negstraight-marker~%")  
  (let* ((iks index))
     (loop for j from 0 to iks
           do(let* ((posi-a (cl-transforms:make-3d-vector (+ (cl-transforms:x *gesture*) j)
                                                          (cl-transforms:y *gesture*)
                                                          (cl-transforms:z A-point))))
               (location-costmap::publish-point posi-a :id (+ 500 j))))))

(defun x-smaller-y-smaller-marker (index A-point)
;;(format t "x-smaller-y-smaller-marker~%")  
  (let* ((iks (* index (- 1)))
          (posi-a (cl-transforms:make-3d-vector 0 0 0)))
     (loop for j from 0 to iks
           do(cond((or (< (cl-transforms:y posi-a) (cl-transforms:y A-point))
                       (= (cl-transforms:y posi-a) (cl-transforms:y A-point)))
                   (setf posi-a (cl-transforms:make-3d-vector (- (cl-transforms:x *gesture*) j)
                                                              (cl-transforms:y posi-a) 
                                                              (cl-transforms:z A-point))))
                  (t (setf posi-a (cl-transforms:make-3d-vector (- (cl-transforms:x *gesture*) j)
                                                                (- (cl-transforms:y *gesture*) (- j 0.95))
                                                                (cl-transforms:z A-point)))))
           (location-costmap::publish-point posi-a :id (+ 500 j)))))        

(defun x-smaller-y-taller-marker (index A-point)
;;  (format t "x-smaller-y-taller-marker~%")  
   (let* ((iks (* index (- 1)))
          (posi-a (cl-transforms:make-3d-vector 0 0 0)))
     (loop for j from 0 to iks
           do(cond((or (> (cl-transforms:y posi-a) (cl-transforms:y A-point))
                       (= (cl-transforms:y posi-a) (cl-transforms:y A-point)))
                   (setf posi-a (cl-transforms:make-3d-vector (- (cl-transforms:x *gesture*) j)
                                                              (cl-transforms:y posi-a) 
                                                              (cl-transforms:z A-point))))
                  (t (setf posi-a (cl-transforms:make-3d-vector (- (cl-transforms:x *gesture*) j)
                                                                (+ (cl-transforms:y *gesture*) (- j 0.98))
                                                                (cl-transforms:z A-point)))))
           (location-costmap::publish-point posi-a :id (+ 500 j)))))

(defun x-taller-y-smaller-marker (index A-point)
;;  (format t "x-taller-y-smaller-marker~%")  
  (let* ((iks  index))
    (loop for j from 0 to iks
          do(let* ((posi-a (cl-transforms:make-3d-vector (+ (cl-transforms:x *gesture*) j)
                                                         (- (cl-transforms:y *gesture*) (- j 0.95))
                    (cl-transforms:z A-point))))
              (location-costmap::publish-point posi-a :id (+ 500 j))))))

(defun x-taller-y-taller-marker (index A-point)
  ;;(format t "x-taller-y-taller-marker~%")
  (let* ((iks  index))
    (loop for j from 0 to iks
          do(let* ((posi-a (cl-transforms:make-3d-vector (+ (cl-transforms:x *gesture*) j)
                                                         (+ (cl-transforms:y *gesture*) (- j 0.95))
                    (cl-transforms:z A-point))))
              (location-costmap::publish-point posi-a :id (+ 500 j))))))

(defun x-fix-y-smaller-marker (index A-point)
;;  (format t "x-fix-y-smaller-marker~%")
  (let* ((iks  index))
    (loop for j from 0 to iks
          do(let* ((posi-a (cl-transforms:make-3d-vector (cl-transforms:x *gesture*)
                                                         (- (cl-transforms:y *gesture*) (- j 0.95))
                    (cl-transforms:z A-point))))
              (location-costmap::publish-point posi-a :id (+ 500 j))))))

(defun x-fix-y-taller-marker (index A-point)
;;  (format t "x-fix-y-taller-marker~%")
  (let* ((iks  index))
    (loop for j from 0 to iks
          do(let* ((posi-a (cl-transforms:make-3d-vector (cl-transforms:x *gesture*)
                                                         (+ (cl-transforms:y *gesture*) (- j 0.95))
                    (cl-transforms:z A-point))))          
              (location-costmap::publish-point posi-a :id (+ 500 j))))))


;;creates 3 points, calls the plane, creates the normal vector, compares with elements in the list

;; (defun create-minus-points (point pose)
;;   (format t "create minus~%")
;;   (let* ((elem NIL))
  
;;     (loop for i in '(-1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12 -13 -14 -15 -16)
;;           do (let* ((line (get-pointing-line point i)))
;;            ;;  (let*((A-point (cl-transforms:make-3d-vector
;;                        ;;     (+ (cl-transforms:x point) i)
;;                        ;;     (+ (cl-transforms:y point) 0.
;;                ;;      (+ (cl-transforms:z point) 0.1)))
;;                   ;;(B-point (cl-transforms:make-3d-vector
;;                     ;;        (+ (cl-transforms:x point) i)
;;                      ;;       (+ (cl-transforms:y point) (- 0.25))
;;                      ;;       (+ (cl-transforms:z point) 0.1)))
;;                 ;;  (normal-plane (3D-plane point A-point B-point)))
;;                (format t "get the pointing line ~a~%" line)
;;           ;;   (set-all-the-marker-functions i A-point B-point pose)
;;               (dotimes(jo (list-length *liste-name*))
;;                 (format t "what is jo ~a~%" jo)
;;                 (setf value

;;                       (get-value-of-nomal-vector-and-pose 
;;                       (obj-layer-calculation
;;                                 (cl-transforms:origin (car (nthcdr jo *liste-pose*)))
;;                                 (cl-transforms:y (car (nthcdr jo *liste-dim*)))
;;                                 (cl-transforms:z (car (nthcdr jo *liste-dim*)))) line))
;;                                 ;;                      value (get-value-of-nomal-vector-and-pose
;;               ;;               normal-plane (equation-plane (cl-transforms:origin (car (nthcdr jo *liste-pose*))) (cl-transforms:z (car (nthcdr jo *liste-dim*))))))
;; ;;(format t "alze ~a and elem in list ~a~%" value  (car (nthcdr jo *liste-name*)))
;;                 (format t "what is n-vector ~a~%" value)
;;                 (if (and (not(equal value 0))
;;                          (equal elem NIL))
;;                     (setf elem (car (nthcdr jo *liste-name*)))
;;                     (format t "ach meno ~a ~%" elem)))))
;;             elem))


;;   (defun create-plus-points (point pose)
;; (format t "create plus~%")
;; (loop for i in '(1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 10.5 11 11.5 12 12.5 13 13.5 14 14.5 15 15.5 16 16.5)
;;         do(let*((A-point (cl-transforms:make-3d-vector
;;                           (- (cl-transforms:x point) i)
;;                           (+ (cl-transforms:y point) 0.15)
;;                           (+ (cl-transforms:z point) 0.1)))
;;                 (B-point (cl-transforms:make-3d-vector
;;                           (- (cl-transforms:x point) i)
;;                           (+ (cl-transforms:y point) (- 0.15))
;;                           (+ (cl-transforms:z point) 0.1)))
;;                 (elem NIL))
;;             (set-all-the-marker-functions i A-point B-point pose)
;;             (setf elem (append elem (list (3D-plane point A-point B-point))))
;;             elem)))

;;   (defun 3D-plane (O-point A-point B-point)
;;     (let*((one-vector (cl-transforms:make-3d-vector (- (cl-transforms:x A-point)
;;                                                        (cl-transforms:x O-point))
;;                                                     (- (cl-transforms:y A-point)
;;                                                        (cl-transforms:y O-point))
;;                                                     (- (cl-transforms:z A-point)
;;                                                        (cl-transforms:z O-point))))
;;           (two-vector (cl-transforms:make-3d-vector (- (cl-transforms:x B-point)
;;                                                        (cl-transforms:x O-point))
;;                                                     (- (cl-transforms:y B-point)
;;                                                        (cl-transforms:y O-point))
;;                                                     (- (cl-transforms:z B-point)
;;                                                        (cl-transforms:z O-point)))))
;;       (get-normal-vector one-vector two-vector)))

;; (defun get-normal-vector (one-vector two-vector)
;;   (format t "one ~a~% and two ~a~%" one-vector two-vector)
;;    (let*((normal-vec (cl-transforms:make-3d-vector (- (* (cl-transforms:y one-vector)
;;                                                          (cl-transforms:z two-vector))
;;                                                       (* (cl-transforms:z one-vector)
;;                                                          (cl-transforms:y two-vector)))
;;                                                    (- (* (cl-transforms:z one-vector)
;;                                                          (cl-transforms:x two-vector))
;;                                                       (* (cl-transforms:x one-vector)
;;                                                          (cl-transforms:z two-vector)))
;;                                                    (- (* (cl-transforms:x one-vector)
;;                                                          (cl-transforms:y two-vector))
;;                                                       (* (cl-transforms:y one-vector)
;;                                                          (cl-transforms:x two-vector))))))
;;      normal-vec))

;; (defun get-value-of-nomal-vector-and-pose (n-vector equation)
;;   (format t "equation is ~a~%" equation)
;;     (format t "n-vector is ~a~%" n-vector)
;;   (let*((n1 (cl-transforms:x n-vector))
;;         (n2 (cl-transforms:y n-vector))
;;         (n3 (cl-transforms:z n-vector))
;;         (e1 (cl-transforms:x equation))
;;         (e2 (cl-transforms:y equation))
;;         (e3 (cl-transforms:z equation))
;;         (n-e-value (+ (* e1 n1) (* e2 n2) (* e3 n3))))
;;     n-e-value))


;; ;; Calculate the layers for the objects in the map
;; (defun obj-layer-calculation (obj-pose dim-y dim-z)
;;   (format t "what is obj-pose ~a~%" obj-pose)
;;  (let*((o-x (cl-transforms:x obj-pose))
;;        (o-y (cl-transforms:y obj-pose))
;;        (o-z (cl-transforms:z obj-pose))
;;        (a-x (cl-transforms:x obj-pose))
;;        (a-y (cl-transforms:y obj-pose))
;;        (a-z (+ dim-z (cl-transforms:z obj-pose)))
;;        (b-x (cl-transforms:x obj-pose))
;;        (b-y (- (cl-transforms:y obj-pose) dim-y))
;;        (b-z (cl-transforms:z obj-pose))
;;        (o-a-vec (cl-transforms:make-3d-vector (- a-x o-x)
;;                                               (- a-y o-y)
;;                                               (- a-z o-z)))
;;        (o-b-vec (cl-transforms:make-3d-vector (- b-x o-x)
;;                                               (- b-y o-y)
;;                                               (- b-z o-z)))
;;        (n-vector (get-normal-vector o-a-vec o-b-vec)))
;;    n-vector))


;; (defun equation-plane (obj-vector dim-z)
;;   (let*((obj-x (cl-transforms:x obj-vector))
;;         (obj-y (cl-transforms:y obj-vector))
;;         (obj-z (cl-transforms:z obj-vector))
;;         (sec-x (- (cl-transforms:x obj-vector) 1))
;;         (sec-y (- (cl-transforms:y obj-vector) 1))
;;         (sec-z (+ dim-z (cl-transforms:z obj-vector))))
;;     (cl-transforms:make-3d-vector (- sec-x obj-x) (- sec-y obj-y) (- sec-z obj-z))))


;; (defun set-all-the-marker-functions (i A-point B-point pose)
;;   (format t "set all the makrer functoion~%")
;;   (let*((posep (cl-transforms:origin pose)))
;;     (set-the-marker-A A-point posep i)
    ;; (set-the-marker-A-1 A-point posep i)
    ;; (set-the-marker-A-2 A-point posep i)
    ;; (set-the-marker-A-3 A-point posep i)
    ;; (set-the-marker-A-4 A-point posep i)
    ;; (set-the-marker-B B-point posep i)
    ;; (set-the-marker-B-1 B-point posep i)
    ;; (set-the-marker-B-2 B-point posep i)
    ;; (set-the-marker-B-3 B-point posep i)
    ;; (set-the-marker-B-4 B-point posep i)
    ;; (format t "set all the makrer functoionss~%")))



;;creates a line with two points and returns the direction vector
;; (defun get-pointing-line (vec i)
;; (let*((o-x (cl-transforms:x vec))
;;       (o-y (cl-transforms:y vec))
;;       (o-z (cl-transforms:z vec))
;;       (a-x (- (cl-transforms:x vec) i))
;;       (a-y (cl-transforms:y vec))
;;       (a-z (+ (cl-transforms:z vec) 0.1))
;;      ;; (ve-A (cl-transforms:make-3d-vector a-x a-y a-z))
;;       (line (cl-transforms:make-3d-vector (- a-x o-x)
;;                                           (- a-y o-y)
;;                                           (- a-z o-z))))
;;       line))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,,,
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (defun set-the-marker-A (A-point pose i)
;; (loop for j from i to 0
;;   do

;;      (loop for k from 1 to 10
;;            do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                                   (cl-transforms:x pose) ) (/ j 10)) (cl-transforms:x pose))
;;                                                          (+ (* (- (cl-transforms:y A-point)
;;                                                                   (cl-transforms:y pose)) j) (cl-transforms:y pose))
;;                                                          (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose))  (* (/ (- k) 10) j)) (cl-transforms:z pose)))))
;;               (format t "posi-a ~a~%" posi-a)
;;               (location-costmap::publish-point posi-a :id (+ 1000 j))
;;       ))))
       
;; (defun set-the-marker-A-1 (A-point pose i)
;;   (loop for j from i to 0
;;         do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                              (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                        (- (+ (* (- (cl-transforms:y A-point)
;;                                                              (cl-transforms:y pose)) j) (cl-transforms:y pose)) 0.3)
;;                                                        (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) j) (cl-transforms:z pose)))))
         
;;             (location-costmap::publish-point posi-a :id (+ 100 j)))))

;; (defun set-the-marker-A-2 (A-point pose i)
;;   (loop for j from 0 to i
;;         do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                              (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                        (- (+ (* (- (cl-transforms:y A-point)
;;                                                              (cl-transforms:y pose)) j) (cl-transforms:y pose)) 0.5)
;;                                                        (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) j) (cl-transforms:z pose)))))
           
;;             (location-costmap::publish-point posi-a :id (+ 600 j)))))

;; (defun set-the-marker-A-3 (A-point pose i)
;;   (loop for j from 0 to i
;;         do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                              (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                        (- (+ (* (- (cl-transforms:y A-point)
;;                                                              (cl-transforms:y pose)) j) (cl-transforms:y pose)) 0.7)
;;                                                        (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) j) (cl-transforms:z pose)))))
         
;;             (location-costmap::publish-point posi-a :id (+ 700 j)))))


;; (defun set-the-marker-A-4 (A-point pose i)
;;   (loop for j from 0 to i
;;         do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                              (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                        (- (+ (* (- (cl-transforms:y A-point)
;;                                                              (cl-transforms:y pose)) j) (cl-transforms:y pose)) 0.9)
;;                                                        (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) (* (- 1 j))) (cl-transforms:z pose)))))
           
;;             (location-costmap::publish-point posi-a :id (+ 800 j)))))

;; (defun set-the-marker-B (A-point pose i)
;;   (loop for j from 0 to i
;;         do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                              (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                        (+ (* (- (cl-transforms:y A-point)
;;                                                              (cl-transforms:y pose)) j) (cl-transforms:y pose)) 
;;                                                        (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) j) (cl-transforms:z pose)))))
          
;;             (location-costmap::publish-point posi-a :id (+ 200 j)))))

;; (defun set-the-marker-B-1 (A-point pose i)
;;   (loop for j from 0 to i
;;         do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                              (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                        (+ (+ (* (- (cl-transforms:y A-point)
;;                                                              (cl-transforms:y pose)) j) (cl-transforms:y pose)) 0.3) 
;;                                                        (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) j) (cl-transforms:z pose)))))
        
;;             (location-costmap::publish-point posi-a :id (+ 200 j)))))


;; (defun set-the-marker-B-2 (A-point pose i)
;;   (loop for j from 0 to i
;;         do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                              (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                       (+ (+ (* (- (cl-transforms:y A-point)
;;                                                              (cl-transforms:y pose)) j) (cl-transforms:y pose)) 0.5) 
;;                                                        (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) j) (cl-transforms:z pose)))))
          
;;             (location-costmap::publish-point posi-a :id (+ 400 j)))))

;; (defun set-the-marker-B-3 (A-point pose i)
;;   (loop for j from 0 to i
;;         do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                              (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                       (+ (+ (* (- (cl-transforms:y A-point)
;;                                                              (cl-transforms:y pose)) j) (cl-transforms:y pose)) 0.7) 
;;                                                        (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) j) (cl-transforms:z pose)))))
;;            (format t "posi-a ~a~%" posi-a)
;;             (location-costmap::publish-point posi-a :id (+ 500 j)))))

;; (defun set-the-marker-B-4 (A-point pose i)
;;     (loop for j from 0 to i
;;           do(let* ((posi-a (cl-transforms:make-3d-vector (+ (* (- (cl-transforms:x A-point)
;;                                                                   (cl-transforms:x pose) ) j) (cl-transforms:x pose))
;;                                                             (+ (+ (* (- (cl-transforms:y A-point)
;;                                                                         (cl-transforms:y pose)) j) (cl-transforms:y pose)) 0.9) 
;;                                                             (+ (* (- (cl-transforms:z A-point)                                                                                                                                         (cl-transforms:z pose)) (* (- 1) j)) (cl-transforms:z pose)))))
;;               (format t "posieee-a ~a~%" posi-a)
;;               (location-costmap::publish-point posi-a :id (+ 500 j)))))

