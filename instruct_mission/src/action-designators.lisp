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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; all the action designators
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; an action designator with one action-sequence => "move" plus integrations

(defun create-action-MOVE-designator (type agent cmd gesture)
  (format t "move action desig~%")
  (let*((acttype (read-from-string (instruct-mission::get-action (first (split-cmd cmd)))))
        (loc NIL)
        (ref NIL))
    (cond((= (length (instruct-mission::get-inside-list cmd)) 0)
          (setf loc (make-designator :location `((,(instruct-mission::direction-symbol
                                                    (instruct-mission::get-dir cmd)) ,gesture)))))
         (t (setf loc (make-designator :location `((,(instruct-mission::direction-symbol
                                                    (instruct-mission::get-dir cmd)) ,gesture)
                                                   (,(instruct-mission::direction-symbol (instruct-mission::get-dir (first (instruct-mission::get-inside-list cmd ))))
                                                    ,(instruct-mission::get-dir-cntnt3 (first (instruct-mission::get-inside-list cmd)))))))))
    (format t "loc ~a~%" loc)
 (setf ref (reference loc))
  (make-designator :action `((:cmd ,type)
                                         (:agent ,agent)
                                         (:type ,acttype)
                                         (:loc ,ref)))))


;; an action designator with one action-sequence => "detect"
(defun create-action-DETECT-designator (type agent cmd)
  (let*((act (read-from-string (instruct-mission::get-action cmd)))
        (col (read-from-string (instruct-mission::get-dir cmd)))
        (obj (instruct-mission::get-dir-cntnt3 cmd))
        (loc (make-designator :location `((:to :see)
                                          (:color ,col)
                                          (:type ,obj)))))
   ;; (setf ref (reference loc))    
    (make-designator :action `((:cmd ,type)
                               (:agent ,agent)
                               (:type ,act)
                               (:loc ,loc)))))


;; an action designator with one action-sequence => take
(defun create-action-TAKE-designator (type agent cmd)
  (let*((act (read-from-string (instruct-mission::get-action  cmd)))
        (obj (first (split-sequence:split-sequence #\) (instruct-mission::get-dir cmd)))))  
    (make-designator :action `((:cmd ,type)
                               (:agent ,agent)
                               (:type ,act)
                               (:obj ,(make-designator :object `((:a ,obj))))))))

;; an action designator with one action-sequence => move plus integrations and detect
(defun create-action-MOVE-DETECT-designator (type agent cmd gesture)
  (let*((acttype1  (read-from-string (instruct-mission::get-action (first (split-cmd cmd)))))
        (col (read-from-string (instruct-mission::get-dir (second (split-cmd cmd)))))
        (obj (instruct-mission::get-dir-cntnt3 (second (split-cmd cmd))))
        (loc NIL)
        (ref NIL))
    (cond((= (length (instruct-mission::get-inside-list (first (instruct-mission::split-cmd cmd)))) 0)
          (setf loc (make-designator :location `((,(instruct-mission::direction-symbol
                                                    (instruct-mission::get-dir cmd)) ,gesture)
                                                 (:to :see)
                                                 (:color ,col)
                                                 (:type ,obj)))))
         (t (setf loc (make-designator :location `((,(instruct-mission::direction-symbol
                                                    (instruct-mission::get-dir cmd)) ,gesture)
                                                   (,(instruct-mission::direction-symbol (instruct-mission::get-dir (first (instruct-mission::get-inside-list cmd))))
                                                    ,(instruct-mission::get-dir-cntnt3 (first (instruct-mission::get-inside-list cmd))))
                                                   (:to :see)
                                                   (:color ,col)
                                                 (:type ,obj))))))                                 
   (setf ref (reference loc))
  (make-designator :action `((:cmd ,type)
                                         (:agent ,agent)
                                         (:type ,acttype1)
                                         (:loc ,ref)))))

;; an action designator with one action-sequence => move, move
(defun create-action-MOVE-MOVE-designator (type agent cmd gesture)
 (let*((acttype1  (read-from-string (instruct-mission::get-action (first (split-cmd cmd)))))
       (acttype2 (read-from-string (instruct-mission::get-action (second(split-cmd cmd)))))
       (loc1 NIL)
       (loc2 NIL)
       (ref1 NIL)
       (ref2 NIL))
   (cond((= (length (instruct-mission::get-inside-list cmd)) 0)
         (setf loc1 (make-designator :location `((,(instruct-mission::direction-symbol
                                                   (instruct-mission::get-dir cmd)) ,gesture))))   
         (setf loc2 (make-designator :location `((,(instruct-mission::direction-symbol
                                                    (instruct-mission::get-dir (second (instruct-mission::split-cmd cmd)))) ,gesture)))))
        
        (t (cond((and (= (length (instruct-mission::get-inside-list
                             (first (instruct-mission::split-cmd cmd)))) 1)
                      (= (length (instruct-mission::get-inside-list
                                  (second (instruct-mission::split-cmd cmd)))) 0))                 
                 (setf loc1 (make-designator :location `((,(instruct-mission::direction-symbol
                                                            (instruct-mission::get-dir cmd))
                                                          ,gesture)
                                                         (,(instruct-mission::direction-symbol
                                                            (instruct-mission::get-dir
                                                             (first
                                                              (instruct-mission::get-inside-list cmd))))
                                                          ,(instruct-mission::get-dir-cntnt3
                                                            (first
                                                             (instruct-mission::get-inside-list cmd)))))))
                 (setf loc2 (make-designator :location `((,(instruct-mission::direction-symbol
                                                            (instruct-mission::get-dir
                                                             (second (instruct-mission::split-cmd cmd))))
                                                          ,gesture)))))
                
                ((and (= (length (instruct-mission::get-inside-list
                                 (first (instruct-mission::split-cmd cmd)))) 0)
                     (= (length (instruct-mission::get-inside-list
                                 (second (instruct-mission::split-cmd cmd)))) 1))
                (setf loc1 (make-designator :location `((,(instruct-mission::direction-symbol
                                                           (instruct-mission::get-dir cmd)) ,gesture))))                
                (setf loc2 (make-designator :location `((,(instruct-mission::direction-symbol
                                                             (instruct-mission::get-dir  (second (instruct-mission::split-cmd cmd))))
                                                          ,gesture)
                                                         (,(instruct-mission::direction-symbol
                                                            
                                                            (instruct-mission::get-dir
                                                             (first
                                                              (instruct-mission::get-inside-list cmd))))
                                                          ,(instruct-mission::get-dir-cntnt3
                                                            (first
                                                             (instruct-mission::get-inside-list cmd))))))))
                (t (setf loc1 (make-designator :location `((,(instruct-mission::direction-symbol
                                                            (instruct-mission::get-dir cmd))
                                                           ,gesture)
                                                         (,(instruct-mission::direction-symbol
                                                            (instruct-mission::get-dir
                                                             (first
                                                              (instruct-mission::get-inside-list cmd))))
                                                          ,(instruct-mission::get-dir-cntnt3
                                                            (first
                                                             (instruct-mission::get-inside-list cmd)))))))
            (setf loc2 (make-designator :location `((,(instruct-mission::direction-symbol
                                                             (instruct-mission::get-dir  (second (instruct-mission::split-cmd cmd))))
                                                          ,gesture)
                                                         (,(instruct-mission::direction-symbol
                                                            
                                                            (instruct-mission::get-dir
                                                             (first
                                                              (instruct-mission::get-inside-list (second (instruct-mission::split-cmd cmd))))))
                                                          ,(instruct-mission::get-dir-cntnt3
                                                            (first
                                                             (instruct-mission::get-inside-list (second (instruct-mission::split-cmd cmd)))))))))))))                
   ;;  (setf ref1 (reference loc1))
   ;;  (setf ref2 (reference loc2))
   (format t "ds---> ~a~%" cmd)
 (list (make-designator :action `((:cmd ,type)
                                              (:agent ,agent)
                                              (:type ,acttype1)
                                              (:loc ,loc1)))
                   (make-designator :action `((:cmd ,type)
                                              (:agent ,agent)
                                              (:type ,acttype2)
                                              (:loc ,loc2))))))

;; an action designator with one action-sequence => move, take
(defun create-action-MOVE-TAKE-designator (type agent cmd gesture)
  (let*((acttype1  (read-from-string (instruct-mission::get-action (first (split-cmd cmd)))))
        (acttype2  (read-from-string (instruct-mission::get-action (second (split-cmd cmd)))))
        (obj (instruct-mission::get-dir-one (second (split-cmd cmd))))
        (loc NIL)
        (ref NIL)
        (obj (instruct-mission::get-dir-one (second (instruct-mission::split-cmd cmd)))))
    (cond((= (length (instruct-mission::get-inside-list (first (instruct-mission::split-cmd cmd)))) 0)
          (setf loc (make-designator :location `((,(instruct-mission::direction-symbol
                                                    (instruct-mission::get-dir cmd)) ,gesture)))))
         (t (setf loc (make-designator :location `((,(instruct-mission::direction-symbol
                                                    (instruct-mission::get-dir cmd)) ,gesture)
                                                   (,(instruct-mission::direction-symbol (instruct-mission::get-dir (first (instruct-mission::get-inside-list cmd))))
                                                    ,(instruct-mission::get-dir-cntnt3 (first (instruct-mission::get-inside-list cmd)))))))))
    (setf ref (reference loc))
    (list (make-designator :action `((:cmd ,type)
                                     (:agent ,agent)
                                     (:type ,acttype1)
                                     (:loc ,ref)))
          (make-designator :action `((:cmd ,type)
                                     (:agent ,agent)
                                     (:type ,acttype2)
                                     (:obj ,(make-designator :object `((:a ,obj)))))))))


(defun ned2wgs (postpst)
  (let*((a 6378137)
        (b 6356752.3124)
        (lat_home 44.153278)
        (lon_home 12.241426)
        (alt_home 41)
        (ori (cl-transforms:origin postpst))
        (ori-x (cl-transforms:x ori))
        (ori-y (cl-transforms:y ori))
        (ori-z (cl-transforms:z ori))
        (e (sqrt (- 1 (/ (* b b) (* a a)))))
        (lat_home_rad (* lat_home (/ pi 180.0)))
      ;;  (lon_home_rad (* lon_home (/ pi 180.0)))
        (intern1 (* (sin lat_home_rad) (sin lat_home_rad)))
        (intern2 (* (sqrt (- 1 (* e e))) intern1))  
        (radius (/ a intern2))      
        (lat (+ (/ ori-x (* radius (/ 180.0 pi))) lat_home))
        (lon (+ (/ ori-y (* radius (/ 180.0 (/ pi (cos lat_home_rad))))) lon_home))
        (alti (+ alt_home ori-z)))
 (cl-transforms:make-pose (cl-transforms:make-3d-vector lat lon alti)
                          (cl-transforms:make-identity-rotation ))))
      
    
        
(defun wgs2ned (postpst)
  (let*((ANTON 6378137)
        (BERTA 6356752.3124)
        (lat_home 44.153278)
        (lon_home 12.241426)
        (alt_home 41.0)
        (ori (cl-transforms:origin postpst))
        (ori-lat (cl-transforms:x ori))
        (ori-lon (cl-transforms:y ori))
        (ori-alt (cl-transforms:z ori))
        (euler (sqrt (- 1 (/ (* BERTA BERTA) (* ANTON ANTON)))))
        (lat_rad (* ori-lat (/ pi 180.0)))
        (lon_rad (* ori-lon (/ pi 180.0)))
        (lat_home-rad (* lat_home (/ pi 180)))
        (lon_home-rad (* lon_home (/ pi 180)))
        (intern1 (* (sin lat_home-rad) (sin lat_home-rad)))
        (intern2 (* (sqrt (- 1 (* euler euler))) intern1))   
        (radius (/ a intern2))      
        (iks (* (- lat_rad lat_home-rad) radius))
        (yps (* (* (- lon_rad lon_home-rad) radius) (cos lat_home-rad)))
        (zed (- ori-alt alt_home)))
    (format t "~a~%"  (- lon_rad lon_home-rad))
    (format t "~a~%" radius)
    (cl-transforms:make-pose (cl-transforms:make-3d-vector iks yps zed)
                             (cl-transforms:orientation postpst))))
