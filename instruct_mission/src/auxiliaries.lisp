;;; Copyright (c) 2014, Fereshta Yazdani <yazdani@cs.uni-bremen.de>
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

(defun get-agent()
  (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 0)))))

(defun get-cmd-type()
     (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 2)))))

(defun get-action()
   (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 1)))))

;;TODO
(defun get-direction()
     (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 3)))))

(defun get-item()
     (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 4)))))

(defun get-location()
     (string-to-pose (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 5))))))

(defun string-to-pose(chain)
  (let* ((tmp (string-right-trim "#\)" (string-left-trim "#\(" chain)))
         (tmp1  (split-sequence::split-sequence #\, tmp))
         (x  (with-input-from-string (in (car tmp1)) (read in)))
         (y  (with-input-from-string (in (cadr tmp1)) (read in)))
         (z  (with-input-from-string (in (caddr tmp1)) (read in)))
         (vec (vector x y z)))
    vec))
    
          
