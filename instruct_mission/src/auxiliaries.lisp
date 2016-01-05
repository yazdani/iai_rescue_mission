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

;; (defun parse-cmd-into-designator (cntnt)
;;   (let* ((agent (read-from-string (substitute #\- #\Space (slot-value cntnt 'instruct_mission-msg::agent))))
;;          (cmd (slot-value cntnt 'instruct_mission-msg::command))
;;          (type (read-from-string (slot-value cntnt 'instruct_mission-msg::type)))
;;          (gesture (slot-value cntnt 'instruct_mission-msg::gesture))
;;          (ge-vector (cl-transforms::make-3d-vector (svref gesture 0)
;;                                                    (svref gesture 1)
;;                                                    (svref gesture 2)))         
;;          (gps (slot-value cntnt 'instruct_mission-msg::gps))
;;          (gps-vector (cl-transforms::make-3d-vector (svref gps 0)
;;                                                     (svref gps 1)
;;                                                     (svref gps 2)))
;;         ;;(..))
;;          )
;;     (format t "cmd: ~a~% agent: ~a~% type: ~a~% gesture: ~a~% ge-vector: ~a~% gps: ~a~% gps-vector: ~a~%" cmd agent type gesture ge-vector gps gps-vector)
;;     cmd)) 


;; (defun char-into-word (cntnt)
;;   (let*((a-var 0)
;;         (ab-var 0))
;;     (loop for elem from 0 to (- (length cntnt) 1)
;;           do (cond ((char=  (aref cntnt elem) #\;)
;;                     (setf a-var (parse-instruct 0 (- elem 1)))
;;                     (setf ab-var (parse-instruct (+ elem 1) (length cntnt))))
;;                    (t (format t "well, i think it didnt work~%")
;;                       (setf a-var (parse-instruct 0 (- (length cntnt) 1))))))))

  
;; (defun parse-instruct (cntnt elem1 elem2)
;;    (let*((action-var 0)
;;          (elem-num 0)
;;          (direction-var 0)
;;          (location-var 0))
;;      (loop for elem from elem1 to elem2
;;            do (cond ((char=  (aref cntnt elem) #\()
;;                      (if (equal action-var 0)
;;                          (setf action-var (- elem 1))
;;                          (format t "go further~%")))
;;                     ((char=  (aref cntnt elem) #\))
;;                      (if (equal location-var 0)
;;                          (setf location-var (- elem 1))
;;                          (format t "end~%")))
;;                     ((char=  (aref cntnt elem) #\,)
;;                      (if (equal direction-var 0)
;;                          (setf direction-var (- elem 1))
;;                          (format t "go straight~%")))                               
;;                     (t (format t "~a und ~a und ~a~%" action-var direction-var location-var))))))

;; (defun parse-instruct (cntnt)
;;   (let* ((cmd (split-cmd cntnt))
         
;; (defun split-cmd (cmd)
;;    (split-sequence:split-sequence #\; (coerce cmd 'string)))

;; (defun get-action (cmd-part)
;;   (car (split-sequence:split-sequence #\( cmd-part)))

;; (defun get-dir (cmd-part)
;;   (car (split-sequence:split-sequence #\,  (cadr cmd-part))))

;; (defun get-loc (cmd-part)
;;   (car (split-sequence:split-sequence #\,  (cadr cmd-part))))
          
;;(defun get-agent()
;;  (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 0)))))

;;(defun get-cmd-type()
;;     (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 2)))))

;;(defun get-action()
;;   (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 1)))))

;;TODO
;;(defun get-direction()
;;     (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 3)))))

;;(defun get-item()
;;     (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 4)))))

;;(defun get-location()
;;    (string-to-pose (split-sequence::string-left-trim " " (cadr (split-sequence:split-sequence #\: (aref instruct-mission::*buffer-vector* 5))))))

;;(defun string-to-pose(chain)
;;  (let* ((tmp (string-right-trim "#\)" (string-left-trim "#\(" chain)))
;;         (tmp1  (split-sequence::split-sequence #\, tmp))
;;         (x  (with-input-from-string (in (car tmp1)) (read in)))
;;         (y  (with-input-from-string (in (cadr tmp1)) (read in)))
;;         (z  (with-input-from-string (in (caddr tmp1)) (read in)))
;;         (vec (vector x y z)))
;;    vec))
    
          
