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

(defvar *get-semantic-map*)

;;; CREATE SEMANTIC MAP
(defun swm->initialize-semantic-map ()
  (format t "zeiuhdisdqweer~%")
  (let* ((obj (make-instance 'sem-map-utils::semantic-map
                 :parts
                 (sem-map->hash-function))))
     (format t "zeiuhdisdqweer ~a~%" obj)
    (setf *get-semantic-map* obj)
    *get-semantic-map*))

(defun sem-map->hash-function()
  (let*((sem-liste (swm->geopose-elements))
        (intern-liste (internal-semantic-map-geom sem-liste))
        (hasht (make-hash-table :test #'equal)))
        (mapc (lambda (key-and-geom)
                         (let ((key (first key-and-geom))
                               (geom (second key-and-geom)))
                           (setf (gethash key hasht) geom)))
                       intern-liste)
    hasht))

;;getting the min and max value of a bounding box
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

;;calculating the sum of a boundig box
(defun sem-map->bbox-sum (name sem-hash)
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

;; calculating all objects which are close in front of the human
(defun sem->objects-next-human (distance sem-map)
;;  (format t "func(): swm->objects-next-human ~%")
  (setf *pub* (swm->intern-tf-creater))
  (let* ((new-liste (visualize-plane distance))
         (sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
         (elem NIL)
         (incrementer 1)
         (value NIL))
    (swm->intern-tf-remover)
     ;; (format t "func(): swm->objects-next-human1234~%")
  ;;  (format t "~a~%" new-liste)
    (dotimes (index (length new-liste))
      do(let*((new-point (nth index new-liste))
               (smarter (+ (* 10 incrementer) index)))
               (loop for jndex from 0 to (- (length sem-keys) 1)
                     do(let* ((elem1 (first (swm->get-bbox-as-aabb (nth jndex sem-keys) sem-hash)))
                              (elem2 (second (swm->get-bbox-as-aabb (nth jndex sem-keys) sem-hash)))
                              (smarter (+ smarter jndex)))
                         (setf value
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point)))
                         (cond ((equal value T)
                                ;;(swm->publish-point new-point :id smarter :r 1.0 :g 1.0 :b 0.0 :a 0.9)
                                (setf elem (append (list (nth jndex sem-keys)) elem))
                              ;;  (location-costmap::publish-point (cl-transforms:origin new-point) :id smarter)
                                (remove-duplicates elem)
                                (return))
                               (t;;(swm->publish-point  new-point :id smarter :r 1.0 :g 0.0 :b 0.0 :a 0.9))))
                             ;;   (location-costmap::publish-point (cl-transforms:origin new-point) :id smarter)
                                )))
                       ;;(swm->publish-point new-point :id (+ smarter jndex) :r 1.0 :g 0.0 :b 0.0 :a 0.9)
                       (setf incrementer (+ incrementer 2)))))
    
    (reverse (remove-duplicates elem))))

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


;; (defun visualize-plane (point num)
;; (let* ((temp '())
;;          (ori (cl-transforms:origin point))
;;          (quat (cl-transforms:orientation point)))
;;     (loop for jindex from 5 to num
;;           do (loop for mass from 1 to 10 
;;             do  (let*((new-point2 (cl-transforms:make-pose
;;                                            (cl-transforms:make-3d-vector
;;                                             (+ (cl-transforms:x ori) jindex)
;;                                             (cl-transforms:y ori)
;;                                             (- (cl-transforms:z ori) mass))
;;                                            quat))
;;                       (new-point (cl-transforms:make-pose
;;                                           (cl-transforms:make-3d-vector
;;                                            (+ (cl-transforms:x ori) jindex)
;;                                            (cl-transforms:y ori)
;;                                            (cl-transforms:z ori))
;;                                           quat))
;;                       (new-point1 (cl-transforms:make-pose
;;                                         (cl-transforms:make-3d-vector
;;                                          (+ (cl-transforms:x ori) jindex)
;;                                          (cl-transforms:y ori)
;;                                          (+ (cl-transforms:z ori) mass))
;;                                         quat)))
;;                  (loop for index from 1 to 30
;;                        do
;;                           (setf Apoint (cl-transforms:make-pose
;;                                         (cl-transforms:make-3d-vector
;;                                          (cl-transforms:x (cl-transforms:origin new-point))
;;                                         (+ (cl-transforms:y (cl-transforms:origin new-point)) index)
;;                                         (cl-transforms:z (cl-transforms:origin new-point)))
;;                                         quat))
;;                           (setf Bpoint (cl-transforms:make-pose
;;                                         (cl-transforms:make-3d-vector
;;                                          (cl-transforms:x (cl-transforms:origin new-point))
;;                                         (- (cl-transforms:y (cl-transforms:origin new-point)) index)
;;                                         (cl-transforms:z (cl-transforms:origin new-point)))
;;                                         quat))
;;                           (setf Cpoint (cl-transforms:make-pose
;;                                        (cl-transforms:make-3d-vector
;;                                         (cl-transforms:x (cl-transforms:origin new-point1))
;;                                         (+ (cl-transforms:y (cl-transforms:origin new-point1)) index)
;;                                         (cl-transforms:z (cl-transforms:origin new-point1)))
;;                                        quat))
;;                          (setf Dpoint (cl-transforms:make-pose
;;                                        (cl-transforms:make-3d-vector
;;                                         (cl-transforms:x (cl-transforms:origin new-point1))
;;                                         (- (cl-transforms:y (cl-transforms:origin new-point1)) index)
;;                                         (cl-transforms:z (cl-transforms:origin new-point1)))
;;                                        quat))
;;                          (setf Epoint (cl-transforms:make-pose
;;                                        (cl-transforms:make-3d-vector
;;                                         (cl-transforms:x (cl-transforms:origin new-point2))
;;                                         (+ (cl-transforms:y (cl-transforms:origin new-point2)) index)
;;                                         (cl-transforms:z (cl-transforms:origin new-point2)))
;;                                        quat))
;;                          (setf Fpoint (cl-transforms:make-pose
;;                                        (cl-transforms:make-3d-vector
;;                                         (cl-transforms:x (cl-transforms:origin new-point2))
;;                                         (- (cl-transforms:y (cl-transforms:origin new-point2)) index)
;;                                         (cl-transforms:z (cl-transforms:origin new-point2)))
;;                                        quat))

;;                            ;; (format t "temo ~a~%" temp)
;;                          (setf temp (cons Fpoint (cons Epoint (cons new-point1 (cons new-point2 (cons Dpoint (cons Cpoint (cons Bpoint (cons Apoint (cons new-point temp))))))))))))))
;;                (reverse temp))) 


(defun visualize-plane (num)
  (let* ((temp '()))
    (loop for jindex from 5 to num
          do(loop for smart from 0 to 30
                  do(loop for mass from 1 to 41 
                   do  (let*((new-point (swm->get-gesture->relative-genius
                                          (cl-transforms:make-3d-vector
                                            jindex  (- mass 11) (- smart 15)))))
                                 (setf temp (cons new-point temp))))))
                 (reverse temp))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;RSG ROSJAVA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Interface to robot scene graph
(defun internal-semantic-map-geom (swm-liste)
  (let*((elem NIL))
    (dotimes (i (length swm-liste))
      do(setf elem (append (list (list (first (nth i swm-liste)) (make-instance
								  sem-map-utils::'semantic-map-geom
								  :type (second (nth i swm-liste))
								  :parent NIL
								  :name (first (nth i swm-liste))
								  :owl-name "owl-name"
								  :pose (third (nth i swm-liste))
								  :dimensions (internal-bboxs (fourth (nth i swm-liste)) (fifth (nth i swm-liste)))
								  :aliases NIL))) elem)))
    elem))

;;two geoposes to a dimension vector
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


;; knowrob call by rosjava
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

;; split the whole message coming from rosjava
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
        
;;splitting the geometry poses
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


;;calculating the cartesian pose out of the gepose from the rsg graph
(defun swm->get-cartesian-pose-agent (agent)
  (let* ((pose (swm->get-geopose-agent agent)) ;;(cl-transforms:make-pose (cl-transforms:make-3d-vector 44.1533088684 12.2414226532 42.7000007629) (cl-transforms:make-quaternion 0 0 0 1))) ;;(swm->get-geopose-agent agent))
     
        (call (roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg pose))))
        (format t "~a~%" pose)
   (splitgeometry->pose call)))

(defun swm->get-cartesian-pose-agents (agent)
  (let* ((pose (swm->get-geopose-agent agent)) ;;(cl-transforms:make-pose (cl-transforms:make-3d-vector 44.1533088684 12.2414226532 42.7000007629) (cl-transforms:make-quaternion 0 0 0 1))) ;;(swm->get-geopose-agent agent))
        (call (roslisp:call-service "mywgs2ned_server" 'world_mission-srv::Mywgs2ned_server :data (cl-transforms-stamped::to-msg pose))))
   (splitgeometry->poses call)))


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
  (let*((elems (swm->geopose-elements))
        (pub (cl-tf:make-transform-broadcaster)))
    (loop for i from 0 to (- 1 (length elems))
          do(let*((frame-id (nth 0 (nth i elems)))
                  (ori (cl-transforms:origin (nth 1 (nth i elems))))
                  (qua (cl-transforms:orientation (nth 1 (nth i elems)))))
             (cl-tf:send-transforms pub (cl-transforms-stamped:make-transform-stamped "map"  frame-id (roslisp:ros-time) ori qua))))))


(defun swm->elem-name->type (name)
 (let*((pose NIL)
       (liste *geo-list*)); (swm->geopose-elements)))
                   (loop for i from 0 to (length liste)
                         do(cond ((string-equal name (car (nth i liste)))
                                (setf pose (second (nth i liste))))
                               (t (setf var 1))))
                   pose))


(defun swm->elem-name->position (name)
 ;; (format t "swm->elem-name->position~%")
 (let*((pose NIL)
       (liste *geo-list*))
   ;; (swm->geopose-elements)))
 ;;  (format t "~a name is~%" name)
 ;;  (format t "~a liste is~%" liste)
                   (loop for i from 0 to (- (length liste) 1)
                         do(cond ((and (string-equal name (car (nth i liste)))
                                       (equal pose NIL))
                                  (setf pose (third (nth i liste))))
                                 (t ())))
                   pose))

(defun swm->find-elem-in-map (elem)
  (let*((value NIL)
        (sem-map (swm->initialize-semantic-map))
        (sem-hash (slot-value sem-map 'sem-map-utils:parts))
        (sem-keys (hash-table-keys sem-hash))
        (ret NIL))
  ;;  (format t "elems ~a~%" value)
    (loop for i in '(5 10 17 30 50 70 90 120 150 170 190 210 230 260 280 300 320 340 360 380 400)
	  do(if (equal ret NIL)
          (let*((elems (sem->objects-next-human i sem-map)))
          ;;   (format t "elems ~a~%" elems)
             (if (equal elems NIL)
                 (format t "")
                 (loop for jndex from 0 to (- (length sem-keys) 1)
                       do(if (equal ret NIL)
                             (loop for index from 0 to (- (length sem-keys) 1)
                               do (if (equal NIL value)
                                      (cond ((and (string-equal (nth index sem-keys) (nth jndex elems))
                                                  (string-equal (slot-value (gethash (nth index sem-keys) sem-hash) 'sem-map-utils::type) elem))
                                             (setf value T)
                                             (setf ret (nth index sem-keys))
                                             (return))
                                      (t ()))
                                      (format t "")))
                             (return)))))  
           (return)))
  ret))


;; GROUND FOR GESTURE

(defun swm->close-to-gesture ()
  (let* ((elem NIL)
         (sem-map (swm->initialize-semantic-map))
         (sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
         (incrementer 0))
    (loop for i in '(5 10 20 30 45 60 85 100 120 140 160)
          do;(format t "~a~%" i)
             (let*((liste (visualize-plane-gesture i)))
                   (dotimes (mo (length liste))
                   do (let*((new-point (nth mo liste))
                            (smarter (+ (* 10 incrementer) i)))
                        (dotimes (jndex (length sem-keys))
                          do(let* ((elem1 (first (swm->get-bbox-as-aabb (nth jndex sem-keys) sem-hash)))
                                   (elem2 (second (swm->get-bbox-as-aabb (nth jndex sem-keys) sem-hash)))
                              (smarter (+ smarter jndex)))
                              (setf value
                               (semantic-map-costmap::inside-aabb elem1 elem2 (cl-transforms:origin new-point)))
                         (cond ((equal value T)
                                (location-costmap::publish-point (cl-transforms:origin new-point) :id smarter)
                                (setf elem (append (list (nth jndex sem-keys)) elem))
                                (remove-duplicates elem))
                               (t
                               ;(location-costmap::publish-point (cl-transforms:origin new-point) :id smarter)
                               )))
		       (setf incrementer (+ incrementer 2))))))) 
             (reverse (remove-duplicates elem))))


(defun visualize-plane-gesture (num)
  (setf *pub* (swm->intern-tf-creater))
  (let* ((temp '()))
    (loop for jindex from 2 to num
          do(loop for smart from 0 to 20
                  do(loop for mass from 1 to 21 
                   do  (let*((new-point (swm->get-gesture->relative-genius
                                          (cl-transforms:make-3d-vector
                                            jindex  (- mass 11) (- smart 10)))))
                        ;; (format t "~a~%" new-point)
                         (setf temp (cons new-point temp))))))
    (swm->intern-tf-remover)
    (reverse temp))) 
