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
  (let*((gen-pose (instruct-mission::swm->get-cartesian-pose-agent "genius"));;(get-genius-pose->map-frame "genius_link")) ;;(instruct-mission::swm->get-cartesian-pose-agent "genius"))
        (pub (cl-tf:make-transform-broadcaster)))
    (format t "gen-pose is ~a~%" gen-pose)
    (cl-tf:send-static-transforms pub 1.0 "meineGeste" (cl-transforms-stamped:make-transform-stamped "map" "genius_link" (roslisp:ros-time)  (cl-transforms:origin gen-pose) (cl-transforms:orientation gen-pose)))))


(defun swm->get-gesture->relative-genius (gesture-vec) 
;;(format t "GESTURE VEC ~a~%" gesture-vec)
(let*((pose (cl-transforms-stamped:make-pose-stamped "genius_link" 0.0
                                                            gesture-vec
                                                             (cl-transforms:make-identity-rotation))))
 ;; (format t "GENIUS-POOOOSEEE ~a~%" pose)
(cl-transforms-stamped:pose-stamped->pose  (cl-tf:transform-pose *tf* :pose pose :target-frame "map"))))

(defun swm->list-values (num point)
  (let*(( zet 1.0)
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
  (format t "swm->give-obj-pointed-at ~a~%" point)
  (setf var (swm->intern-tf-creater))
  (format t " (swm->intern-tf-creater) ~a~%" var)
  (location-costmap::remove-markers-up-to-index 50)
  (format t "swm->give-obj-pointed-at~%")
 (let*((elem NIL)
       (num (make-list 100))
       (eps 0)
       (var 0)
       (*swm-liste* (instruct-mission::swm->geopose-elements))
       (swm-names (swm->get-names *swm-liste*))
       (value NIL)
       (sem-map (instruct-mission::swm->create-semantic-map))
       (sem-hash (slot-value sem-map 'sem-map-utils:parts))
       (liste-tr (swm->list-values num point)))
   (format t "swm->give-obj-pointed-at")
  (loop for jindex from 0 to (- (length liste-tr) 1)
        do(let*((new-point (nth jindex liste-tr))
                (new-point+z2 (set-height-pose new-point 1.5))
                (new-point+z4 (set-height-pose new-point 3.0))
                (new-point+z6 (set-height-pose new-point 4.5))
                (new-point+z8 (set-height-pose new-point 6.0))
                (new-point+z10 (set-height-pose new-point 7.5))
                (new-point+z12 (set-height-pose new-point 9.0))
                (new-point+z14 (set-height-pose new-point 10.5))
                (new-point+z16 (set-height-pose new-point 12.0))
                (new-point+z18 (set-height-pose new-point 13.5))
                (new-point+z20 (set-height-pose new-point 15.0))
                (new-point+z22 (set-height-pose new-point 16.5))
                (new-point+z24 (set-height-pose new-point 18.0))
                (new-point+z26 (set-height-pose new-point 19.5))
                (new-point+z28 (set-height-pose new-point 21.0))
                (new-point+z30 (set-height-pose new-point 22.5))
                (new-point+z32 (set-height-pose new-point 24.0))
                (new-point+z34 (set-height-pose new-point 25.5))
                (new-point+z36 (set-height-pose new-point 27.0))
                (new-point+z38 (set-height-pose new-point 28.5))
                (new-point+z40 (set-height-pose new-point 30.0))
                (new-point+z42 (set-height-pose new-point 31.5))
                (new-point+z44 (set-height-pose new-point 33.0))
                (new-point+z46 (set-height-pose new-point 34.5))
                (new-point+z48 (set-height-pose new-point 36.0))
                (new-point+z50 (set-height-pose new-point 37.5))
                (new-point+z52 (set-height-pose new-point 39.0))
                (new-point+z54 (set-height-pose new-point 40.5))
                (new-point+z56 (set-height-pose new-point 42.0))
                (new-point+z58 (set-height-pose new-point 43.5))
                (new-point+z60 (set-height-pose new-point 45.0))
                (new-point+z62 (set-height-pose new-point 46.5))
                (new-point+z64 (set-height-pose new-point 48.0))
                (new-point+z66 (set-height-pose new-point 49.5))
                (new-point+z68 (set-height-pose new-point 51.0))
                (new-point-z2 (set-height-pose new-point -1.5))
                (new-point-z4 (set-height-pose new-point -3.0))
                (new-point-z6 (set-height-pose new-point -4.5))
                (new-point-z8 (set-height-pose new-point -6.0))
                (new-point-z10 (set-height-pose new-point -7.5))
                (new-point-z12 (set-height-pose new-point -9.0))
                (new-point-z14 (set-height-pose new-point -10.5))
                (new-point-z16 (set-height-pose new-point -12.0))
                (new-point-z18 (set-height-pose new-point -13.5))
                (new-point-z20 (set-height-pose new-point -15.0))
                (new-point-z22 (set-height-pose new-point -16.5))
                (new-point-z24 (set-height-pose new-point -18.0))
                (new-point-z26 (set-height-pose new-point -19.5))
                (new-point-z28 (set-height-pose new-point -21.0))
                (new-point-z30 (set-height-pose new-point -22.5))
                (new-point-z32 (set-height-pose new-point -24.0))
                (new-point-z34 (set-height-pose new-point -25.5))
                (new-point-z36 (set-height-pose new-point -27.0))
                (new-point-z38 (set-height-pose new-point -28.5))
                (new-point-z40 (set-height-pose new-point -30.0))
                (new-point-z42 (set-height-pose new-point -31.5))
                (new-point-z44 (set-height-pose new-point -33.0))
                (new-point-z46 (set-height-pose new-point -34.5))
                (new-point-z48 (set-height-pose new-point -36.0))
                (new-point-z50 (set-height-pose new-point -37.5))
                (new-point-z52 (set-height-pose new-point -39.0))
                (new-point-z54 (set-height-pose new-point -40.5))
                (new-point-z56 (set-height-pose new-point -42.0))
                (new-point-z58 (set-height-pose new-point -43.5))
                (new-point-z60 (set-height-pose new-point -45.0))
                (new-point-z62 (set-height-pose new-point -46.5))
                (new-point-z64 (set-height-pose new-point -48.0))
                (new-point-z66 (set-height-pose new-point -49.5))
                (new-point-z68 (set-height-pose new-point -51.0))
                (new-point+y2 (set-width-pose new-point 1.5))
                (new-point+y4 (set-width-pose new-point 3.0))
                (new-point+y6 (set-width-pose new-point 4.5))
                (new-point+y8 (set-width-pose new-point 6.0))
                (new-point+y10 (set-width-pose new-point 7.5))
                (new-point+y12 (set-width-pose new-point 9.0))
                (new-point+y14 (set-width-pose new-point 10.5))
                ;; (new-point+y16 (set-width-pose new-point 16))
                ;; (new-point+y18 (set-width-pose new-point 18))
                ;; (new-point+y20 (set-width-pose new-point 20))
                ;; (new-point+y22 (set-width-pose new-point 22))
                ;; (new-point+y24 (set-width-pose new-point 24))
                ;; (new-point+y26 (set-width-pose new-point 26))
                ;; (new-point+y28 (set-width-pose new-point 28))
                ;; (new-point+y30 (set-width-pose new-point 30))
                (new-point-y2 (set-width-pose new-point -1.5))
                (new-point-y4 (set-width-pose new-point -3.0))
                (new-point-y6 (set-width-pose new-point -4.5))
                (new-point-y8 (set-width-pose new-point -6.0))
                (new-point-y10 (set-width-pose new-point -7.5))
                (new-point-y12 (set-width-pose new-point -9.0))
                (new-point-y14 (set-width-pose new-point -10.5))
                ;; (new-point-y16 (set-width-pose new-point -16))
                ;; (new-point-y18 (set-width-pose new-point -18))
                ;; (new-point-y20 (set-width-pose new-point -20))
                ;; (new-point-y22 (set-width-pose new-point -22))
                ;; (new-point-y24 (set-width-pose new-point -24))
                ;; (new-point-y26 (set-width-pose new-point -26))
                ;; (new-point-y28 (set-width-pose new-point -28))
                ;; (new-point-y30 (set-width-pose new-point -30))
                )
            (setf eps (+ eps 1))
            (if (equal elem NIL)
                (set-my-marker new-point eps)
                (setf var 1))
           (format t "eps : ~a~%" eps)
            (dotimes(jo (list-length *swm-liste*))
           
              (let* ((elem1 (first (instruct-mission::swm->get-bbox-as-aabb (nth jo swm-names) sem-hash)))
                     (elem2 (second (instruct-mission::swm->get-bbox-as-aabb (nth jo swm-names) sem-hash))))
                (setf value
                      (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point)))
                (setf value+z2
                      (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z2)))
                (setf value+z4
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z4)))
                (setf value+z6
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z6)))
                (setf value+z8
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z8)))
                (setf value+z10
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z10)))
                (setf value+z12
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z12)))
                (setf value+z14
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z14)))
                (setf value+z16
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z16)))
                (setf value+z18
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z18)))
                (setf value+z20
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z20)))
                (setf value+z22
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z22)))
                (setf value+z24
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z24)))
                (setf value+z26
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z26)))
                (setf value+z28
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z28)))
                (setf value+z30
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z30)))
                (setf value+z32
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z32)))
                (setf value+z34
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z34)))
                (setf value+z36
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z36)))
                (setf value+z38
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z38)))
                (setf value+z40
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z40)))
                (setf value+z42
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z42)))
                (setf value+z44
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z44)))
                (setf value+z46
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z46)))
                (setf value+z48
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z48)))
                 (setf value+z50
                       (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z50)))
                (setf value+z52
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z52)))
                (setf value+z54
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z54)))
                (setf value+z56
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z56)))
                (setf value+z58
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z58)))
                (setf value+z60
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z60)))
                (setf value+z62
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z62)))
                (setf value+z64
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z64)))
                (setf value+z66
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z66)))
                (setf value+z68
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z68)))
                ;; (setf value+z70
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z70)))
                ;; (setf value+z72
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z72)))
                ;; (setf value+z74
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z74)))
                ;; (setf value+z76
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z76)))
                ;; (setf value+z78
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z78)))
                ;; (setf value+z80
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z80)))
                ;; (setf value+z82
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z82)))
                ;; (setf value+z84
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z84)))
                ;; (setf value+z86
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z86)))
                ;; (setf value+z88
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z88)))
                ;; (setf value+z90
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z90)))
                ;; (setf value+z92
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z92)))
                ;; (setf value+z94
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z94)))
                ;; (setf value+z96
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z96)))
                ;; (setf value+z98
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z98)))
                ;; (setf value+z100
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+z100)))
                (setf value-z2
                      (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z2)))
                (setf value-z4
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z4)))
                (setf value-z6
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z6)))
                (setf value-z8
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z8)))
                (setf value-z10
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z10)))
                (setf value-z12
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z12)))
                (setf value-z14
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z14)))
                (setf value-z16
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z16)))
                (setf value-z18
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z18)))
                (setf value-z20
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z20)))
                (setf value-z22
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z22)))
                (setf value-z24
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z24)))
                (setf value-z26
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z26)))
                (setf value-z28
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z28)))
                (setf value-z30
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z30)))
                (setf value-z32
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z32)))
                (setf value-z34
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z34)))
                (setf value-z36
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z36)))
                (setf value-z38
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z38)))
                (setf value-z40
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z40)))
                (setf value-z42
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z42)))
                (setf value-z44
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z44)))
                (setf value-z46
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z46)))
                (setf value-z48
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z48)))
                (setf value-z50
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z50)))
                (setf value-z52
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z52)))
                (setf value-z54
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z54)))
                (setf value-z56
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z56)))
                (setf value-z58
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z58)))
                (setf value-z60
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z60)))
                (setf value-z62
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z62)))
                (setf value-z64
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z64)))
                (setf value-z66
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z66)))
                (setf value-z68
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z68)))
                ;; (setf value-z70
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z70)))
                ;; (setf value-z72
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z72)))
                ;; (setf value-z74
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z74)))
                ;; (setf value-z76
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z76)))
                ;; (setf value-z78
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z78)))
                ;; (setf value-z80
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z80)))
                ;; (setf value-z82
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z82)))
                ;; (setf value-z84
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z84)))
                ;; (setf value-z86
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z86)))
                ;; (setf value-z88
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z88)))
                ;; (setf value-z90
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z90)))
                ;; (setf value-z92
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z92)))
                ;; (setf value-z94
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z94)))
                ;; (setf value-z96
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z96)))
                ;; (setf value-z98
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z98)))
                ;; (setf value-z100
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-z100)))
                (setf value+y2
                      (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y2)))
                (setf value+y4
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y4)))
                (setf value+y6
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y6)))
                (setf value+y8
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y8)))
                (setf value+y10
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y10)))
                (setf value+y12
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y12)))
                (setf value+y14
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y14)))
                ;; (setf value+y16
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y16)))
                ;; (setf value+y18
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y18)))
                ;; (setf value+y20
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y20)))
                ;; (setf value+y22
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y22)))
                ;; (setf value+y24
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y24)))
                ;; (setf value+y26
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y26)))
                ;; (setf value+y28
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y28)))
                ;; (setf value+y30
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point+y30)))
                 (setf value-y2
                      (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y2)))
                (setf value-y4
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y4)))
                (setf value-y6
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y6)))
                (setf value-y8
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y8)))
                (setf value-y10
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y10)))
                (setf value-y12
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y12)))
                (setf value-y14
                           (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y14)))
                ;; (setf value-y16
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y16)))
                ;; (setf value-y18
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y18)))
                ;; (setf value-y20
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y20)))
                ;; (setf value-y22
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y22)))
                ;; (setf value-y24
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y24)))
                ;; (setf value-y26
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y26)))
                ;; (setf value-y28
                ;;            (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y28)))
                ;; (setf value-y30
                ;;       (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point-y30)))
                
                 (cond ((and (or (equal value T)
                                 (equal value+z2 T)
                                 (equal value+z4 T)
                                 (equal value+z6 T)
                                 (equal value+z8 T)
                                 (equal value+z10 T)
                                 (equal value+z12 T)
                                 (equal value+z14 T)
                                 (equal value+z16 T)
                                 (equal value+z18 T)
                                 (equal value+z20 T)
                                 (equal value+z22 T)
                                 (equal value+z24 T)
                                 (equal value+z26 T)
                                 (equal value+z28 T)
                                 (equal value+z30 T)
                                 (equal value+z32 T)
                                 (equal value+z34 T)
                                 (equal value+z36 T)
                                 (equal value+z38 T)
                                 (equal value+z40 T)
                                 (equal value+z42 T)
                                 (equal value+z44 T)
                                 (equal value+z46 T)
                                 (equal value+z48 T)
                                 (equal value+z50 T)
                                 (equal value+z52 T)
                                 (equal value+z54 T)
                                 (equal value+z56 T)
                                 (equal value+z58 T)
                                 (equal value+z60 T)
                                 (equal value+z62 T)
                                 (equal value+z64 T)
                                 (equal value+z66 T)
                                 (equal value+z68 T)
                                 (equal value-z2 T)
                                 (equal value-z4 T)
                                 (equal value-z6 T)
                                 (equal value-z8 T)
                                 (equal value-z10 T)
                                 (equal value-z12 T)
                                 (equal value-z14 T)
                                 (equal value-z16 T)
                                 (equal value-z18 T)
                                 (equal value-z20 T)
                                 (equal value-z22 T)
                                 (equal value-z24 T)
                                 (equal value-z26 T)
                                 (equal value-z28 T)
                                 (equal value-z30 T)
                                 (equal value-z32 T)
                                 (equal value-z34 T)
                                 (equal value-z36 T)
                                 (equal value-z38 T)
                                 (equal value-z40 T)
                                 (equal value-z42 T)
                                 (equal value-z44 T)
                                 (equal value-z46 T)
                                 (equal value-z48 T)
                                 (equal value-z50 T)
                                 (equal value-z52 T)
                                 (equal value-z54 T)
                                 (equal value-z56 T)
                                 (equal value-z58 T)
                                 (equal value-z60 T)
                                 (equal value-z62 T)
                                 (equal value-z64 T)
                                 (equal value-z66 T)
                                 (equal value-z68 T)
                                 (equal value-y2 T)
                                 (equal value-y4 T)
                                 (equal value-y6 T)
                                 (equal value-y8 T)
                                 (equal value-y10 T)
                                 (equal value-y12 T)
                                 (equal value-y14 T)
                                 (equal value+y2 T)
                                 (equal value+y4 T)
                                 (equal value+y6 T)
                                 (equal value+y8 T)
                                 (equal value+y10 T)
                                 (equal value+y12 T)
                                 (equal value+y14 T)
                                 )
                             (not (equal (nth jo swm-names)
                                         (find (nth jo swm-names)
                                               elem :test #'equal))))
                        (setf *collision-point* new-point)
                        (set-my-marker new-point 1000)
                        (setf elem (append (list (nth jo swm-names)) elem)))
                       (t (setf var 1)))))))
   (format t "elem is ~a~%" elem)
   (swm->intern-tf-remover)
             (last elem))) 


  

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
(format t "swm->intern-tf-remover~%")
(cl-tf::unadvertise "/tf"))

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
