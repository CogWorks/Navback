(defun get-device ()
  (device (current-device-interface)))

(defun get-vision ()
  (get-module :vision))

(defun get-visicon ()
  (visicon (get-module :vision)))

(defun get-visicon-chunks ()
  (visicon-chunks (get-module :vision)))

(defun get-chunk-types ()
  (let ((res nil))
    (dolist (c (all-dm-chunks (get-module declarative)))
      (push (act-r-chunk-type-name (act-r-chunk-chunk-type (get-chunk c))) res))
    (remove-duplicates res)))

(defun get-production-names ()
 (mapcar (lambda(x) (production-name x)) (procedural-productions (get-module procedural))))

(defun get-production-by-name (name)
  (get-production  name))

(defun show-buffers (&optional (bufs (buffers)))
  (if (atom bufs)
    (buffer-chunk-fct (list bufs))
    (dolist (buf bufs)
      (buffer-chunk-fct (list buf)))))

;(buffer-status)
;(buffers)


;(threads-pprint)
;(tgm-chunk-set (get-module goal))


(defun module-names ()
 (maphash (lambda(key val) (print key)) (act-r-modules-table *modules-lookup*)))

(defun show-events ()
  (meta-p-events (get-mp (current-meta-process))))

(defun get-all-chunks ()
 (act-r-model-chunks-table (current-model-struct)))

(defun sdp-by-type (typ) 
  (sdp-fct (no-output (sdm-fct `(isa ,typ)))))

(defun get-chunk-activation (name) 
  (first (first (no-output (sdp-fct `((,name) :activation))))))

(defun get-chunk-from-set-by-type (typ) 
  (let ((pos (position typ (mapcar (lambda(x) (act-r-chunk-type-name (act-r-chunk-chunk-type (get-chunk x)))) 
                                   (tgm-chunk-set (get-module goal))))))
    (if pos (nth pos (tgm-chunk-set (get-module goal))))))

(defun remove-from-set (typ)
  (aif (get-chunk-from-set-by-type typ) (thread-clear (get-module goal) 'goal it)))

(defun find-chunk-type (type lst)
  (find-if (lambda(x) (eql type 
                           (act-r-chunk-type-name (act-r-chunk-chunk-type (get-chunk x)))))
           lst))

(defun get-chunk-activations(typ)
  (mapcar (lambda(name) (list name (get-chunk-activation name))) (no-output (sdm-fct `(isa ,typ)))))

(defun disable-by-condition (cnd)
  (let* ((cnd-len (length (if (stringp cnd) cnd (symbol-name cnd))))
         (prods (remove-if (lambda(p) (or (eql #\* (elt (symbol-name p) 0))
                                          (equal (subseq (symbol-name p) 0 cnd-len) (if (stringp cnd) cnd (symbol-name cnd)))))  
                           (get-production-names ))))
    (print prods)
    (pdisable-fct prods)))
