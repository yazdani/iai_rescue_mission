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


(defun create-mhri-msg (liste)
(let*((desigliste (first liste))
      (aliste '())
      (tmp NIL)(pose NIL))
      (cond ((= (length desigliste) 0)
             (setf aliste (cons (roslisp:make-message "mhri_msgs/interpretation"
                                               :value (cl-transforms-stamped::make-msg "std_msgs/Bool"
                                                            :data 0)
                                               :error (cl-transforms-stamped::make-msg "std_msgs/String"
                                                             :data "Error: Why is the command empty?")
                                               :type ""
                                               :pose  (cl-transforms-stamped::to-msg (cl-transforms:make-identity-pose)))
                                aliste)))
            (t (dotimes (index (length liste))
                 do (format t " (type-of (second (nth index liste) ~a~%"  (second (nth index liste)))
                 (cond((equal 'cl-transforms-stamped:pose-stamped (type-of (second (nth index liste))))

                         (setf tmp (cl-transforms-stamped::to-msg (cl-transforms-stamped:pose-stamped->pose (second (nth index liste)))))
                         (setf pose (slot-value (roslisp:call-service "myned2wgs_server" 'world_mission-srv::Mywgs2ned_server :data tmp) 'WORLD_MISSION-SRV:SUM))
                         (setf aliste (cons (roslisp:make-message "mhri_msgs/interpretation"
                                               :value (cl-transforms-stamped::make-msg "std_msgs/Bool"
                                                            :data 1)
                                               :error (cl-transforms-stamped::make-msg "std_msgs/String"
                                                             :data "")
                                               :type (cl-transforms-stamped::make-msg "std_msgs/String"
                                                              :data (first (nth index liste)))
                                               :pose  pose)
                                          aliste)))
                        (t
                         (setf aliste (cons (roslisp:make-message "mhri_msgs/interpretation"
                                               :value (cl-transforms-stamped::make-msg "std_msgs/Bool"
                                                            :data 1)
                                               :error (cl-transforms-stamped::make-msg "std_msgs/String"
                                                             :data (second (nth index liste)))
                                               :type (cl-transforms-stamped::make-msg "std_msgs/String"
                                                              :data "")
                                               :pose  (cl-transforms-stamped::to-msg (cl-transforms-stamped:make-identity-pose)))
                                          aliste)))))))
  (reverse aliste)))
         






;;###############################################################;;
;;                                                               ;;
;; Internal Functions for action-move-ins()                      ;;
;;                                                               ;;
;;###############################################################;;




    

