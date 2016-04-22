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

;; (defun visualize-bbox (abbox bbbox point)
;;   (let ((index 0)
;; 	(iks-small (cl-transforms:x abbox))
;; 	(yps-small (cl-transforms:y abbox))
;; 	(zet-small (cl-transforms:z abbox))
;; 	(iks-big (cl-transforms:x bbbox))
;; 	(yps-big (cl-transforms:x bbbox)))
;;   (loop while (<= zet-small (cl-transforms:z bbbox))
;;         do(loop while (<= iks-small (cl-transforms:x bbox)
;; 			  do(let*((pose (cl-transforms:make-pose 
;; 					  (cl-transforms:make-3d-vector (+ (cl-transforms:x abbox) 1)
;; 									(cl-transforms:y abbox)
;; 									(cl-transforms:z abbox))
;; 					  (cl-transforms:make-identity-rotation))))
;; 			      (set-my-point pose (* 100 iks-small) 

;; set-my-point

;;      (loop while (< (cl-transforms:x abbox) (cl-transforms:y bbbox))
;;         do(
;;   (let*((x-axis (cl-transforms:make-3d-vector (+ (cl-transforms:x vec1) index)
;;                                               (cl-transforms:y vec1)
;;                                               (cl-transforms:z vec1)))
;;         (y-axis (cl-transforms:make-3d-vector  (cl-transforms:x vec1) 
;;                                               (+ (cl-transforms:y vec1) index)
;;                                               (cl-transforms:z vec1)))
;;         (z-axis (cl-transforms:make-3d-vector  (cl-transforms:x vec1) 
;;                                               (cl-transforms:y vec1)
;;                                               (+ (cl-transforms:z vec1) index))))
     

;;(defun calculate-smallest-object (semmap)

  
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


