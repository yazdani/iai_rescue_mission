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

(defun create-the-msg (agent type icmd gelem)
  (let*(;(gtype (get-elem-type gelem))
        (acts (split-sequence:split-sequence #\; icmd))
        (desig NIL))
    (cond ((= (length acts) 1)
           (setf desig (create-msg-one-action agent icmd gelem)))
          ((= (length acts) 2)
           (setf desig (create-msg-two-actions agent type icmd gelem))))
    desig))

(defun create-msg-one-action (agent icmd gelem)
  (let*((ins (split-sequence:split-sequence #\= icmd))
        (desig NIL))
    (cond ((= (length ins) 1)
           (setf desig (create-msg->action icmd gelem agent)))
          ((> (length ins) 1)
           (setf desig (create-msg->ins-actions icmd gelem agent))))
    desig))


;;#######################################################################################;;
;;                                                                                       ;;
;;      CREATE-MSG->INS-ACTIONS => action(direction,object)<=inside(direction,object)    ;;
;;                                                                                       ;;
;;#######################################################################################;;

(defun create-msg->ins-actions (cmd gelem agent)
  (let*((action (first (split-sequence:split-sequence #\( cmd)))
        (desig NIL))
    (cond ((string-equal action "move")
           (setf desig (action-move-ins cmd)));; gelem)));; agent)))
          ((string-equal action "take")
           (setf desig (action-take-ins cmd gelem)));; agent)))
          ((string-equal action "scan")
           (setf desig (action-scan-ins cmd gelem)))
          (t (format t "Could not parse this sentence, because command is not of types: move, take or scan~%")))
    desig))


(defun action-move-ins (cmd);; gelem)
  (format t "hallooo~%")
(let*((cmd-split (split-sequence:split-sequence #\= cmd))
      (cmd-splitter1 (split-sequence:split-sequence #\( (first cmd-split)))
      (cmd-splitter1-1 (split-sequence:split-sequence #\, (second cmd-splitter1)))
      (cmd-splitter2 (split-sequence:split-sequence #\( (second cmd-split)))
      (desig NIL)
      (desig-intern NIL)
      (ref NIL))
     (cond ((and (= (length cmd-splitter1-1) 1)
                 (= (length cmd-splitter2) 2))
            (let*((elem1 (first (split-sequence:split-sequence #\) (second cmd-splitter1))))
                  (elem2 (first (split-sequence:split-sequence #\) (second (split-sequence:split-sequence #\, (second cmd-splitter2))))))
                  (elem1-list (swm->type->amount-elems elem1))
                  (elem2-list (swm->type->amount-elems elem2))
                  (dir2 (first (split-sequence:split-sequence #\, (second cmd-splitter2)))))
              (cond ((and (>= (length elem1-list) 1)
                          (= (length elem2-list) 1))
                     (format t "is true~%")
                     (setf desig-intern (make-designator :location `((,(instruct-mission::direction-symbol dir2) ,(first (car elem2-list))))))
                  ;;   (setf ref (reference desig-intern))
                     (setf desig (list "true" "" "move" desig-intern)));;ref)))
                    ((and (>= (length elem1-list) 1)
                          (>= (length elem2-list) 1))
                    (setf desig (list "false" (format NIL "Too many objects of the types found!" "" NIL))))
                    ((and (< (length elem1-list) 1)
                          (>= (length elem2-list) 1))
                    (setf desig (list "false" (format NIL "No object found of type '~a'" elem1) "" NIL)))
                    ((and (>= (length elem1-list) 1)
                          (< (length elem2-list) 1))
                    (setf desig (list "false" (format NIL "No object found of type '~a'" elem2) "" NIL)))
                    ((and (< (length elem1-list) 1)
                          (< (length elem2-list) 1))
                    (setf desig (list "false" (format NIL "No object found of both types '~a' and '~a'" elem1 elem2))))
                    (t (format t "Something went wrong inside action-move-ins~%")
                       (setf desig (list "false" (format NIL "Error: Something went wrong with the Interpretation of the instruction!") "" NIL))))))
           
           )desig))
                   






(defun action-scan-ins (cmd gelem)
(let*((cmd-split (split-sequence:split-sequence #\= cmd))
      (cmd-counts (split-sequence:split-sequence #\( (second cmd-split)))
      (dir (first (split-sequence:split-sequence #\, (second cmd-counts))))
      (elem (first (split-sequence:split-sequence #\) (second (split-sequence:split-sequence #\, (second cmd-counts))))))
      (desig NIL)
      (elem-list (instruct-mission::swm->type->amount-elems elem))
      (desig-intern NIL)
      (ref NIL))
      (cond((and (= 2 (length cmd-counts))
                 (= (length elem-list) 1))
            (setf desig-intern (make-designator :location `((,(instruct-mission::direction-symbol dir) ,(first (car elem-list))))))
            (setf ref (reference desig-intern))
            (setf desig (list "true" "" "scan" desig-intern ref)))
           ((and (= 2 (length cmd-counts))
                 (= (length elem-list) 0))
            (setf desig (list "false" (format NIL "Error: There is no object of type '~a' inside the map!" elem) "" NIL)))
           ((and (= 2 (length cmd-counts))
                 (> (length elem-list) 1))
            (setf desig (list "false" (format NIL "Error: There are too many objects of type '~a' inside the map!" elem) "" NIL)))
           ((and (= 3 (length cmd-counts)))
            (setf desig (action-scan-ins-pointer cmd gelem)))
           (t (format t "Something went wrong in the function action-scan-ins~%")
              (setf desig (list "false" (format NIL "Error: Something went wrong with the interpretation of the instruction!") "" NIL))))
  desig))


(defun action-scan-ins-pointer (cmd gelem)
   (let*((cmd-split (split-sequence:split-sequence #\= cmd))
         (cmd-counts (split-sequence:split-sequence #\( (second cmd-split)))
         (dir (first (split-sequence:split-sequence #\,  (second cmd-counts))))
         (elem (first (split-sequence:split-sequence #\)  (third cmd-counts))))
         (desig NIL)
         (elem-list (instruct-mission::swm->type->amount-elems elem))
         (type (instruct-mission::swm->elem-name->type gelem))
         (desig-intern NIL)
         (ref NIL))
     (cond((string-equal elem type)
           (setf desig-intern (make-designator :location `((,(instruct-mission::direction-symbol dir) ,(first (car elem-list))))))
          (setf ref (reference desig-intern))
           (setf desig (list "true" "" "scan" desig-intern)));;ref)))
          ((and (not(string-equal elem type))
                (/= (length elem-list) 0))
           (setf desig (list "false" (format NIL "Error: Pointed object ~a and command ~a are not fitting together" type elem) "" NIL )))
          ((and (not(string-equal elem type))
                (= (length elem-list) 0))
           (setf desig (list "false" (format NIL "Error: There is no object of type '~a' in the map!" elem) "" NIL )))
          (t (format t "Something went wrong during the interpretation in action-scan-ins-pointer")
             (setf desig (list "false" (format NIL "Something went wrong during the command interpretation!") "" NIL))))
     desig))
            
(defun action-take-ins (cmd gelem)
(let*((cmd-splitter (split-sequence:split-sequence #\= cmd))
      (cmd-splitter2 (split-sequence:split-sequence #\( (second cmd-splitter)))
                      (dir (first (split-sequence:split-sequence #\, (second (split-sequence:split-sequence #\( (second cmd-splitter))))))
      (elem (first (split-sequence:split-sequence #\) (second (split-sequence:split-sequence #\, (second (split-sequence:split-sequence #\( (second cmd-splitter))))))))
      (elem-list (instruct-mission::swm->type->amount-elems elem))
      (desig NIL)
      (desig-intern NIL)
      (ref NIL))
(cond((and (= (length cmd-splitter2) 2)
           (= (length elem-list) 1))
      (setf desig-intern (make-designator :location `((,(instruct-mission::direction-symbol dir) ,(first (car elem-list))))))
      (setf ref (reference desig-intern))
      (setf desig (list "true" "" "take-picture" ref)))
     ((and (= (length cmd-splitter2) 2)
           (> (length elem-list) 1))
        (setf desig (list "false" (format NIL "Error: There are too many objects of type '~a'!" elem) "" NIL)))
      ((and (= (length cmd-splitter2) 2)
           (< (length elem-list) 1))
        (setf desig (list "false" (format NIL "Error: No object of type '~a' available!" elem) "" NIL)))

      ((= (length cmd-splitter2) 3)
       (setf desig (action-take-ins-pointer cmd gelem)))
      (t (format t "Something went wrong with the interpretations inside action-take-ins~%")
         (setf desig (list "false" (format NIL "Error: Could not interpret the command, not available in the vocabulary") "" NIL))))
desig))

(defun action-take-ins-pointer (cmd gelem)
(let*((cmd-splitter (split-sequence:split-sequence #\= cmd))
      (cmd-split (split-sequence:split-sequence #\(  (second cmd-splitter)))
      (elem (first (split-sequence:split-sequence #\) (third cmd-split))))
      (dir (first (split-sequence:split-sequence #\, (second cmd-split))))
      (type (instruct-mission::swm->elem-name->type gelem))
      (desig NIL)
      (desig-intern NIL)
      (ref NIL)
      (elem-list (swm->type->amount-elems elem)))
  (cond((string-equal type elem)
        (setf desig-intern (make-designator :location `((,(instruct-mission::direction-symbol dir) ,gelem))))
       (setf ref (reference desig-intern))
        (setf desig (list "true" "" "take-picture" ref)))
       ((and (not (string-equal type elem))
             (> (length elem-list) 0))
        (setf desig (list "false" (format NIL "Error: Pointed object '~a' and nl command '~a' are not the same!" type elem) "" NIL)))
        ((and (not (string-equal type elem))
             (= (length elem-list) 0))
        (setf desig (list "false" (format NIL "Error: Object in the command '~a' are not in the map!" elem) "" NIL)))
        (t (format t "Something went wrong during the interpretation in action-take-ins-pointer~%")
           (setf desig (list "false" (format NIL "Error: Could not interpret the instruction. Something is wrong.") "" NIL))))
  desig))
  


;;#######################################################################################;;
;;                                                                                       ;;
;;        CREATE-MSG-ONE-ACTION => action(direction,object) vs. action(object)           ;;
;;                                                                                       ;;
;;#######################################################################################;;

(defun create-msg->action (icmd gelem agent)
  (let*((act (first (split-sequence:split-sequence #\( icmd)))
        (desig NIL))
    (cond ((string-equal act "move")
           (setf desig (action-move icmd gelem)))
          ((string-equal act "take")
           (setf desig (action-take agent)))   ;;done
          ((string-equal act "scan")
           (setf desig (action-scan icmd gelem agent))) ;; done
          (t (format t "cmd is not of types: 'move', 'take' and 'scan'~%")))
    desig))


;;move(wood)
;;move(pointed_at(wood))
(defun action-move (cmd gelem)
  (let*((len (split-sequence:split-sequence #\, cmd))
        (fbrakets (split-sequence:split-sequence #\( cmd))
        (elem (first (split-sequence:split-sequence #\) (second fbrakets))))
        (pelem (first (split-sequence:split-sequence #\) (third fbrakets))))
        (type (instruct-mission::swm->elem-name->type gelem))
        (desig NIL)
        (desig-intern NIL)
        (ref NIL)
        (elem-list (instruct-mission::swm->type->amount-elems elem)) ;;move(wood)
        (pelem-list (instruct-mission::swm->type->amount-elems pelem))) ;;move(pointed_at(wood))
    (cond ((and (= (length len) 1)
                (= (length fbrakets) 2)  ;;move(wood)
                (= (length elem-list) 1)) 
           (setf desig-intern (make-designator :location `((:close ,(first (car elem-list))))))
           (setf ref (reference desig-intern))
           (setf desig (list "true" "" "move" ref)))
           ((and (= (length len) 1)
                 (= (length fbrakets) 2)  ;;move(wood) to many elements TODO: move(river)
                 (> (length elem-list) 1))
            (setf desig (list "false" (format NIL "Error: There are too many objects in the world with the name '~a'" elem) "" NIL)))
           ((and (= (length len) 1)
                 (= (length fbrakets) 2)  ;;move(wood) no elements
                 (< (length elem-list) 1))
            (setf desig (list "false" (format NIL "Error: There are no objects in the world with the name '~a'" elem) "" NIL)))
           ((and (= (length len) 1)
                 (= (length fbrakets) 3)  ;;pointing with elements fits move(pointed_at(wood))
                 (string-equal type pelem))
            (setf desig-intern (make-designator :location `((:close ,gelem))))
            (setf ref (reference desig-intern))
            (setf desig (list "true" "" "move" ref)))
           ((and (= (length len) 1)
                 (= (length fbrakets) 3)  ;;pointing with elements don-t fit move(pointed_at(wood))
                 (not (string-equal type pelem))
                 (> (length pelem-list) 0))
            (setf desig (list "false" (format NIL "Error: Pointed Object '~a' do not fit with nl command '~a'" type pelem) "" NIL)))
           ((and (= (length len) 1)
                 (= (length fbrakets) 3)  ;;pointing with elements don-t fit move(pointed_at(wood))
                 (not (string-equal type pelem))
                 (= (length pelem-list) 0))
            (setf desig (list "false" (format NIL "Error: Pointed Object '~a' do not fit with nl command '~a' and is maybe not available in the map" type pelem) "" NIL)))
           ((= (length len) 2)
            (setf desig (action-move-gesture cmd gelem)))
           (t (format t "Something went wrong inside 'action-move'~%")
              (setf desig (list "false" (format NIL "Error: Something went wrong during the interpretation of '~a'" cmd) "" NIL))))
    desig))



;;move(dir,pointed_at(test))
(defun action-move-gesture (cmd gelem)
(let*((dir (second (split-sequence:split-sequence #\( (first (split-sequence:split-sequence #\, cmd)))))
      (desig NIL)
      (desig-intern)
      (ref NIL)
      (word (first (split-sequence:split-sequence #\) (second(split-sequence:split-sequence #\( (second (split-sequence:split-sequence #\, cmd)))))))
      (word-list (instruct-mission::swm->type->amount-elems word))
      (type (instruct-mission::swm->elem-name->type gelem)))
  (format t " what is word ~a~%" word)
  (cond ((and (string-equal word type))
         (setf desig-intern (make-designator :location `((,(instruct-mission::direction-symbol dir) ,gelem))))
       (setf ref (reference desig-intern))
         (setf desig (list "true" "" "move" ref)))
        ((and (not (string-equal word type))
              (> (length word-list) 0))
         (setf desig (list "false" (format NIL "Error: You are pointing towards a '~a' but you say  '~a', please correct your command!" type word )"" NIL)))
        ((and (not (string-equal word type))
              (= 0 (length word-list)))
         (setf desig (list "false" (format NIL "Error: You are pointing towards a '~a' but you say  '~a', the '~a' is maybe not available inside the map. Please correct your command!" type word word)"" NIL)))
        (t (format t "Something went wrong inside 'action-move-gesture'~%")
           (setf desig (list "false" (format NIL "Error: Something went wrong with the interpretation of the command '~a'!" cmd) "" nil))))
  desig))

;;what we already did:
;;scan(area)/scan(pointed_at(wood)) <= area:agents-pose
;;take(picture) <=agents-pose


;;take a picture at the position of the agent
;;take(picture)
(defun action-take (agent)
  (let*((pose (swm->get-cartesian-pose-agent agent))
        (desig NIL))
   (cond ((not (equal pose NIL))
          (setf desig (list "true" "" "take-picture" pose)))
         (t (setf desig (list "false" (format NIL "Error: Could not read ~a pose out of the map. Please update it!" agent)))))
    desig))


;;scan((test))
;;scan(area) <- means wasps
(defun action-scan (icmd gelem agent)
  (let*((len (split-sequence:split-sequence #\_ icmd))
        (br (first (split-sequence:split-sequence #\) (second (split-sequence:split-sequence #\( icmd)))))
        (desig NIL)
        (type (instruct-mission::swm->elem-name->type gelem))
        (t-list (instruct-mission::swm->type->amount-elems br)))
    (cond((and (= (length len) 1) 
               (string-equal "area" br))
          (setf desig (list "true" "" "scan" (instruct-mission::swm->get-geopose-agent agent))))
         ((and (= (length len) 1) 
               (= (length t-list) 1)
               (string-equal br type))
          (setf desig (list "true" "" "scan" (third (first t-list)))))
         ((and (= (length len) 1) 
               (= (length t-list) 1)
               (not (string-equal br type)))
          (setf desig (list "false" (format NIL "Error: Pointed object with type '~a' is not of type '~a'."type br) "" NIL)))
         ((and (= (length len) 1) 
               (> (length t-list) 1))
          (setf desig (list "false" (format NIL "Error: Too many objects of type '~a' inside the list" br)  "" NIL)))
          ((and (= (length len) 1)
                (= (length t-list) 0))
           (setf desig (list "false" (format NIL "Error: No objects are available of type '~a'" br) "" NIL)))
          ((= (length len) 2)
           (setf desig (action-scan-with-gesture icmd gelem)))
          (t (format t "Something went wrong during command interpretation~%")
             (setf desig (list "false" "Error: Something went wrong during interpretation of '~a'" icmd))))
    desig))

;;scan(pointed_at(test))
(defun action-scan-with-gesture (cmd gelem)
(let*((elm (first (split-sequence:split-sequence #\) (third (split-sequence:split-sequence #\( cmd)))))
      (t-list (instruct-mission::swm->type->amount-elems elm))
      (n-gelem (instruct-mission::swm->elem-name->type gelem))
      (desig NIL))
  (cond ((and (= (length t-list) 1)
              (string-equal n-gelem elm))
         (setf desig (list "true" "" "scan" (instruct-mission::swm->elem-name->position gelem))))
        ((and (= (length t-list) 1)
              (not(string-equal n-gelem elm))
              (string-equal elm (second (first t-list))))
         (setf desig (list "false" (format NIL "Error: Pointed object of type '~a' is not a '~a'. Please correct your command." n-gelem elm) "" NIL)))
        ((and (=  (length t-list) 1)
              (not (string-equal elm (second (first t-list)))))
              (setf desig (list "false" (format NIL "Error: '~a' is not inside the map" elm))))
        ((> (length t-list) 1)
         (setf desig (list "false" (format NIL "Error: Two many elements in that list of type '~a'" elm) "" NIL)))
        ((= (length t-list) 0)
         (setf desig (list "false" (format NIL "Error: No object of type '~a' found in the world. Please correct your command." elm) "" NIL)))
        (t (format t "Something went wrong in 'action-scan-with-gesture'~%")
         (setf desig (list "false" (format NIL "Error: Something went wrong with command '~a'" cmd) "" NIL))))
  desig))               



;;##############################################################################;;
;;                                                                              ;;
;;                   Helping-Hands for parsing the instructions                 ;;
;;                                                                              ;;
;;##############################################################################;;


(defun swm->type->amount-elems (type)
  (let*((liste (instruct-mission::swm->geopose-elements))
        (new-liste NIL))
    (loop for index from 0 to (- (length liste) 1)
          do(cond((and (string-equal (second (nth index liste)) type)
                       (equal new-liste NIL))
                  (setf new-liste (append (list (nth index liste)) new-liste)))
                 (t ())))
    new-liste))


(defun swm->map-type->name (type)
  (let*((liste (instruct-mission::swm->geopose-elements))
        (pnom NIL))
    (loop for i from 0 to (- (length liste) 1)
          do(if(and (string-equal type (second (nth i liste)))
                    (equal pnom NIL))
               (setf pnom (third (nth i liste)))
               (setf pnom NIL)))
    pnom))


(defun get-elem-type (gelem)
 (swm->elem-name->type gelem))

