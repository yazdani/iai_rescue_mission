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

(defsystem startup-mission
  :author "yazdani"
  :license "BSD"
  :depends-on (; spatial-relations-costmap
               cram-designators
               cram-location-costmap
               cram-prolog
               roslisp
               cram-semantic-map-costmap
               ; cram-robot-pose-gaussian-costmap
               cram-bullet-reasoning
               ;;cram-quadrotor-knowledge
               agent-mission
               cram-bullet-reasoning-belief-state
               ; projection-process-modules
               ; occupancy-grid-costmap
               cram-plan-library
               cram-bullet-reasoning-designators
               ;; cram-quadrotor-designators
               instruct_mission-msg
	       instruct_mission-srv
	       cl-tf
               cram-semantic-map-designators
               instruct-mission
               alexandria)
  ;; bullet-reasoning-utilities)
  :components
  ((:module "src"
    :components
    ((:file "package")
     (:file "costmap-knowledge" :depends-on("package"))
     (:file "gesture-calculation" :depends-on("package"))
     (:file "cost-functions" :depends-on ("package"))
     (:file "designators" :depends-on ("package"))
     (:file "reasoning" :depends-on ("package" "cost-functions"))
     (:file "start-scenario" :depends-on ("package" "costmap-knowledge" "reasoning" "gesture-calculation"))))))
