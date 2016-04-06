;;TEST UNIHB_CRAM

(in-package :startup-mission)

(defun create-the-semantic-map ()
 ;;(format t "swm->create-semantic-map~%")
  (let* ((obj (make-instance 'sem-map-utils::semantic-map
                 :parts
                 (hasht-function))))
   (format t "~a HASH MAP ~%" obj)
    (setf *sem-map* obj)
    obj))

(defun hasht-function()
    (let*((sem-liste (get-the-map))
        (intern-liste (internal-semantic-geom sem-liste))
        (hasht (make-hash-table :test #'equal)))
        (mapc (lambda (key-and-geom)
                         (let ((key (first key-and-geom))
                               (geom (second key-and-geom)))
                           (setf (gethash key hasht) geom)))
                       intern-liste)
    hasht))

(defun internal-semantic-geom (*swm-liste*)
  (let*((elem NIL))
    (loop for i from 0 to (- (length *swm-liste*) 1)
          do(setf elem (append (list (list (first (nth i *swm-liste*)) (make-instance
                                                                        sem-map-utils::'semantic-map-geom
                                                                        :type (second (nth i *swm-liste*))
                                                                        :name (first (nth i *swm-liste*))
                                                                        :owl-name "owl-name"
                                                                        :pose (third (nth i *swm-liste*))
                                                                        :dimensions (fourth (nth i *swm-liste*))
                                                                        :aliases NIL))) elem)))
    elem))

(defun get-the-map ()
  (format t "get-the-map~%")
    (let* ((map-name "http://knowrob.org/kb/ias_semantic_map.owl#GaltelliSimMap")
           (individuals NIL)
           (names NIL)
           (new-list NIL))
      (setf individuals (force-ll (json-prolog:prolog
             `("map_root_objects" ,map-name ?objs))))
      (setf names (cdaar individuals))
      (loop for i from 0 to (length names)
            do(let* ((var (internal-string (nth i names))))
                (setf indi-type (force-ll (json-prolog:prolog
                                           `(and ("map_object_type" ,var ?t)
                                                 ("rdf_atom_no_ns" ?t ?type)
                                                 ("rdf_atom_no_ns" ,var ?name)
                                                 ("rdf_has" ?SEM "http://knowrob.org/kb/knowrob.owl#objectActedOn" ,var)
                                                 ("rdf_has" ?SEM "http://knowrob.org/kb/knowrob.owl#eventOccursAt" ?TNS)
                                                 ("rdf_triple" "http://knowrob.org/kb/knowrob.owl#translation" ?TNS ("literal"("type" "_"?Translation)))
                                                 ("rdf_triple" "http://knowrob.org/kb/knowrob.owl#quaternion" ?TNS ("literal" ("type" "_" ?Quaternion)))
                                                 ("owl_has" ,var "http://knowrob.org/kb/knowrob.owl#depthOfObject" ("literal" ("type" "_" ?D)))
                                                ("atom_number" ?D ?Depth)
                                                ("owl_has" ,var "http://knowrob.org/kb/knowrob.owl#widthOfObject" ("literal" ("type" "_" ?W)))
                                                ("atom_number" ?W ?Width)
                                                 ("owl_has" ,var "http://knowrob.org/kb/knowrob.owl#widthOfObject" ("literal" ("type" "_" ?H)))
                                                ("atom_number" ?H ?Height)))))
                (setf type (internal-string (cdr (assoc  '?type (car indi-type)))))
                (setf name (internal-string (cdr (assoc '?name (car indi-type)))))
                (format t "name ~a~%" name)
                ;; (setf list-pose (force-ll (json-prolog:prolog
                ;;                            `(and ("rdf_has" ?SEM "http://knowrob.org/kb/knowrob.owl#objectActedOn" ,var)
                ;;                                  ("rdf_has" ?SEM "http://knowrob.org/kb/knowrob.owl#eventOccursAt" ?TNS)
                ;;                                  ("rdf_triple" "http://knowrob.org/kb/knowrob.owl#translation" ?TNS ("literal"("type" "_"?Translation)))
                ;;                                  ("rdf_triple" "http://knowrob.org/kb/knowrob.owl#quaternion" ?TNS ("literal" ("type" "_" ?Quaternion)))))))
                (setf quaternion (cdr (assoc '?quaternion (car indi-type))))
                (setf translation (cdr (assoc '?translation (car indi-type))))
                (setf tlist (split-by-one-space (internal-string translation)))
                (setf qlist (split-by-one-space (internal-string quaternion)))
               
                (setf pose (cl-transforms:make-pose  (cl-transforms:make-3d-vector (read-from-string (first tlist))
                                                                                   (read-from-string (second tlist))
                                                                                   (read-from-string (third tlist)))
                                                     (cl-transforms:make-quaternion (read-from-string (second qlist))
                                                                                    (read-from-string (third qlist))
                                                                                    (read-from-string (fourth qlist))
                                                                                    (read-from-string (first qlist)))))
                 (format t "pose ~a~%" pose)
                ;; (setf dim-list (force-ll (json-prolog:prolog
                ;;                           `(and ("owl_has" ,var "http://knowrob.org/kb/knowrob.owl#depthOfObject" ("literal" ("type" "_" ?D)))
                ;;                                 ("atom_number" ?D ?Depth)
                ;;                                 ("owl_has" ,var "http://knowrob.org/kb/knowrob.owl#widthOfObject" ("literal" ("type" "_" ?W)))
                ;;                                 ("atom_number" ?W ?Width)
                ;;                                  ("owl_has" ,var "http://knowrob.org/kb/knowrob.owl#widthOfObject" ("literal" ("type" "_" ?H)))
                ;;                                 ("atom_number" ?H ?Height)))))
                (format t "get-the-map ~a~%" i)
                (setf depth (cdr (assoc '?Depth (car indi-type))))
                 (format t "depth ~a~%" depth)
                
                (setf width (cdr (assoc '?Width (car indi-type))))
                  (format t "width ~a~%" width)
                (setf height (cdr (assoc '?Height (car indi-type))))
                  (format t "height ~a~%" height)
                (setf dim (cl-transforms:make-3d-vector height depth width))
                (setf new-list (append (list (list name type pose dim)) new-list))))
      (setf *swm-liste* new-list)
      new-list))

      (defun split-by-one-space (string)
    "Returns a list of substrings of string
divided by ONE space each.
Note: Two consecutive spaces will be seen as
if there were an empty string between them."
    (loop for i = 0 then (1+ j)
          as j = (position #\Space string :start i)
          collect (subseq string i j)
          while j))

      
(defun internal-string (sym)
  (remove #\' (symbol-name sym)))


