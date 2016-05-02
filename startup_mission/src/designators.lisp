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

(defun create-the-desiglist (icmd ge-vector sem-map)
  (setf puber (swm->intern-tf-creater))
  (let*((liste '())
        (pelem NIL))
    (dotimes (index (length icmd))
      do(cond((string-equal "pointed_at" (third (nth index icmd)))
              (setf pelem (checker-of-pointer (fourth (nth index icmd)) ge-vector sem-map))
              (setf liste (cons (replace-elem (nth index icmd) (fourth (nth index icmd)) pelem) liste)))
             ((string-equal "small" (third (nth index icmd)))
              (setf pelem (calculate-small-object (fourth (nth index icmd)) sem-map))
              (setf liste  (cons (replace-elem (nth index icmd) (fourth (nth index icmd)) pelem) liste)))
             ((string-equal "big" (third (nth index icmd)))
              (setf pelem (calculate-big-object (fourth (nth index icmd)) sem-map))
              (setf liste  (cons (replace-elem (nth index icmd) (fourth (nth index icmd)) pelem) liste)))
             ((and (string-equal "nil" (third (nth index icmd)))
                   (not (string-equal "nil" (fourth (nth index icmd)))))
              (setf pelem (swm->find-elem-in-map (fourth (nth index icmd))))
              (setf liste (cons (replace-elem (nth index icmd) (fourth (nth index icmd)) pelem) liste)))
             (t (setf liste (cons (nth index icmd) liste)))))
    (swm->intern-tf-remover puber)
    (reverse liste)))

(defun take-desig (cmd)
  (let*((object (fourth cmd))
        (desig (list "take-picture" object)))
    desig))

(defun move-desig (cmd)
  (let*((object (fourth cmd))
        (desig NIL))
    (cond ((equal 'NULL (type-of (search "Error" (fourth cmd))))
            (setf desig (list "move" (make-designator :location `((,(direction-symbol (second cmd)) ,object))))))
          (t (setf desig (list "move" (fourth cmd)))))
    desig))

(defun direction-symbol (sym)
  (intern (string-upcase sym) "KEYWORD"))
  
(defun liste-with-locs (liste)
  (let*((new '()))
  (dotimes (index (length liste))
    do(cond((string-equal "move" (first (nth index liste)))
             (setf new (cons (move-desig (nth index liste)) new)))
            ((string-equal "take" (first (nth index liste)))
             (setf new (cons (take-desig (nth index liste)) new)))
            (t (format t "Something went wrong~%"))))
    (reverse new)))

(defun liste-with-referenced-locs (liste)
  (let*((newliste '())
        (ret NIL))
    (dotimes (index (length liste))
      do(cond((and (string-equal "move" (first (nth index liste)))
                   (equal 'location-designator (type-of (second (nth index liste)))))
              (setf ret (reference (second (nth index liste))))
              (setf newliste (cons (list (first (nth index liste)) ret) newliste))) 
             (t (setf newliste (cons (nth index liste) newliste)))))
  (reverse newliste)))
