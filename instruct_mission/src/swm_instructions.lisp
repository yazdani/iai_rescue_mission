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

(in-package :instruct-mission)

(defvar *swm-bbx* NIL)
(defvar *swm-pose* NIL)
(defvar *geo-list*)
(defparameter *swm-liste* NIL)

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

