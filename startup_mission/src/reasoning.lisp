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
(defmethod costmap-generator-name->score ((name (eql 'semantic-map-free-space))) 11)

(def-fact-group cognitive-reasoning-costmap (desig-costmap)
  (<- (desig-costmap ?desig ?costmap)
    (costmap ?costmap)
   ;; (lisp-fun get-genius-pose->map-frame "genius_link" ?pose)
    (lisp-fun instruct-mission::swm->get-cartesian-pose-agent "genius" ?pose)
    (prepositions ?desig ?pose ?costmap))


  ;;#########################################################;;
  ;;                                                         ;;
  ;;               STARTING WITH SPATIAL RELATIONS           ;;
  ;;                                                         ;;
  ;;#########################################################;;


  ;;############### RIGHT OF ####################;;
  (<- (prepositions ?desig ?pose ?costmap)   
    (or (desig-prop ?desig (:right-of ?object1-name))
        (desig-prop ?desig (:right ?object1-name)))
    (lisp-fun instruct-mission::swm->elem-name->position ?object1-name ?object1-pose)
   ;; (lisp-fun make-new-function-right ?pose ?object1-pose ?new-pose)
    ;;   (lisp-fun get-sem-object-pose->map ?object1-name ?object1-pose)
    (lisp-fun preposition-right ?pose ?list-values)
    (prolog::equal (?fvalue ?svalue) ?list-values)
    (costmap ?costmap)
    (swm->semantic-map-objects ?all-objects)
    (lisp-fun swm->semantic-map->geom-objects ?all-objects 7 ?object1-pose ?objects)
    (costmap-padding ?padding)
    (costmap-add-function semantic-map-free-space
                          (semantic-map-costmap::make-semantic-map-costmap
                           ?objects :invert t :padding ?padding)
                          ?costmap)
     (instance-of reasoning-generator ?reasoning-generator-id)
     (costmap-add-function
     ?reasoning-generator-id
    (make-reasoning-cost-function ?object1-pose ?fvalue ?svalue 0.3)
    ?costmap)
    (costmap ?costmap)
    (instance-of gaussian-generator ?gaussian-generator-id)
    (costmap-add-function ?gaussian-generator-id
                    (make-location-cost-function ?object1-pose 2.0)
                    ?costmap)
    (costmap-add-height-generator
     (swm->make-constant-height-function ?object1-name ?resulting-z)
     ?costmap))

  
  ;;############### LEFT OF ####################;;
 (<- (prepositions ?desig ?pose ?costmap)
    (or (desig-prop ?desig (:left-of ?object1-name))
        (desig-prop ?desig (:left ?object1-name)))
   (lisp-fun instruct-mission::swm->elem-name->position ?object1-name ?object1-pose)
    ;;(lisp-fun make-new-function-left ?pose ?object1-pose ?new-pose)
    ;;   (lisp-fun get-sem-object-pose->map ?object1-name ?object1-pose)
   (lisp-fun preposition-left ?pose ?list-values)
   (prolog::equal (?fvalue ?svalue) ?list-values)
   (swm->semantic-map-objects ?all-objects)
   (lisp-fun swm->semantic-map->geom-objects ?all-objects 7 ?object1-pose ?objects)
   (costmap-padding ?padding)
   (costmap-add-function semantic-map-free-space
                        (semantic-map-costmap::make-semantic-map-costmap
                          ?all-objects :invert t :padding ?padding)
                        ?costmap)
    (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap-add-function
     ?reasoning-generator-id
     (make-reasoning-cost-function ?object1-pose ?fvalue ?svalue 0.3)
     ?costmap)
    (costmap ?costmap)
   (instance-of gaussian-generator ?gaussian-generator-id)
   (costmap-add-function ?gaussian-generator-id
                         (make-location-cost-function ?object1-pose 2.0)
                         ?costmap)
   (costmap-add-height-generator
    (swm->make-constant-height-function ?object1-name ?resulting-z)
    ?costmap))
  
    ;;############### BEHIND OF ####################;;
  (<- (prepositions ?desig ?pose ?costmap)
    (format "ACROSS and BEHIND")
    (or (desig-prop ?desig (:behind-of ?object1-name))
        (desig-prop ?desig (:across ?object1-name))
        (desig-prop ?desig (:behind ?object1-name)))
;;    (lisp-fun get-sem-object-pose->map ?object1-name ?object1-pose)
    (lisp-fun instruct-mission::swm->elem-name->position ?object1-name ?object1-pose)
    ;;(lisp-fun make-new-function-left ?pose ?object1-pose ?new-pose)
    (lisp-fun preposition-front ?pose ?list-values)
    (prolog::equal (?fvalue ?svalue) ?list-values)
    (swm->semantic-map-objects ?all-objects)
    (lisp-fun swm->semantic-map->geom-objects ?all-objects 3 ?object1-pose ?objects)
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
    (costmap ?costmap)
  (instance-of gaussian-generator ?gaussian-generator-id)
   (costmap-add-function ?gaussian-generator-id
                         (make-location-cost-function ?object1-pose  2.0)
                        ?costmap)
    (costmap-add-height-generator
     (swm->make-constant-height-function ?object1-name ?resulting-z)
     ?costmap))

  ;;############### IN FRONT OF ####################;;
    (<- (prepositions ?desig ?pose ?costmap)
     (or (desig-prop ?desig (:in-front-of ?object1-name))
         (desig-prop ?desig (:front ?object1-name)))
      ;;      (lisp-fun get-sem-object-pose->map ?object1-name ?object1-pose)
      (lisp-fun instruct-mission::swm->elem-name->position ?object1-name ?object1-pose)
      (lisp-fun preposition-behind ?pose ?list-values)
      (prolog::equal (?fvalue ?svalue) ?list-values)
      (swm->semantic-map-objects ?all-objects)
      (lisp-fun swm->semantic-map->geom-objects ?all-objects 3 ?object1-pose ?objects)
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
      (costmap ?costmap)
      (instance-of gaussian-generator ?gaussian-generator-id)
      (costmap-add-function ?gaussian-generator-id
                            (make-location-cost-function ?object1-pose  2.0)
                            ?costmap)
      (costmap-add-height-generator
       (swm->make-constant-height-function ?object1-name ?resulting-z)
       ?costmap))

  ;;############### ABOVE ####################;;
 (<- (prepositions ?desig ?pose ?costmap)
     (desig-prop ?desig (:above ?object1-name))
   ;;(lisp-fun get-sem-object-pose->map ?object1-name ?object1-pose)
   (lisp-fun instruct-mission::swm->elem-name->position ?object1-name ?object1-pose)
   (instance-of gaussian-generator ?gaussian-generator-id)
   (costmap-add-function ?gaussian-generator-id
                         (make-location-cost-function ?object1-pose 1.5)
                         ?costmap)
   (costmap-add-height-generator
     (swm->make-constant-height-function ?object1-name ?resulting-z)
     ?costmap))
  
    ;;############### COME-BACK-TO-ME ####################;;
(<- (prepositions ?desig ?pose ?costmap)
  (format "INSIDE HERE ~%")
  (desig-prop ?desig (:toMe ?object1-pose))
  
  ;;(lisp-fun get-sem-object-pose->map ?object1-name ?object1-pose)
  (instance-of gaussian-generator ?gaussian-generator-id)
  (costmap-add-function ?gaussian-generator-id
                        (make-location-cost-function ?pose 1.5)
                        ?costmap)
  (format "INSIDE HERE2 ~%")
  (costmap-add-height-generator
   (swm->make-height-human ?pose ?resulting-z)
   ?costmap))


   ;;############### Test ####################;;
(<- (prepositions ?desig ?pose ?costmap)
 (desig-prop ?desig (:test ?object1-name))
  (lisp-fun instruct-mission::swm->elem-name->position ?object1-name ?object1-pose)
    (swm->semantic-map-objects ?all-objects)
    (lisp-fun swm->semantic-map->geom-objects ?all-objects 7 ?object1-pose ?objects)
   (costmap-padding ?padding)
    (costmap-add-function semantic-map-free-space
                          (semantic-map-costmap::make-semantic-map-costmap
                           ?objects :invert t :padding ?padding)
                          ?costmap))
   ;;############### AROUND ####################;;
  (<- (prepositions ?desig ?pose ?costmap)
    (or (desig-prop ?desig (:around ?object1-name))
        (desig-prop ?desig (:close ?object1-name))
        (desig-prop ?desig (:next ?object1-name)))
    ;; (lisp-fun get-sem-object-pose->map ?object1-name ?object1-pose)
    (lisp-fun instruct-mission::swm->elem-name->position ?object1-name ?object1-pose)
    (swm->semantic-map-objects ?all-objects)
    (lisp-fun swm->semantic-map->geom-objects ?all-objects 3 ?object1-pose ?objects)
    ;;(semantic-map-costmap::semantic-map-objects ?all-objects)
    (costmap-padding ?padding)
    (costmap-add-function semantic-map-free-space
                          (semantic-map-costmap::make-semantic-map-costmap
                           ?objects :invert t :padding ?padding)
                          ?costmap)
    (costmap ?costmap)
    (instance-of gaussian-generator ?gaussian-generator-id)
    (costmap-add-function ?gaussian-generator-id
                          (make-location-cost-function ?object1-pose  1.5)
                          ?costmap)
    (costmap-add-height-generator
     (swm->make-constant-height-function ?object1-name ?resulting-z)
     ?costmap))
    
  (<- (swm->semantic-map-objects ?objects)
    (lisp-fun instruct-mission::swm->create-semantic-map ?semantic-map)
    (lisp-fun sem-map-utils:semantic-map-parts ?semantic-map
              :recursive nil ?objects)))
  
;;   ;;right next TODO
  
;;    ;;right and close/next 
;;  (<- (prepositions ?desig ?pose ?costmap)
;;    (or (desig-prop ?desig (:right-of ?object1-name))
;;         (desig-prop ?desig (:right ?object1-name)))
;;     (or (desig-prop ?desig (:next-to ?object2-name))
;;         (desig-prop ?desig (:next ?object2-name))
;;         (desig-prop ?desig (:close-to ?object2-name))
;;         (desig-prop ?desig (:close ?object2-name)))
;;    (right-next ?desig ?object1-name ?object2-name ?pose ?costmap))

;;   (<- (right-next ?desig ?name1 ?name2 ?human-pose ?costmap)
;;     (lisp-fun get-sem-object-pose->map ?name1 ?pose1)
;;     (lisp-fun get-sem-object-pose->map ?name2 ?pose2)
;;     (lisp-fun right-direction ?human-pose ?pose1 ?list-values)
;;      (format"was34545~%")
;;     (prolog::equal (?fvalue ?svalue) ?list-values)
;;     (lisp-fun left-direction ?human-pose ?pose2 ?lists-values)
;;      (format"was334~%")
;;     (prolog::equal (?fvalues ?svalues) ?lists-values)
;;     (costmap ?costmap)
;;     (semantic-map-costmap::semantic-map-objects ?all-objects)
;;     (lisp-fun semantic-map->geom-objects ?all-objects 7 ?pose1 ?objects)
;;     (costmap-padding ?padding)
;;     (format"objects ~a~%" ?objects)
;;     (costmap-add-function semantic-map-free-space
;;                         (semantic-map-costmap::make-semantic-map-costmap
;;                          ?objects :invert t :padding ?padding)
;;                         ?costmap)
;;     (costmap ?costmap)
;;     (instance-of reasoning-generator ?reasoning-generator-id)
;;     (costmap-add-function
;;      ?reasoning-generator-id
;;      (make-reasoning-cost-function ?pose1 ?fvalue ?svalue 0.4)
;;      ?costmap)
;;     (costmap ?costmap)
;;     (instance-of reasoning-generator ?reasoning-generator-id2)
;;     (costmap-add-function
;;      ?reasoning-generator-id2
;;      (make-reasoning-cost-function ?pose2 ?fvalues ?svalues 0.5)
;;      ?costmap)
;;      (format"objects123 ~a~%" ?objects)
;;     (costmap ?costmap)
;;   ;; (instance-of gaussian-generator ?gaussian-generator-id)
;;   ;; (costmap-add-function ?gaussian-generator-id
;;    ;;                    (make-location-cost-function ?pose1  2.5)
;;     ;;                    ?costmap)
;;     ;;  (costmap ?costmap)
;;     (costmap-add-height-generator
;;      (make-bb-height-function ?name1 ?resulting-z)
;;      ?costmap)))

;;   ;;; combination of both TODO: find a better solution ;;;

  

;; (def-fact-group location-desig-utils ()
  
;;   (<- (object-instance-name ?name ?name)
;;     (lisp-type ?name symbol)))

;; (def-fact-group for-collision-states ()
;;   (<- (object-in-collision ?obj)))

  
