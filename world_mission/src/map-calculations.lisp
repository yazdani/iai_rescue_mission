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

(in-package :world-mission)

(defvar *get-semantic-map*)



(defun swm->bbox-sum (name sem-hash)
  (let*((liste (swm->get-bbox-as-aabb name sem-hash))
        (erst (first liste))
        (zweit (second liste))
        (sum NIL))
    (setf sum (+ (+ (cl-transforms:x erst) (cl-transforms:x zweit))
                 (+ (cl-transforms:y erst) (cl-transforms:y zweit))
                 (+ (cl-transforms:z erst) (cl-transforms:z zweit))))
    sum))

(defun hash-table-keys (hash-table)
                   "Return a list of keys in HASH-TABLE."
                   (let ((keys '()))
                     (maphash (lambda (k _v) (push k keys)) hash-table)
                     keys))

(defun swm->objects-next-human (distance pose sem-map)
  ;;(format t "func(): swm->objects-next-human~%")
  (let* ((new-liste (visualize-plane (cl-transforms:origin pose) distance))
         (sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
         (elem NIL)
         (incrementer 1)
         (value NIL))
    (dotimes (index (length new-liste))
      do(let*((new-point (nth index new-liste))
               (smarter (+ (* 10 incrementer) index)))
               (loop for jndex from 0 to (- (length sem-keys) 1)
                     do(let* ((elem1 (first (swm->get-bbox-as-aabb (nth jndex sem-keys) sem-hash)))
                              (elem2 (second (swm->get-bbox-as-aabb (nth jndex sem-keys) sem-hash)))
                              (smarter (+ smarter jndex)))
                         (setf value
                               (semantic-map-costmap::inside-aabb elem1 elem2 new-point))
                         (cond ((equal value T)
                                ;;(swm->publish-point new-point :id smarter :r 1.0 :g 1.0 :b 0.0 :a 0.9)
                                (setf elem (append (list (nth jndex sem-keys)) elem))
                                (remove-duplicates elem)
                                (return))
                               (t;;(swm->publish-point  new-point :id smarter :r 1.0 :g 0.0 :b 0.0 :a 0.9))))
                                )))
                       ;;(swm->publish-point new-point :id (+ smarter jndex) :r 1.0 :g 0.0 :b 0.0 :a 0.9)
		       (setf incrementer (+ incrementer 2))))) 
             (reverse (remove-duplicates elem))))



(defun swm->get-cartesian-pose-agent (agent)
  (let* ((pose (swm->get-geopose-agent agent)) ;;(cl-transforms:make-pose (cl-transforms:make-3d-vector 44.1533088684 12.2414226532 42.7000007629) (cl-transforms:make-quaternion 0 0 0 1))) ;;(swm->get-geopose-agent agent))
     
        (call (roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg pose))))
        (format t "~a~%" pose)
   (splitgeometry->pose call)))


(defun swm->get-geopose-agent (agent)
  (let* ((array (json-prolog:prolog  `("swm_AgentsData" ,agent ?agent)))
         (str-pose (symbol-name (cdaar array)))
         (seq (cddr (split-sequence:split-sequence #\[ str-pose)))
         (a-seq (first (split-sequence:split-sequence #\] (first seq))))
         (b-seq (first (split-sequence:split-sequence #\] (second seq))))
         (a-nums (split-sequence:split-sequence #\, a-seq))
         (b-nums (split-sequence:split-sequence #\, b-seq)))
    ;;(format t "(typeof) ~a and ~a ~%" b-nums a-nums)
        (cl-transforms:make-pose (cl-transforms:make-3d-vector
                                        (read-from-string (first a-nums))
                                        (read-from-string (second a-nums))
                                        (read-from-string (third a-nums)))
                                       (cl-transforms:make-quaternion
                                        (read-from-string (first b-nums))
                                        (read-from-string (second b-nums))
                                        (read-from-string (third b-nums))
                                        (read-from-string (fourth b-nums))))))

(defun swm->publish-elements-tf ()
  (let*((elems *geo-list*);(swm->geopose-elements))
        (pub (cl-tf:make-transform-broadcaster)))
    (loop for i from 0 to (- 1 (length elems))
          do(let*((frame-id (nth 0 (nth i elems)))
                  (ori (cl-transforms:origin (nth 1 (nth i elems))))
                  (qua (cl-transforms:orientation (nth 1 (nth i elems)))))
             (cl-tf:send-transforms pub (cl-transforms-stamped:make-transform-stamped "map"  frame-id (roslisp:ros-time) ori qua))))))



;;;;;;;;;;;;;;;;;;;; SEMANTIC MAP CALCULATIONS


;;
;; Getting the smallest object inside the map
;;

(defun calculate-small-object (sem-map)
  (let*((sem-hash (slot-value sem-map 'sem-map-utils:parts))
        (sem-keys (hash-table-keys sem-hash))
        (name (first sem-keys))
        (value (swm->bbox-sum name sem-hash)))
    (loop for index from 1 to (- (length sem-keys) 1)
          do(cond((> value (swm->bbox-sum (nth index sem-keys) sem-hash))
                  (setf name (nth index sem-keys))
                  (setf value (swm->bbox-sum (nth index sem-keys) sem-hash)))
                 (t ())))
    name))


;;
;; Getting the biggest object inside the map
;;
(defun calculate-big-object (sem-map)
  (let*((sem-hash (slot-value sem-map 'sem-map-utils:parts))
        (sem-keys (hash-table-keys sem-hash))
        (name (first sem-keys))
        (value (swm->bbox-sum name sem-hash)))
    (loop for index from 1 to (- (length sem-keys) 1)
          do (cond((< value (swm->bbox-sum (nth index sem-keys) sem-hash))
                  (setf name (nth index sem-keys))
                  (setf value (swm->bbox-sum (nth index sem-keys) sem-hash)))
                 (t ())))
    name))
    

(defun swm->elem-type (name)
 (let*((type NIL)
       (sem-hash (slot-value *get-semantic-map* 'sem-map-utils:parts))
       (sem-keys (hash-table-keys sem-hash)))
       (loop for i from 0 to (- (length sem-keys) 1)
             do(cond ((string-equal name (nth i sem-keys))
                      (setf type (slot-value (gethash name sem-hash)
                                             'cram-semantic-map-utils::type)))
                     (t ())))
   type))

(defun swm->elem-pose (name)
  (let*((pose NIL)
       (sem-hash (slot-value *get-semantic-map* 'sem-map-utils:parts))
       (sem-keys (hash-table-keys sem-hash)))
       (loop for i from 0 to (- (length sem-keys) 1)
             do(cond ((string-equal name (nth i sem-keys))
                      (setf pose (slot-value (gethash name sem-hash)
                                             'cram-semantic-map-utils::pose)))
                     (t ())))
    pose))
 

(defun swm->publish-point (point &key id r g b a)
  (setf *marker-publisher*
        (roslisp:advertise "~location_marker" "visualization_msgs/Marker"))
  (let ((current-index 0))
    (when *marker-publisher*
      (roslisp:publish *marker-publisher*
               (roslisp:make-message "visualization_msgs/Marker"
                             (cl-transforms-stamped::stamp  header) (roslisp:ros-time)
                             (frame_id header) "/map"
                             ns "kipla_locations"
                             id (or id (incf current-index))
                             type (roslisp:symbol-code
                                   'visualization_msgs-msg:<marker> :sphere)
                             action (roslisp:symbol-code
                                     'visualization_msgs-msg:<marker> :add)
                             (x position pose) (cl-transforms:x point)
                             (y position pose) (cl-transforms:y point)
                             (z position pose) (cl-transforms:z point)
                             (w orientation pose) 1.0
                             (x scale) 0.15
                             (y scale) 0.15
                             (z scale) 0.15
                             (r color) r ; (random 1.0)
                             (g color) g ; (random 1.0)
                             (b color) b ; (random 1.0)
                             (a color) a)))))

(defun visualize-plane (point pointer)
;; (format t "func(): visualize-plane ~a~%" point)
  (let* ((temp '()))
 (loop for index from 5 to pointer
       do(loop for smart from 1 to 5
               do(setf new-pointp (cl-transforms:make-3d-vector
                                   (+ (cl-transforms:x point) index)
                                   (cl-transforms:y point)
                                   (cl-transforms:z point)))
                 (setf new-pointm (cl-transforms:make-3d-vector
                                   (+ (cl-transforms:x point) index)
                                   (cl-transforms:y point)
                                   (- (cl-transforms:z point) smart)))
                 (setf new-point (cl-transforms:make-3d-vector
                                  (+ (cl-transforms:x point) index)
                                  (cl-transforms:y point)
                                  (+ (cl-transforms:z point) smart)))
                 (loop for jindex from 1 to 50
                       do (setf A1point (cl-transforms:make-3d-vector
                                         (cl-transforms:x new-point)
                                         (+ (cl-transforms:y new-point) index)
                                         (cl-transforms:z  new-point)))
                        (setf A2point (cl-transforms:make-3d-vector
                                        (cl-transforms:x new-pointp)
                                        (+ (cl-transforms:y new-pointp) jindex)
                                        (cl-transforms:z new-pointp)))
                        (setf A3point (cl-transforms:make-3d-vector
                                       (cl-transforms:x new-pointm)
                                       (+ (cl-transforms:y new-pointm) jindex)
                                       (cl-transforms:z new-pointm)))
                        (setf B1point  (cl-transforms:make-3d-vector
                                        (cl-transforms:x new-point)
                                        (- (cl-transforms:y new-point) jindex)
                                        (cl-transforms:z new-point)))
                        (setf B2point (cl-transforms:make-3d-vector
                                       (cl-transforms:x new-pointp)
                                       (- (cl-transforms:y new-pointp) jindex)
                                       (cl-transforms:z new-pointp)))
                        (setf B3point (cl-transforms:make-3d-vector
                                       (cl-transforms:x new-pointm)
                                       (- (cl-transforms:y new-pointm) jindex)
                                       (cl-transforms:z new-pointm)))
                         (setf C1point (cl-transforms:make-3d-vector
                                        (cl-transforms:x new-point)
                                        (+ (cl-transforms:y new-point) jindex)
                                        (cl-transforms:z new-point)))
                         (setf C2point (cl-transforms:make-3d-vector
                                        (cl-transforms:x new-pointp)
                                        (+ (cl-transforms:y new-pointp) jindex)
                                        (cl-transforms:z new-pointp)))
                         (setf C3point (cl-transforms:make-3d-vector
                                        (cl-transforms:x new-pointm)
                                        (+ (cl-transforms:y new-pointm) jindex)
                                        (cl-transforms:z new-pointm)))
                         (setf D1point (cl-transforms:make-3d-vector
                                        (cl-transforms:x new-point)
                                        (- (cl-transforms:y new-point) jindex)
                                        (cl-transforms:z new-point)))
                         (setf D2point (cl-transforms:make-3d-vector
                                        (cl-transforms:x new-pointp)
                                        (- (cl-transforms:y new-pointp) jindex)
                                        (cl-transforms:z new-pointp)))
                         (setf D3point (cl-transforms:make-3d-vector
                                        (cl-transforms:x new-pointm)
                                        (- (cl-transforms:y new-pointm) jindex)
                                        (cl-transforms:z new-pointm)))
                        (setf temp (cons D3point (cons D2point (cons D1point (cons C3point (cons C2point (cons C1point (cons B3point (cons B2point (cons B1point (cons A3point (cons A2point (cons A1point (cons new-point temp)))))))))))))))));;(cons H1point (cons G1point (cons F1point (cons E1point (cons D1point (cons C1point (cons B1point (cons A1point (cons new-point temp))))))))))))
    (reverse temp))) 


;;; CREATE SEMANTIC MAP
(defun swm->initialize-semantic-map ()
  (let* ((obj (make-instance 'sem-map-utils::semantic-map
                 :parts
                 (swm->hash-function))))
    (setf *get-semantic-map* obj)
    *get-semantic-map*))

(defun swm->hash-function()
  (let*((sem-liste (swm->geopose-elements))
        (intern-liste (internal-semantic-map-geom sem-liste))
        (hasht (make-hash-table :test #'equal)))
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
									:parent NIL
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
                                                   (+ (* (- 1) cl1-x)  cl2-x)
                                                   (cond ((>= cl2-x cl1-x)
                                                          (- cl2-x cl1-x))
                                                         (t (- cl1-x cl2-x)))))
                                           (if (minusp cl2-y)
                                               (if (minusp (+ cl1-y (* (- 1) cl2-y)))
                                                   (* (- 1) (+ cl1-y (* (- 1) cl2-y)))
                                                   (+ cl1-y (* (- 1) cl2-y)))
                                               (if (minusp (+ cl1-y  cl2-y))
                                                   (+ (* (- 1) cl1-y)  cl2-y)
                                                   (cond ((>= cl2-y cl1-y)
                                                          (- cl2-y cl1-y))
                                                         (t (- cl1-y cl2-y)))))
                                           (if (minusp cl2-z)
                                               (if (minusp (+ cl1-z (* (- 1) cl2-z)))
                                                   (* (- 1) (+ cl1-z (* (- 1) cl2-z)))
                                                   (+ cl1-z (* (- 1) cl2-z)))
                                                (if (minusp (+ cl1-z  cl2-z))
                                                    (+ (* (- 1) cl1-z)  cl2-z)
                                                   (cond ((>= cl2-z cl1-z)
                                                          (- cl2-z cl1-z))
                                                         (t (- cl1-z cl2-z))))))))
    vec))

(defun swm->geopose-elements ()
  (setf *swm-liste* NIL)
  (let* ((array  (json-prolog:prolog `("swm_EntitiesData" ?A)))
          (comp (symbol-name (cdaar array)))
          (seq  (cdr (split-sequence:split-sequence #\( comp)))
          (a-seq (cddr seq)))
 (loop for i from 0 to  (length a-seq)
       do (cond ((not (equal (length a-seq) 0))
                 (setf *swm-liste* (append *swm-liste* (list (internal-function (car a-seq)))))
                 (setf a-seq (cdr a-seq)))))
    *swm-liste*))

(defun internal-function (tmp)
  (let*((seq (split-sequence:split-sequence #\, (car (split-sequence:split-sequence #\) tmp))))
        (seq-name (car seq))
        (seq-type (second seq))
        (tmp (cddr seq))
        (c1 (third (split-sequence:split-sequence #\[ (car tmp))))
        (c2 (second tmp))
        (c3 (car (split-sequence:split-sequence #\] (third tmp))))
        (q1 (second (split-sequence:split-sequence #\[ (fourth tmp))))
        (q2 (first (cddddr tmp)))
        (q3 (second (cddddr tmp)))
        (q4 (car (split-sequence:split-sequence #\] (third (cddddr tmp)))))
        (center (cl-transforms:make-pose (cl-transforms:make-3d-vector (read-from-string c1) (read-from-string c2) (read-from-string c3))
                             (cl-transforms:make-quaternion (read-from-string q1) (read-from-string q2) (read-from-string q3) (read-from-string q4))))
   (tmp (cdddr (cddddr tmp)))
         (b1 (third (split-sequence:split-sequence #\[ (car tmp))))
        (b2 (second tmp))
        (b3 (car (split-sequence:split-sequence #\] (third tmp))))
        (bq1 (second (split-sequence:split-sequence #\[ (fourth tmp))))
        (bq2 (first (cddddr tmp)))
        (bq3 (second (cddddr tmp)))
        (bq4 (car (split-sequence:split-sequence #\] (third (cddddr tmp)))))
        (bbox1 (cl-transforms:make-pose (cl-transforms:make-3d-vector (read-from-string b1) (read-from-string b2) (read-from-string b3))
                             (cl-transforms:make-quaternion (read-from-string bq1) (read-from-string bq2) (read-from-string bq3) (read-from-string bq4))))
        (tmp (cdddr (cddddr tmp)))
        (bb1 (third (split-sequence:split-sequence #\[ (car tmp))))
        (bb2 (second tmp))
        (bb3 (car (split-sequence:split-sequence #\] (third tmp))))
        (bbq1 (second (split-sequence:split-sequence #\[ (fourth tmp))))
        (bbq2 (first (cddddr tmp)))
        (bbq3 (second (cddddr tmp)))
        (bbq4 (car (split-sequence:split-sequence #\] (third (cddddr tmp)))))
        (bbox2 (cl-transforms:make-pose (cl-transforms:make-3d-vector
                                         (read-from-string bb1)
                                         (read-from-string bb2)
                                         (read-from-string bb3))
                                        (cl-transforms:make-quaternion
                                         (read-from-string bbq1)
                                         (read-from-string bbq2)
                                         (read-from-string bbq3)
                                         (read-from-string bbq4)))))
    ;;(format t "CENTER center ~a~%" center)
    (list seq-name seq-type 
          (splitgeometry->pose (roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg  center)))
          (splitgeometry->pose(roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg  bbox1)))
          (splitgeometry->pose(roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg  bbox2))))))
        

(defun splitGeometry->pose (test)
  (let* ((sum (slot-value test 'WORLD_MISSION-SRV:SUM))
         (position (slot-value sum 'GEOMETRY_MSGS-MSG:POSITION))
         (ori-x (slot-value position 'GEOMETRY_MSGS-MSG:X))
         (ori-y (slot-value position 'GEOMETRY_MSGS-MSG:Y))
         (ori-z (slot-value position 'GEOMETRY_MSGS-MSG:Z))
         (orientation (slot-value sum 'GEOMETRY_MSGS-MSG:ORIENTATION))
         (qua-x (slot-value orientation 'GEOMETRY_MSGS-MSG:X))
         (qua-y (slot-value orientation 'GEOMETRY_MSGS-MSG:Y))
         (qua-z (slot-value orientation 'GEOMETRY_MSGS-MSG:Z))
         (qua-w (slot-value orientation 'GEOMETRY_MSGS-MSG:W)))
    (cl-transforms:make-pose
     (cl-transforms:make-3d-vector ori-x ori-y 0)
     (cl-transforms:make-quaternion qua-x qua-y qua-z qua-w))))

;; (defun splitGeometry->poses (test)
;;   (let* ((sum (slot-value test 'WORLD_MISSION-SRV:SUM))
;;          (position (slot-value sum 'GEOMETRY_MSGS-MSG:POSITION))
;;          (ori-x (slot-value position 'GEOMETRY_MSGS-MSG:X))
;;          (ori-y (slot-value position 'GEOMETRY_MSGS-MSG:Y))
;;          (ori-z (slot-value position 'GEOMETRY_MSGS-MSG:Z))
;;          (orientation (slot-value sum 'GEOMETRY_MSGS-MSG:ORIENTATION))
;;          (qua-x (slot-value orientation 'GEOMETRY_MSGS-MSG:X))
;;          (qua-y (slot-value orientation 'GEOMETRY_MSGS-MSG:Y))
;;          (qua-z (slot-value orientation 'GEOMETRY_MSGS-MSG:Z))
;;          (qua-w (slot-value orientation 'GEOMETRY_MSGS-MSG:W)))
;;     (cl-transforms:make-pose
;;      (cl-transforms:make-3d-vector ori-x ori-y ori-z)
;;      (cl-transforms:make-quaternion qua-x qua-y qua-z qua-w))))

(defun swm->get-bbox-as-aabb (name sem-hash)
(let*((dim-x (cl-transforms:x (slot-value (gethash name sem-hash) 'sem-map-utils:dimensions)))
      (dim-y (cl-transforms:y (slot-value (gethash name sem-hash) 'sem-map-utils:dimensions)))
      (dim-z (cl-transforms:z (slot-value (gethash name sem-hash) 'sem-map-utils:dimensions)))
      (pose-x (cl-transforms:x (cl-transforms:origin  (slot-value (gethash name sem-hash) 'sem-map-utils:pose))))
       (pose-y (cl-transforms:y (cl-transforms:origin  (slot-value (gethash name sem-hash) 'sem-map-utils:pose))))
      (min-vec (cl-transforms:make-3d-vector (- pose-x (/ dim-x 2))
                                             (- pose-y (/ dim-y 2))
                                             0))
      (max-vec (cl-transforms:make-3d-vector (+ pose-x (/ dim-x 2))
                                             (+ pose-y (/ dim-y 2))
                                             dim-z)))
  (cram-semantic-map-costmap::get-aabb min-vec max-vec)))


;; (defun swm->visualize-poses-close-human ()
;;   (let*((pose (swm->get-cartesian-pose-agent "genius"))
;;         (ori (cl-transforms:origin pose))
;;         (quat (cl-transforms:orientation pose))
;;         (dist-pose (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                              (+ (cl-transforms:x ori) 5)
;;                                              (cl-transforms:y ori)
;;                                              (cl-transforms:z ori))
;;                                             quat)))
;;     (loop for index from 1 to 250
;;           do(let*((dist-m (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                     (+ (cl-transforms:x (cl-transforms:origin dist-pose)) index)
;;                                                     (cl-transforms:y (cl-transforms:origin dist-pose))
;;                                                     (cl-transforms:z (cl-transforms:origin dist-pose)))
;;                                                    quat))
;;                   (dist-mu (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                      (cl-transforms:x (cl-transforms:origin dist-pose))
;;                                                     (cl-transforms:y (cl-transforms:origin dist-pose))
;;                                                     (+ (cl-transforms:z (cl-transforms:origin dist-pose)) index))
;;                                                     quat))
;;                   (dist-md (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                      (cl-transforms:x (cl-transforms:origin dist-pose))
;;                                                     (cl-transforms:y (cl-transforms:origin dist-pose))
;;                                                     (- (cl-transforms:z (cl-transforms:origin dist-pose)) index))
;;                                                     quat))
;;                   (dist-mr (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                      (cl-transforms:x (cl-transforms:origin dist-pose))
;;                                                      (- (cl-transforms:y (cl-transforms:origin dist-pose)) index)
;;                                                      (cl-transforms:z (cl-transforms:origin dist-pose)))
;;                                                     quat))
;;                   (dist-mru (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                      (cl-transforms:x (cl-transforms:origin dist-pose))
;;                                                      (- (cl-transforms:y (cl-transforms:origin dist-pose)) index)
;;                                                      (+ (cl-transforms:z (cl-transforms:origin dist-pose)) index))
;;                                                      quat))
;;                   (dist-mrd (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                      (cl-transforms:x (cl-transforms:origin dist-pose))
;;                                                      (- (cl-transforms:y (cl-transforms:origin dist-pose)) index)
;;                                                      (- (cl-transforms:z (cl-transforms:origin dist-pose)) index))
;;                                                      quat))
;;                   (dist-ml (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                      (cl-transforms:x (cl-transforms:origin dist-pose))
;;                                                      (+ (cl-transforms:y (cl-transforms:origin dist-pose)) index)
;;                                                      (cl-transforms:z (cl-transforms:origin dist-pose)))
;;                                                    quat))
;;                   (dist-mlu (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                      (cl-transforms:x (cl-transforms:origin dist-pose))
;;                                                      (+ (cl-transforms:y (cl-transforms:origin dist-pose)) index)
;;                                                      (+ (cl-transforms:z (cl-transforms:origin dist-pose)) index))
;;                                                    quat))
;;                   (dist-mld (cl-transforms:make-pose (cl-transforms:make-3d-vector
;;                                                      (cl-transforms:x (cl-transforms:origin dist-pose))
;;                                                      (+ (cl-transforms:y (cl-transforms:origin dist-pose)) index)
;;                                                      (- (cl-transforms:z (cl-transforms:origin dist-pose)) index))
;;                                                    quat))
