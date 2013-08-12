
(defparameter actr-done nil)
(defvar *params* nil)
(defvar *current-episode* nil)
(defparameter *retrieve-error* 0)

(defun reset-vars()

  (setf *perc-correct-turns* 0)

  (setf *tot-dirs-list* nil)
  (setf *tot-users-turns* nil)
  (setf *total-perc-correct-turns* 0)

  (setf *deviation-score* 0)
  (setf *jitter-score* 0)
  (setf *total-deviation-score* 0)
  (setf *tot-total-devs* 0)
  (setf *tot-list-arrow-jitter* nil)
)

(defun run-m-1 (&key (s "V-DB-N3" ) (strategy 'I) (params '(.5 .10  20 t) ))
 (setf *params* params)
 (load (concatenate 'string (directory-namestring (get-load-path)) "Model/navback-model.lisp"))
 (setf actr-done nil)
 (setf *retrieve-error* 0)
 (run-model :cnd1 s :strategy strategy)
 (while (null actr-done)
        (sleep 5))
 ;(write-log-file)
 (format t " Results: ~S ~S ~S" *params* *save-results* *retrieve-error*))
 

(defun run-m (&optional (n 2) &key (cnds '(  "V-DB-N1"  "A-N1" "V-A-N1" "V-DB-N3"  "A-N3" "V-A-N3")) (strategy 'I) (v "~/navback-trace.lisp"  ))
  (let ((run-index 0)
        (params '(
                  ;(.5 .15 21 )
                  ;(.6 .15 21 )
                  ;(.5 .05 24 )
                  (.5 .20 24 )
                  ;(.6 .15)
                 ; (.5 .20 15)
                  ;(.5 .20 21)
                  ;(.6 .20 21)
                  (.5 .10 24 )
                  ;(.5 .10 21)
                  ;(.6 .10 21)                 
                  ))
        ) 
    (if (null (probe-file "~/NavbackModelRuns.txt"))
        (with-open-file (fs "~/NavbackModelRuns.txt" :direction :output)
          (write 'cnd :stream fs) (write-char #\tab fs)
          (write 'str :stream fs) (write-char #\tab fs)
          (write 'bll :stream fs) (write-char #\tab fs)
          (write 'ans :stream fs) (write-char #\tab fs)
          (write 'epi :stream fs) (write-char #\tab fs)
          (write 'dev :stream fs) (write-char #\tab fs)
          (write 'acc :stream fs) (write-char #\tab fs)
          (write 'err :stream fs) (write-char #\newline fs)))
        
    (with-open-file (fs "~/NavbackModelRuns.txt" :direction :output :if-exists :append :if-does-not-exist :create)
      (dotimes (j n)
        (dolist (s cnds)
          (dolist (p params)
            (format t "~%running ~S ~S" s p)
            (setf *params* (append p (list v)))
            (reset-vars)
            (load (concatenate 'string (directory-namestring (get-load-path)) "Model/navback-model.lisp"))
            (setf *retrieve-error* 0)
            (setf actr-done nil)
            (run-model :cnd1 s :strategy strategy)
            (while (null actr-done)
                   (sleep 5))
            (write-log-file)
            (format t " Results: ~S " *save-results* )
            (write (read-from-string s) :stream fs) (write-char #\tab fs)
            (write strategy :stream fs) (write-char #\tab fs)
            (write (first p) :stream fs) (write-char #\tab fs)
            (write (second p) :stream fs) (write-char #\tab fs)
            (write (third p) :stream fs) (write-char #\tab fs)
            (write (first *save-results*) :stream fs) (write-char #\tab fs)
            (write (second *save-results*) :stream fs) (write-char #\tab fs)
            (write *retrieve-error* :stream fs) (write-char #\newline fs)
            (setf *log* nil)
            (reset)
            (sleep 5)
          ))))))


;(defparameter +actr-run-time+ 3600)
(defparameter +actr-output+ nil)
(defparameter +debug+ nil)

(defvar *log* nil)
(defun log-info (lst)
  (push (list (get-internal-real-time) (mp-time) lst) *log*))

(defun log-header (params strategy)
  (let ((date-string nil))
    (multiple-value-bind
        (second minute hour day month year daylight zone other) 
        (get-decoded-time) 
      (declare (ignore second daylight zone other))
      (setf date-string (format nil "~d/~d/~d  ~d:~2d" month day year hour minute)))
    
    (log-info (list "CW-EVENT" "EXPERIMENT-NAME" "Navback"))
    (log-info (list "CW-EVENT" "SCREEN-RESOLUTION" (capi:screen-width (capi:convert-to-screen)) (capi:screen-height (capi:convert-to-screen))))
    (log-info (list "CW-EVENT" "DATE" date-string))
    (log-info (list "CW-EVENT" "Universal-time" (get-universal-time)))
   ; (log-info (list "CW-EVENT" "Unix-time" (unix-time)))
    (log-info (list "CW-EVENT" "ID" "Model"))
    (log-info (list "MODEL-EVENT" "PARAMS" params))
    (log-info (list "MODEL-EVENT" "STRATEGY" strategy))
    
  ))

(defun make-uid ()
  (multiple-value-bind (second minute hour day month year daylight zone other) (get-decoded-time)
    (declare (ignore  daylight zone other))
      (format nil "~2,'0D~2,'0D~2,'0D_~2,'0D~2,'0D~2,'0D"
                         (mod year 2000)
                         month
                         day
                         hour
                         minute
                         second)))

(defun write-log-file (&key (id 1)  (log (reverse *log*)))
  (multiple-value-bind (sc mn hr mo dy yr a b c) (decode-universal-time (get-universal-time))
    (declare (ignore a b c))
    (let* ((dir (concatenate 'string (directory-namestring (get-load-path)) "MNT/Data/"))
           (uid (make-uid))
           (fn (concatenate 'string dir "Navback-00_" (model? +exp-cnd+) "-" uid)))
      (with-open-file (fs fn :direction :output)
        (dolist (lst log)
          (write uid :stream fs) (write-char #\tab fs)
          (write (model? +exp-cnd+) :stream fs) (write-char #\tab fs)
          (write (first lst) :stream fs )
          (dolist (item (third lst))
            (write-char #\tab fs)
            (write (if (stringp item) (read-from-string item) item) :stream fs))
          (write-char #\newline fs))))))

(defmethod give-feedback ((cnd between-subj-cnd))
  (format +actr-output+ "~%Your Scores for BLOCK ~A ~%~%Deviation Score: ~A ~%Percentage of Correct Turns: ~A ~%" 
                               *block* (round *deviation-score*) *perc-correct-turns*)
  
  
  (sleep 2)
)


(defmethod give-feedback ((cnd within-subj-cnd)) 
  (format +actr-output+  "~%Your Scores for BLOCK ~A ~%~%Deviation Score: ~A ~%Percentage of Correct Turns: ~A ~%~%Next is ~A Memory Load" 
                               *block* (round *deviation-score*) *perc-correct-turns* (if (eql *nback* 1) "1-Back" "3-Back"))
  (sleep 2)
  )



(defun cw-speak (str &optional &key (voice 1) (model-string nil))
 (new-word-sound str)
    
  (lw-speak str :voice voice ))

(defun get-model-cnd ()
  (cond ((and (eql *condition* 1) (eql *dirtype* 1))
         'visual)
        ((and (eql *condition* 1) (eql *dirtype* 2))
         'visual-A)
        (t 'audio)))

(defun print-audicon ()
  (let ((module (get-module :audio)))
    (if module
        (progn
          (format t "~%Sound event    Att  Detectable  Kind           Content           location     onset     offset delay     Sound ID")
          (format t "~%-----------    ---  ----------  -------------  ----------------  --------     -----     ------ --------  --------")
          
          (dolist (x (current-audicon module))
            (print-audio-feature x))) 
      (print-warning "No audio module found"))))

(defmethod print-audio-feature ((feat sound-event))
  (format t "~%~15a~5A~12A~15A~18s~10a~8,3f   ~8,3f ~8,3f   ~a"
    (ename feat)
    (attended-p feat)
    (detectable-p feat)
    (kind feat)
    (content feat)
    (location feat)
    (ms->seconds (onset feat))
    (ms->seconds (offset feat))
    ;(snd-string feat)
    (ms->seconds (delay feat))
    (sname feat)))



(defun run-model (&key (rt *run-time* ) (cnd1 "V-A-N1") (strategy 'I ) (dbg '(production declarative)) )
  (setf +exp-cnd+ (make-instance 'between-subj-cnd))
  (setf (model? +exp-cnd+) cnd1)
  (set-exp-parameters cnd1 +exp-cnd+) 
  (setf  *run-time* rt)
  (setf +debug+ dbg)
  (cond ((member cnd1 '("V-A-N1" "V-DB-N1" "A-N1") :test 'equal)
         (load (concatenate 'string (directory-namestring (get-load-path)) "Model/intersection1.lisp"))
         (load (concatenate 'string (directory-namestring (get-load-path)) "Model/rehearse1.lisp"))
         (load (concatenate 'string (directory-namestring (get-load-path)) "Model/" cnd1)))
        (t
         (load (concatenate 'string (directory-namestring (get-load-path)) "Model/intersection3.lisp"))
         (load (concatenate 'string (directory-namestring (get-load-path)) "Model/rehearse3.lisp"))
         (load (concatenate 'string (directory-namestring (get-load-path)) "Model/" 
                     (if (eql strategy 'R) cnd1 (concatenate 'string cnd1 "-I"))  ".lisp"))))
  (log-header *params* strategy)
  
  
  
  (add-dm-fct `((g1 isa ,(if (member cnd1 '("V-DB-N3-I" "V-DB-N3" "V-DB-N1") :test 'equal) 'start-both 'start-jitter))))
  (goal-focus g1)
  (drive))

(defun run-actr (so)
  (setq *standard-output* so)
  (setq +actr-output+ so) 
   
  (run-until-condition (lambda()  (null (capi:interface-visible-p (get-interface)))) :real-time t)
  (setf actr-done t)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *update-visicon* nil)

(defun my-format (&rest str/args)
  (when (member 'process +debug+) 
    (apply 'format +actr-output+ str/args)
    (format +actr-output+ " ~S ~S ~S"  (get-process-name) (get-internal-real-time) (mp-time))))

(defun my-proc-display (&rest reason)
  (my-format "~%Proc-display ~S" reason )
  (setf *update-visicon* t)

  (if (member 'proc-display +debug+)  (log-info `(proc-display ,reason))))

(defmethod device-update  ((device capi:interface) time)
  (when *update-visicon*
    (setf *update-visicon* nil)
    (proc-display)
    (my-format  "~%Proc-display-done")))
  
(defun get-pinboard-device ()
  (road (get-device)))

(defun reset-model-turns ()
  (let ((g (get-module goal)))
    (dolist (item (tgm-chunk-set g)) (thread-clear g 'GOAL item)))
  ;(format +actr-output+ "Resetting Goal")
  (goal-focus start-goal))

(defmethod start-drive :before ((win capi:interface))
  (cond ((null (get-device)) 
         (install-device win)
         (proc-display)
         ;(print-visicon)
         (mp:process-run-function "ACTR" '() #'run-actr *standard-output*))
        (t
         
         ;(reset-model-turns)
         ;(mp:process-run-function "ACTR" '() #'run-actr *standard-output*) 
         )))

(defun get-process-name ()
  (mp:process-name (mp:get-current-process)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmethod display-drive-directions :after (str (pane drive-display-pane) )
  (setf *current-direction* (direction1 (get-interface)))
  ;(format +actr-output+ "~%New-Directions ~S" str) 

  (capi:apply-in-pane-process pane 'my-proc-display 'directions str) )

(defmethod draw-intersection :after ((interface capi:interface)) 
  ;(format +actr-output+ "~%Intersection ~S ~S ~S ~S" (top-dash interface) (bot-dash interface) (topsqy interface) (botsqy interface))
  (capi:apply-in-pane-process (road interface) 'my-proc-display 'intersection (topsqy interface) (botsqy interface)) )

(defmethod place-arrow :after (image x y (interface capi:interface)) 
  (if (> x 510) (break))
  (when (eql image (arrow interface)) 
    ;(format +actr-output+ "~%Arrow ~S ~S" x y)
    (capi:apply-in-pane-process (road interface) 'my-proc-display 'arrow x y)))

(defmethod update-displays :after ((interface capi:interface))
 (capi:apply-in-pane-process (correct-turns interface) 'my-proc-display 'feedback)
)
  

(defun cw-task-finished () )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmethod visicon-update ((vis-mod vision-module) &optional (count t))
  (check-finsts vis-mod)
  (update-attended-loc vis-mod)
  (stuff-visloc-buffer vis-mod)
  (when count
    (length (visicon-chunks vis-mod))))

(let ((fix-start nil))
(defmethod encoding-complete :around ((vis-mod vision-module) loc scale &key (requested t))
  (let ((obj (call-next-method)))
    (log-info `(eye-fix x ,(chunk-slot-value-fct loc 'screen-x) y,(chunk-slot-value-fct loc 'screen-y) start ,fix-start end ,(get-internal-real-time) object ,obj ))
    obj))

(defmethod move-attention :before ((vis-mod vision-module) &key location scale)
  (setf fix-start (get-internal-real-time)))
)

(defmethod update-device :around ((devin device-interface) time)
  (if (capi:interface-visible-p (device devin)) (call-next-method))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmethod view-position ((view capi:element))
  (capi:with-geometry view (vector capi:%x% capi:%y%)))

(defmethod view-size ((view capi:element))
  (capi:with-geometry view (vector capi:%width% capi:%height%)))

(defmethod device-update-eye-loc ((device capi:interface) (xyloc vector)) ;;called from emma
  ;(update-me *eye-spot* device xyloc)
)

(defmethod update-me ((object capi:pinboard-object) (device capi:interface) xyloc)
  (let ((pb (get-pinboard-device))) ;;;
    (capi:execute-with-interface device
                                 #'(lambda (pb object  x y )
                                     (setf (capi:pinboard-pane-position object)
                                           (values x y))
                                     (unless (capi:pinboard-object-pinboard object)
                                       (capi:manipulate-pinboard
                                        pb object :add-top )))
                                 pb object
                                 (- (svref xyloc 0) (object-x-adjustment object))
                                 (- (svref xyloc 1) (object-y-adjustment object))
                                 )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun str->words (str words)
 (let ((pos (position #\newline str)))
   (if (null pos) 
       (append words (list str))
     (str->words (subseq str (1+ pos)) (append words (list (subseq str 0 pos)))))))

(defmethod build-vis-locs-for ((self capi:interface) (vis-mod vision-module))  
  (with-slots (arrow-obj rec-tl-obj rec-tr-obj rec-bl-obj rec-br-obj visual-directions correct-turns road bot-dash ) self ;deviation-score
  (let* ((objs1 (list arrow-obj rec-tl-obj rec-tr-obj rec-bl-obj rec-br-obj correct-turns road bot-dash ))
         (objs (if (eql *modality* 1) (append objs1 (list visual-directions)) objs1))
         (base-ls (flatten
                    (mapcar #'(lambda (obj) (build-vis-locs-for obj vis-mod)) objs)))) ;deviation-score
    
    base-ls)))

(defmethod build-vis-locs-for  ((self FIXNUM) (vis-mod vision-module)) 
    (let ((f (car (define-chunks-fct `((isa visual-location 
                                      screen-x 500
                                      screen-y ,self
                                      kind line
                                      value dashed
                                      height 2
                                      width 1000
                                      color black))))))
      ;(if (<= 445 self 455) (capi:beep-pane))
      (setf (chunk-visual-object f) self)
      f))

(defmethod build-vis-locs-for  ((self capi:output-pane) (vis-mod vision-module)) 
  (capi:with-geometry self
    (let ((f (car (define-chunks-fct `((isa visual-location 
                                      screen-x ,(floor capi:%width% 2)
                                      screen-y 450
                                      kind road
                                      height 50
                                      width 150
                                      color black))))))
      
      (setf (chunk-visual-object f) self)
      f)))

(defmethod build-vis-locs-for  ((self drive-display-pane) (vis-mod vision-module)) 
  (capi:with-geometry self
    (let* ((font-spec (view-font self))
           (words (str->words (capi:display-pane-text self) nil))
           (text nil)
           (line-h (if (plusp (length words)) (floor capi:%height%  (length words))))
           res)
      (dotimes (i (length words))
        (setq text (nth i words))
        (setq text (remove #\space text))
        (unless (equal text "")
          (multiple-value-bind (ascent descent)
              (font-info  font-spec self)
            (push (first
                   (build-string-feats vis-mod :text text
                              :start-x (1+ (point-h (view-position self)))  ;;;;(xstart self)
                              :y-pos (+ (point-v (view-position self)) (* i line-h)
                                        descent (round ascent 2))
                              :width-fct #'(lambda (str)
                                             (string-width str font-spec))
                              :height ascent :obj self))
                  res))))
    (dolist (loc res) (setf (chunk-visual-object loc) self) (set-chunk-slot-value-fct loc 'color (current-step (get-interface))) )
    res)))

(defmethod build-vis-locs-for ((self screen-rec) (vm vision-module))
  (declare (ignore vis-mod))
  (let* ((interface (get-interface))
         (f (car (define-chunks-fct `((isa rec-location
                                          screen-x ,(case (name self) ((top-left bottom-left) 0) 
                                                                      ((top-right bottom-right) 580)) 
                                          screen-y ,(case (name self) ((top-left top-right) (topsqy interface)) 
                                                      ((bottom-left bottom-right) (botsqy interface))) 
                                          height ,(case (name self) ((top-left top-right) (topsqheight interface)) 
                                                    ((bottom-left bottom-right) (botsqheight interface))) 
                                          width 420
                                          kind rec
                                          name ,(name self)
                                          color darkgreen
                                          ))))))
   ;  (case (name self) ((top-left top-right) (topsqy interface)) 
   ;    ((bottom-left bottom-right) (if (or (> (botsqy interface) 450)
   ;                (and (> (botsqy interface) 130) (< (botsqy interface) 285))) (capi:beep-pane))))
    (setf (id self) f)
    (setf (chunk-visual-object f) self)
    f))
(defvar *dir* nil)
(defmethod build-vis-locs-for ((self screen-arrow) (vm vision-module)) 
  (let* ((interface (get-interface))
         (f (if (eql *dirtype* 2)
                (car (define-chunks-fct `((isa arrow-location 
                                               screen-x ,(arrow-x interface)
                                               screen-y ,(arrow-y interface)
                                               value ,(if(eql 425  (arrow-y interface)) 'turning (arrow-jitter interface))
                                               kind arrow
                                               height 50
                                               width 50
                                               color ,(if (dir self) 'white 'green)
                                               dir ,(if (eql *dirtype* 2) (case (dir self) (left 'L) (right 'R) (forward 'F)))))))
              (car (define-chunks-fct `((isa arrow-location 
                                               screen-x ,(arrow-x interface)
                                               screen-y ,(arrow-y interface)
                                               value ,(if(eql 425  (arrow-y interface)) 'turning (arrow-jitter interface)) 
                                               kind arrow
                                               height 50
                                               width 50
                                               color green)))))))
    (if (eql *dirtype* 2) (push (list (mp-time) (dir self)) *dir*))    
    (setf (id self) f)
    (setf (freq self) (aif (freq self) (+ .01 it) .01))
    (setf (chunk-vis-obj-freq f) (freq self))
    (setf (chunk-visual-object f) self)
    f))

(defmethod vis-loc-to-obj :around ((self screen-arrow) loc)
  (let ((v-o (call-next-method)))
    (setf (chunk-vis-obj-freq v-o) (chunk-vis-obj-freq loc))
    (when (member (model? +exp-cnd+) '("V-A-N1" "V-A-N3" "V-A-N3-I") :test 'equal)
      
        (set-chunk-slot-value-fct  v-o 'dir (chunk-slot-value-fct loc 'dir)))
    v-o))

(defun log-prod-fire (production-name)
 (if (member 'production +debug+)  (log-info `(production-fired  ,production-name ,(mp-time)))))

(defmethod device-handle-keypress :before ((device capi:interface) key)
  (if (member 'keypress +debug+)  (log-info `(pressed-key ,key))))

(defvar *current-episode* 0)
(defun my-trace-filter(e)
  (if (and (eql (evt-action e) 'set-buffer-chunk) (eql (evt-module e) 'declarative)
             (member 'declarative +debug+))
    (log-info `(declarative set-buffer-chunk ,(evt-params e) ,(mp-time) ,(get-chunk-activation (second (evt-params e) ))
                            ,*current-episode* ,(chunk-slot-value-fct (second (evt-params e) ) 'dir ))))
  (not (and (eql (evt-action e) 'mod-buffer-chunk) (eql (evt-module e) 'temporal))))

(defun get-random-dir()
  (nth (random 3) '(L R F)))

(defun check-intersection-tm (tm)
  (+ tm 1))

(defun clear-dir ()
  (setf (dir (arrow-obj (get-interface))) nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro defp (&rest body)
  `(p-fct ',body))

(defmacro defp* (&rest body)
  `(p*-fct ',body))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
