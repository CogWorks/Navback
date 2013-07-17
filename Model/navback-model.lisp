
(clear-all)

(define-model drive-model)  ;;name of model

(set-visloc-default-fct '(isa visual-location kind dummy))

(sgp ;:v t ;"~/navback-trace.lisp" 
     :cycle-hook log-prod-fire :needs-mouse nil :ol nil ; :DECLARATIVE-FINST-SPAN 30 :DECLARATIVE-NUM-FINSTS 6 
     :visual-movement-tolerance 5.0  :blc 3.0 :act nil :crt nil   
     :esc t :trace-detail low :er t  :show-focus nil  :lf 0.5 :sact t
     :do-not-harvest imaginal :do-not-harvest contextual
     :MOTOR-FEATURE-PREP-TIME 0
     :time-master-start-increment 1.0
     :TIME-MULT 1.0001 :trace-filter my-trace-filter
     :conflict-set-hook cs-hook :DIGIT-DETECT-DELAY .150
)

(sgp-fct `(:bll ,(first *params*) :ans ,(second *params*) :v ,(fourth *params*)))

(set-audloc-default :location external :attended nil)

;;; Chunk type definitions
(chunk-type start-jitter)
(chunk-type start-both)
(chunk-type mnt init jitter intersection rehearse)
(chunk-type arrow-task state)
(chunk-type db-task state monitor-tm pos)
(chunk-type rehearse-task state turn-dirs)
(chunk-type meaning sym means)

(chunk-type turn-dir episode dir )
(chunk-type spatial-rep ulx uly lly turn)

(chunk-type turn-list dir1 dir2 dir3 episode)

(chunk-type turn-position dir newdir)

(chunk-type (rec-location (:include visual-location)) name)
(chunk-type (arrow-location (:include visual-location)) dir)
(chunk-type (rec (:include visual-object)))
(chunk-type (arrow (:include visual-object)) dir)

(define-chunks (WAIT isa chunk) (VISUAL isa chunk) (ENCODE isa chunk) (EASY isa chunk) (HARD isa chunk)
               (ARROW isa chunk) (BOTTOM-LEFT isa chunk) (REC isa chunk) (RECALL-DIR isa chunk) 
               (TURN-COMPLETE isa chunk) (ATTEND isa chunk) (TRACK isa chunk) (ENCODE2A isa chunk) (ENCODE2 isa chunk)
               (ENCODE3A isa chunk) (ENCODE3 isa chunk)
               (FIND-ARROW isa chunk) (PRE isa chunk) (ALL isa chunk) (PROC-DIR isa chunk) (CHECK isa chunk) 
               (CALC-POS isa chunk) (CURR-DIR isa chunk) (NEXT isa chunk) (LAST isa chunk)
               (TOP-LEFT isa chunk) (DARKGREEN isa chunk) (TOP-RIGHT isa chunk) (ROAD isa chunk) (DASHED isa chunk)
               (DIR1 isa chunk) (DIR2 isa chunk) (DIR3 isa chunk))

(set-similarities  (CURR-DIR LAST -3.1) (NEXT LAST -0.3)) ;(CURR-DIR NEXT -0.31)


;;; Initialize Declarative Memory

(add-dm 
  
 (F isa meaning sym F means "forward") (R isa meaning sym R means "right") (L isa meaning sym L means "left")
 )

(set-base-levels-fct '((F 10000 0.0) (R 10000 0.0) (L 10000 0.0)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp *start-mnt
 =goal> isa start-jitter
 ?temporal> buffer empty
 ?contextual> buffer empty
==>
 +temporal> isa time
 +goal> isa arrow-task state find-arrow
 +contextual> isa mnt jitter t init t)

(defp *start-mnt1
 =goal> isa start-both
 ?temporal> buffer empty
 ?contextual> buffer empty
==>
 +temporal> isa time
 +goal> isa arrow-task state find-arrow
 +goal> isa db-task state look-for-directions
 +contextual> isa mnt jitter t init t)

(load (concatenate 'string (directory-namestring (get-load-path)) "Model/jitter.lisp"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sdil ()
  (sdm isa instruction-list)
  (sdp-by-type 'instruction-list))
#|
(defmethod update-attended-loc ((eye-mod emma-vis-mod))
  ;; if we're tracking or moving around, ignore this 
  (when (or (tracked-obj eye-mod) (moving-attention eye-mod) 
            (eq 'BUSY (exec-s eye-mod)))
    (return-from update-attended-loc nil))
  ;; when do we update?
  ;; [1] when we're looking at an object and it's gone
  ;; [2] when we're looking at nothing and something appears 
  (when (or (and (currently-attended eye-mod)
                 (or (not (chunk-p-fct (currently-attended eye-mod)))
                     (not (object-present-p eye-mod (currently-attended eye-mod)))))
            (and (current-marker eye-mod)
                 (null (currently-attended eye-mod))
                 (within-move eye-mod (xy-loc (current-marker eye-mod)))))
#|
        (format +actr-output+ "~%update attended loc  ~S ~S ~S " 
                (and (currently-attended eye-mod)
                     (or (not (chunk-p-fct (currently-attended eye-mod)))
                         (not (object-present-p eye-mod (currently-attended eye-mod)))))  
                (and (current-marker eye-mod)
                     (null (currently-attended eye-mod))
                     (within-move eye-mod (xy-loc (current-marker eye-mod)))) 
                (currently-attended eye-mod))
|#
        (schedule-event-relative 0 'move-attention  ;;;mjs   
                                 :params (list 
                                            eye-mod
                                            :location (current-marker eye-mod)
                                            :scale (last-scale eye-mod))
                                 :output 'medium
                                 :details "Move-attention-attended-loc"
                                 :module :vision)
    ))
|#


