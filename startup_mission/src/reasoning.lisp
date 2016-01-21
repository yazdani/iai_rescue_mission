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

;;(defmethod costmap-generator-name->score ((name (eql 'reasoning-generator))) 5)
(defmethod costmap-generator-name->score ((name (eql 'collisions))) 10)

(defclass reasoning-generator () ())
(defmethod costmap-generator-name->score ((name reasoning-generator)) 7)

(defclass gaussian-generator () ())     
(defmethod costmap-generator-name->score ((name gaussian-generator)) 6)
(defclass range-generator () ())
(defmethod costmap-generator-name->score ((name range-generator)) 2)
(defmethod costmap-generator-name->score ((name (eql 'semantic-map-free-space)))
  11)

(def-fact-group cognitive-reasoning-costmap (desig-costmap)
  (<- (desig-costmap ?desig ?costmap)
    (costmap ?costmap)
    (lisp-fun get-genius-pose->world-model "genius_link" ?pose)
    ;;Using prepositions for spatial reasoning
    ;;(e.g. right, left, next-to, behind, in-front)
    (prepositions ?desig ?pose ?costmap))
  
  (<- (prepositions ?desig ?pose ?costmap)
    (or (desig-prop ?desig (:behind-of ?object1-name))
        (desig-prop ?desig (:behind ?object1-name)))
    (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
    (lisp-fun check-the-left-direction ?pose ?object1-pose ?pred)
     (costmap ?costmap)
      (semantic-map-costmap::semantic-map-objects ?objects)
      (lisp-fun semantic-map->geom-object ?objects ?object1-name ?object)
      (costmap-padding ?padding)
      (costmap-add-function semantic-map-free-space
			    (semantic-map-costmap::make-semantic-map-costmap
			     ?object :invert t :padding ?padding)
			    ?costmap)
      (costmap ?costmap)
    (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap-add-function
     ?reasoning-generator-id
     (make-reasoning-cost-function ?object1-pose :X  ?pred 0.6)
     ?costmap)
    (costmap ?costmap)
    (costmap-add-height-generator
     (make-bb-height-function ?object1-name ?resulting-z)
     ?costmap))
    

 (<- (prepositions ?desig ?pose ?costmap)
   (or (desig-prop ?desig (:next-to ?object1-name))
       (desig-prop ?desig (:next ?object1-name))
       (desig-prop ?desig (:close-to ?object1-name))
       (desig-prop ?desig (:close ?object1-name)))
   (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
   (lisp-fun check-the-left-direction ?pose ?object1-pose ?pred)
    (costmap ?costmap)
      (semantic-map-costmap::semantic-map-objects ?all-objects)
      (lisp-fun semantic-map->geom-objects ?all-objects ?object1-name ?objects)
      (costmap-padding ?padding)
      (costmap-add-function semantic-map-free-space
			    (semantic-map-costmap::make-semantic-map-costmap
			     ?objects :invert t :padding ?padding)
			    ?costmap)
      (costmap ?costmap)
   (format "pred ~a~%" ?pred)
   (instance-of reasoning-generator ?reasoning-generator-id)
   (costmap-add-function
    ?reasoning-generator-id
    (make-reasoning-cost-function ?object1-pose :Y  ?pred 0.6)
    ?costmap)
   (costmap ?costmap)
   (costmap-add-height-generator
     (make-bb-height-function ?object1-name ?resulting-z)
     ?costmap))

   (<- (prepositions ?desig ?pose ?costmap)
     (desig-prop ?desig (:in-front-of ?object1-name))
     (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
     (lisp-fun check-the-right-direction ?pose ?object1-pose ?pred)
      (costmap ?costmap)
      (semantic-map-costmap::semantic-map-objects ?objects)
      (lisp-fun semantic-map->geom-object ?objects ?object1-name ?object)
      (costmap-padding ?padding)
      (costmap-add-function semantic-map-free-space
			    (semantic-map-costmap::make-semantic-map-costmap
			     ?object :invert t :padding ?padding)
			    ?costmap)
      (costmap ?costmap)
     (instance-of reasoning-generator ?reasoning-generator-id)
     (costmap-add-function
      ?reasoning-generator-id
      (make-reasoning-cost-function ?object1-pose :X  ?pred 0.5)
      ?costmap)
     (costmap-add-height-generator
     (make-bb-height-function ?object1-name ?resulting-z)
     ?costmap))

 (<- (prepositions ?desig ?pose ?costmap)
     (desig-prop ?desig (:above ?object1-name))
     (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
     (lisp-fun check-the-right-direction ?pose ?object1-pose ?pred)
   (instance-of gaussian-generator ?gaussian-generator-id)
   (costmap-add-function ?gaussian-generator-id
                         (make-location-cost-function ?object1-pose  1.0)
                         ?costmap)
   (costmap-add-height-generator
     (make-constant-height-function ?object1-name ?resulting-z)
     ?costmap))
  
  
  (<- (prepositions ?desig ?pose ?costmap)
    (or (desig-prop ?desig (:right-of ?object1-name))
        (desig-prop ?desig (:right ?object1-name)))
    (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
    (lisp-fun tf-right-direction ?list-values)
    (format "~a~%" ?list-values)
    (prolog::equal (?fvalue ?svalue) ?list-values)
    (format "fvalue ~%" ?fvalue)
    (costmap ?costmap)
    (semantic-map-costmap::semantic-map-objects ?all-objects)
    (lisp-fun semantic-map->geom-objects ?all-objects 10 ?object1-pose ?objects)
    (costmap-padding ?padding)
    (costmap-add-function semantic-map-free-space
                        (semantic-map-costmap::make-semantic-map-costmap
	     ?objects :invert t :padding ?padding)
	    ?costmap)
    (costmap ?costmap)
   (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap-add-function
   ?reasoning-generator-id
    (make-reasoning-cost-function ?object1-pose ?fvalue ?svalue 0.3)
    ?costmap)
   (costmap-add-height-generator
    (make-bb-height-function ?object1-name ?resulting-z)
    ?costmap))
  
  (<- (prepositions ?desig ?pose ?costmap)
    (or (desig-prop ?desig (:left-of ?object1-name))
        (desig-prop ?desig (:left ?object1-name)))
    (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
    (lisp-fun check-l-direction ?pose ?object1-pose ?list-values)
    (lisp-fun return-first-value ?list-values ?fvalue)
    (lisp-fun return-second-value ?list-values ?svalue)
     (costmap ?costmap)
      (semantic-map-costmap::semantic-map-objects ?all-objects)
     (format "?all-objects ~a~%" ?all-objects)
      (lisp-fun semantic-map->geom-objects ?all-objects 10 ?object1-pose ?objects)
    (format "?objects ~a~%" ?objects)
      (costmap-padding ?padding)
      (costmap-add-function semantic-map-free-space
			    (semantic-map-costmap::make-semantic-map-costmap
			     ?objects :invert t :padding ?padding)
			    ?costmap)
      (costmap ?costmap)
    (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap ?costmap)
    (costmap-add-function
     ?reasoning-generator-id
     (make-reasoning-cost-function ?object1-pose ?fvalue ?svalue 0.3)
     ?costmap)
    (format "pred ~a~%" ?pred)
    (costmap-add-height-generator
     (make-bb-height-function ?object1-name ?resulting-z)
     ?costmap)))











  ;;; combination of both TODO: find a better solution ;;;

  

(def-fact-group location-desig-utils ()
  
  (<- (object-instance-name ?name ?name)
    (lisp-type ?name symbol)))

(def-fact-group for-collision-states ()
  (<- (object-in-collision ?obj)))

  
