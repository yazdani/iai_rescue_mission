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

(in-package :startup-mission)

(defvar *pub*)
(defvar *puber* NIL)
(defvar *get-semantic-map*)

(defun service-call ()
  (roslisp-utilities:startup-ros :name "service_node");; :master-uri (roslisp:make-uri "localhost" 11311)  :name "service_node")
;;  (roslisp:with-ros-node ("getting service node" :spin t)
  (roslisp:register-service "multimodal_lisp" 'instruct_mission-srv:multimodal_lisp)
  (roslisp:ros-info (basics-system) "the msg.")
  (roslisp:spin-until nil 1000))

 (defun start-mission ()
   (service-call))

(roslisp:def-service-callback instruct_mission-srv:multimodal_lisp (robot type cmd gesture)
  (visualize-world)
  ;; (setf puber (swm->intern-tf-creater))
  (let*((agent (substitute #\_ #\Space robot))
        (type (read-from-string type))
        (icmd (instruct-mission::parser cmd))
        (sem-map (swm->initialize-semantic-map))
        (ge-vector (cl-transforms::make-3d-vector (svref gesture 0) ;;ned -> nwu
                                                  (* (svref gesture 1) (- 1))
                                                  (* (svref gesture 2) (- 1))))
        (liste (create-the-desiglist icmd ge-vector sem-map))
        (aliste (liste-with-locs liste))
        (bliste (liste-with-referenced-locs aliste))
        (mhri-msgs (instruct-mission::create-mhri-msg bliste)))
    (instruct-mission::mhri-list-into-client-msg mhri-msgs)))
   

(defun checker-of-pointer (elem gesture sem-map)
  (format t "checker-of-pointer~%")
  (let*((sym1 NIL)
        (sym2 NIL)
        (sym NIL))
    (cond ((not (equal NIL (swm->is-elem-in-list elem sem-map)))
           (setf sym (swm->is-elem-in-list elem sem-map)))
          (t (setf sym1 (sem-map->give-obj-pointed-at gesture sem-map))
             (if (equal sym1 NIL)
                 (setf sym2 (swm->close-to-gesture gesture sem-map))
                 (format t ""))
             (cond ((> (length sym1) 0)
                    (dotimes(index (length sym1))
                      do(cond((and (string-equal elem  (swm->elem-type (nth index sym1) sem-map))
                                   (equal sym NIL))
                              (setf sym (nth index sym1)))
                             (t ()))))
                   ((and (= (length sym1) 0)(> (length sym2) 0))
                    (dotimes(index (length sym2))
                      do(cond((and (string-equal elem  (swm->elem-type (nth index sym2) sem-map))
                                   (equal sym NIL))
                              (setf sym (nth index sym2)))
                             (t ()))))
                   (t ()))))
    sym))

    ;; (desig-list  (instruct-mission::create-the-msg agent type icmd gesture-elem))  
 
    ;;     (tmp (instruct-mission::create-mhri-msg desig-list)))
    ;; (cond ((= (length tmp) 1)
    ;;        (setf msg  (roslisp:make-message "mhri_msgs/multimodal" :action (vector (first tmp)))))
    ;;       ((= (length tmp) 2)
    ;;      (setf msg  (roslisp:make-message "mhri_msgs/multimodal" :action (vector (first tmp) (second tmp)))))

    ;;       ((= (length tmp) 3)
    ;;      (setf msg  (roslisp:make-message "mhri_msgs/multimodal" :action (vector (first tmp) (second tmp) (third tmp))))))
    ;; (roslisp:make-response :interpretation msg)))



          
        
