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

(def-fact-group cognitive-reasoning-costmap (desig-costmap)
  (<- (desig-costmap ?desig ?costmap)
    (bullet-world ?world)
    ;;(findall ?obj (and
      ;;             (bullet-world ?world)
        ;;           (object ?world ?name)
          ;;         (%object ?world ?name ?obj)
            ;;       (lisp-type ?obj manmade-object)
              ;;     (get-slot-value ?obj types ?types)
                ;;   (member ?type ?types))?objs)
    (costmap ?costmap)
    (lisp-fun get-genius-pose->world-model ?pose)
    (prepositions ?desig ?pose ?costmap))
  
  (<- (prepositions ?desig ?pose ?costmap)
    (format "behind")
    (or (desig-prop ?desig (:behind-of ?object1-name))
        (desig-prop ?desig (:behind ?object1-name)))
    (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
    (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap-add-function
     ?reasoning-generator-id
     (make-reasoning-cost-function ?object1-pose :X  < 0.6)
     ?costmap))

 (<- (prepositions ?desig ?pose ?costmap)
   (format "next-to")
   (desig-prop ?desig (:next-to ?object1-name))
   (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
   (instance-of reasoning-generator ?reasoning-generator-id)
   (costmap-add-function
    ?reasoning-generator-id
    (make-reasoning-cost-function ?object1-pose :Y  < 0.6)
    ?costmap))

   (<- (prepositions ?desig ?pose ?costmap)
     (format "in-front-of")
   (desig-prop ?desig (:in-front-of ?object1-name))
   (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
   (instance-of reasoning-generator ?reasoning-generator-id)
   (costmap-add-function
    ?reasoning-generator-id
    (make-reasoning-cost-function ?object1-pose :X  > 0.5)
    ?costmap))
  
 (<- (prepositions ?desig ?pose ?costmap)
   (format "right-of")
   (desig-prop ?desig (:right-of ?object1-name))
   (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
   (instance-of reasoning-generator ?reasoning-generator-id)
   (costmap-add-function
    ?reasoning-generator-id
    (make-reasoning-cost-function ?object1-pose :Y  > 0.3)
    ?costmap))
  
 
 (<- (prepositions ?desig ?pose ?costmap)
   (format "left-of")
   (desig-prop ?desig (:left-of ?object1-name))
   (lisp-fun get-object-pose->semantic-map ?object1-name ?object1-pose)
   (instance-of reasoning-generator ?reasoning-generator-id2)
   (costmap ?costmap)
   (costmap-add-function
    ?reasoning-generator-id2
    (make-reasoning-cost-function ?object1-pose :Y  < 0.3)
    ?costmap)))


(def-fact-group location-desig-utils ()

  (<- (object-instance-name ?name ?name)
      (format "object-instance-name ~a~%" ?name)
      (format "      (lisp-type ?name symbol) ~a~%" (lisp-type ?name symbol))
      (lisp-type ?name symbol))
)
 ;; (<- (desig-costmap ?desig ?costmap)
  ;;   (bullet-world ?world)
  ;;   (robot ?robot)
  ;;   (desig-prop ?desig (pointed-pos ?pos))
  ;;   (desig-prop ?desig (for ?obj))
  ;;   (btr:object ?w ?ref-obj-name)
  ;;   (desig-location-prop ?ref-obj-name ?ref-obj-pose)
  ;;   (complete-object-size ?w ?ref-obj-name ?ref-obj-size)
  ;;   (padding-size ?w ?ref-obj-name ?ref-padding)
  ;;   (btr:object ?w ?for-obj-name)
  ;;   (complete-object-size ?w ?for-obj-name ?for-obj-size)
  ;;   (padding-size ?w ?for-obj-name ?for-padding)
  ;;   (-> (desig-prop ?desig (near ?ref-obj-name)
  ;;                   (pointed-costmap ?desig ?ref-obj-pose ?ref-obj-size ?ref-padding ?for-obj-size ?for-padding ?costmap))))
  
  ;; (<- (pointed-costmap ?desig ?ref-obj-pose ?ref-obj-size ?ref-padding ?for-obj-size ?for-padding ?costmap)
  ;;   (costmap  ?costmap)
  ;;   (instance-of gaussian-generator ?gaussian-generator-id)
  ;;   (costmap-add-function
  ;;    ?gaussian-generator-id
  ;;    (make-location-cost-function ?ref-obj-pose 1.0d0)
  ;;    ?costmap)
  ;; (lisp-fun calculate-near-costmap-min-radius ?ref-obj-size ?for-obj-size
  ;;             ?ref-padding ?for-padding ?min-radius)
  ;;   (costmap-width-in-obj-size-percentage-near ?cm-width-perc)
  ;;   (lisp-fun calculate-costmap-width ?ref-obj-size ?for-obj-size ?cm-width-perc
  ;;             ?cm-width)
  ;;   ;;
  ;;   (lisp-fun + ?min-radius ?cm-width ?max-radius)
  ;;   (instance-of range-generator ?range-generator-id-1)
  ;;   (costmap-add-function
  ;;    ?range-generator-id-1
  ;;    (make-range-cost-function ?ref-obj-pose ?max-radius)
  ;;    ?costmap)
  ;;   ;;
  ;;   (instance-of range-generator ?range-generator-id-2)
  ;;   (costmap-add-function
  ;;    ?range-generator-id-2
  ;;    (make-range-cost-function ?ref-obj-pose ?min-radius :invert t)
  ;;    ?costmap))

  ;;   ;; (findall ?obj (and
  ;;   ;;                (bullet-world ?world)
  ;;   ;;                (object ?world ?name)
  ;;   ;;                (%object ?world ?name ?obj)
  ;;   ;;                (lisp-type ?obj environment-object)
  ;;   ;;                (get-slot-value ?obj types ?types)
  ;;   ;;                (member ?type ?types)) ?objs)
  ;;   ;; (costmap-add-function collisions
  ;;   ;;                       (make-costmap-bbox-gen ?objs :invert t :padding 0.1)
  ;;   ;;                       ?costmap)
  ;;   (costmap ?costmap)
  ;;   (costmap-add-function reasoning-generator
  ;;                         (make-cognitive-reasoning-cost-function ?pos :Y  < 0.0)
  ;;                         ?costmap)
  ;;   (costmap ?costmap)
  ;;   (instance-of range-generator ?range-generator-id-1)
  ;;   (costmap-add-function ?range-generator-id-1
  ;;                         (make-range-cost-function ?pos 2.5)
  ;;                         ?costmap)
  ;;   (costmap ?costmap)
  ;;   (instance-of gaussian-generator ?gaussian-generator-id)
  ;;   (costmap-add-function ?gaussian-generator-id
  ;;                         (make-location-cost-function ?pos  1.0)
  ;;                         ?costmap))
   
 
