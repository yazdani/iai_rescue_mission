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

(def-fact-group costmap-metadata ()
   (<- (costmap-size 400 500))
  (<- (costmap-origin -10 -100))
  (<- (costmap-resolution 0.95))
  (<- (costmap-padding 0.3)))

;;  (<- (costmap-size 20 20))
;;  (<- (costmap-origin -10 -10)) ;; out of bounds ERROR
;;  (<- (costmap-resolution 0.95)) ;;MOD ERROR
;;  (<- (costmap-padding 0.025)))


(def-fact-group semantic-map-data (semantic-map-name)
  (<- (semantic-map-object-name "http://knowrob.org/kb/ias_semantic_map.owl#SemanticEnvironmentMap_PM580j")))

(desig::disable-location-validation-function 'btr-desig::validate-designator-solution)
(desig::disable-location-validation-function 'btr-desig::check-ik-solution)
;;(desig::disable-location-generator-function 'gaussian-costmap::robot-current-pose-generator)
;;(*disable-location-validation-function* desig::filter-solution)

