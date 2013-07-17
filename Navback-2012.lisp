
;(eeg:initialize "1.0.0.4")
;(eeg:begin-record)

(in-package :cl-user)

(defclass exp-cnd () 
  ((num-blocks :accessor num-blocks )
   (model? :initform nil :accessor model? )))
(defclass within-subj-cnd (exp-cnd) ((num-blocks :initform 11)))
(defclass between-subj-cnd (exp-cnd) ((num-blocks :initform 1)))
(defparameter +exp-cnd+ (make-instance 'between-subj-cnd))  ;within-subject condition

(defparameter *run-time* 300)        ;set to 1200 for 20 minutes
(defparameter *prac-run-time* 120)    ;set to 120 for 2 minutes for practice block    
(defparameter *modality* 1)          ;1 = Unimodal;    2 = Multimodal;     3 = Persistent Unimodal
(defparameter *dirtype* 1)           ;1 = dir box  2 = in arrow
(defparameter *nback* (if (evenp (random 1000)) 1 2)) ;1  1-back  2 = 3-back
(defparameter *condition* 1)         ;1 = Unimodal;    2 = Multimodal;     3 = Persistent Unimodal

(defparameter *count-start* 5)    ;Countdown for speed change
#|
(defparameter *fast* .1)
(defparameter *medium* .3)
(defparameter *slow* .3)
|#                                     

(defparameter *perc-correct-turns* 0)

(defparameter *tot-dirs-list* nil)
(defparameter *tot-users-turns* nil)
(defparameter *total-perc-correct-turns* 0)

(defparameter *deviation-score* 0)
(defparameter *jitter-score* 0)
(defparameter *total-deviation-score* 0)
(defparameter *tot-total-devs* 0)
(defparameter *tot-list-arrow-jitter* nil)

(defparameter *tm* nil)
(defparameter *block* 1)

(defparameter *turn-hand* 0)
(defparameter *turn-left* "#\j")
(defparameter *turn-right* "#\l")
(defparameter *jitter-left* "#\a")
(defparameter *jitter-right* "#\d")

(defparameter *turn-left-cap* "#\J")
(defparameter *turn-right-cap* "#\L")
(defparameter *jitter-left-cap* "#\A")
(defparameter *jitter-right-cap* "#\D")

(defmacro while (test &rest body)
  `(do ()
       ((not ,test))
     ,@body)
)
;;;
;;;      Start function and interface closure  
;;; 
(let ((interface)
      (load-path (current-pathname)))

(defun drive ()  (drive1 +exp-cnd+))

(defmethod drive1 :around ((cnd exp-cnd)) 
    (let ((obj 
           (cond ((or (eql *condition* 1) (eql *condition* 3))
                  (make-instance 'drive-interface1))
                 ((eql *condition* 2)
                  (make-instance 'drive-interface2)))))
      (setq interface obj)
      (capi:display obj)
      (sleep 1) 
      (setf (turn-time interface) 0)
      (setf (on-screen interface) 0)
      ;(setf (drive-speed interface) 1)
      (log-headers)
      (call-next-method)
      (start-drive obj)
      ;  (eeg:event-notify 1 :label "Block-Start") 
      ))

(defmethod drive1 ((cnd between-subj-cnd))
  (cond ((zerop *block*)
         (setf *tm* (+ *prac-run-time* (get-universal-time))))
        (t
         (setf *tm* (+ *run-time* (get-universal-time))))))
  
(defmethod drive1 ((cnd within-subj-cnd))
  (cond ((zerop *block*)
         (capi:display-message "Memory load is ~A" (if (eql *nback* 1) "1-Back" "3-Back"))
         (setf *tm* (+ *prac-run-time* (get-universal-time))))
        ((= *block* 1)
         (setf *nback* (if (eql *nback* 1) 2 1))
         (setf *tm* (+ *prac-run-time* (get-universal-time))))
        ((> *block* 1)
         (setf *nback* (if (eql *nback* 1) 2 1))
         (setf *tm* (+ *run-time* (get-universal-time)))))
  (log-info `(navback within-subj block ,*block* nback ,*nback*)))

(defun get-interface ()
  interface)

(defun get-load-path ()
  load-path)
) ;;end of let
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;       
;;;
;;; Class definitions
;;;
(defclass drive-object ()
  ((parent :accessor parent :initarg :parent)
   (name :accessor name :initarg :name)
   (id :accessor id :initform nil :initarg :id))
)

(defclass screen-rec (drive-object) () )
(defclass screen-arrow (drive-object) 
  ((freq :initform nil :accessor freq)
   (dir :initform nil :accessor dir))
)

(defclass drive-display-pane (capi:display-pane)
  ((text-ids :initform nil :accessor text-ids))
)


;;;;;;;;;;;;;INTERFACES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Interface1: unimodal and persistent unimodal
;;Interface2: multimodal

(capi:define-interface drive-interface1 ()
  ((arrow :initform (gp:read-external-image (merge-pathnames "mnt/arrow-green.bmp" (get-load-path)) :transparent-color-index 42) :accessor arrow)
   (arrow-color :initform 'green :accessor arrow-color)
   (arrow-rhalf :initform (gp:read-external-image (merge-pathnames "mnt/arrow-green-rhalf.bmp" (get-load-path))) :accessor arrow-rhalf)
   (arrow-lhalf :initform (gp:read-external-image (merge-pathnames "mnt/arrow-green-lhalf.bmp" (get-load-path))) :accessor arrow-lhalf)
   (arrow-rhoriz :initform (gp:read-external-image (merge-pathnames "mnt/arrow-green-rhoriz.bmp" (get-load-path))) :accessor arrow-rhoriz)
   (arrow-lhoriz :initform (gp:read-external-image (merge-pathnames "mnt/arrow-green-lhoriz.bmp" (get-load-path))) :accessor arrow-lhoriz)
   (proc :initform nil :accessor proc)
   (arrow-jitter :initform 465 :accessor arrow-jitter)
   (arrow-x :initform 465 :accessor arrow-x)
   (arrow-y :initform 450 :accessor arrow-y)
   (sqwidth :initform nil :accessor sqwidth)
   (topsqheight :initform nil :accessor topsqheight)
   (botsqheight :initform nil :accessor botsqheight)
   (topsqy :initform nil :accessor topsqy)
   (botsqy :initform nil :accessor botsqy)
   (top-dash :initform nil :accessor top-dash)
   (bot-dash :initform nil :accessor bot-dash)
   (new :initform 0 :accessor new)
   (arrow-obj :initform (make-instance 'screen-arrow :name 'arrow) :accessor arrow-obj)
   (rec-tl-obj :initform (make-instance 'screen-rec :name 'top-left) :accessor rec-tl-obj)
   (rec-tr-obj :initform (make-instance 'screen-rec :name 'top-right) :accessor rec-tr-obj)
   (rec-bl-obj :initform (make-instance 'screen-rec :name 'bottom-left) :accessor rec-bl-obj)
   (rec-br-obj :initform (make-instance 'screen-rec :name 'bottom-right) :accessor rec-br-obj)
   (turn :initform nil :accessor turn)
   (dirs-list :initform nil :accessor dirs-list)
   (users-turns :initform nil :accessor users-turns)
   (loc-users-turns :initform nil :accessor loc-users-turns)
   (loc-dirs-list :initform nil :accessor loc-dirs-list)
   (loc-perc-correct-turns :initform 0 :accessor loc-perc-correct-turns)
   (list-arrow-jitter :initform nil :accessor list-arrow-jitter)
   (total-devs :initform 0 :accessor total-devs)
   (loc-list-arrow-jitter :initform nil :accessor loc-list-arrow-jitter)
   (loc-total-devs :initform 0 :accessor loc-total-devs)
   (loc-deviation-score :initform 0 :accessor loc-deviation-score)
   (turn-count :initform 1 :accessor turn-count)
   (direction1 :initform nil :accessor direction1)
   (direction2 :initform nil :accessor direction2)
   (direction3 :initform nil :accessor direction3)
   (dir-step :initform nil :accessor dir-step)
   (current-step :initform nil :accessor current-step)
   (counting :initform 0 :accessor counting)
   (drive-speed :initform nil :accessor drive-speed)
   (curent-correct-dir :initform nil :accessor current-correct-dir)
   (speed-cond :initform 1 :accessor speed-cond)
   (on-screen :initform nil :accessor on-screen)
   (turn-time :initform nil :accessor turn-time)
   (time-until-dir :initform nil :accessor time-until-dir)
   (current-dev :initform nil :accessor current-dev)
   )
  
  (:panes
   (start capi:push-button
          :accessor start
          :text "Start"
          :callback 'start-drive
         
          :callback-type :interface)
   (stop capi:push-button
         :accessor stop
         :text "Quit"
         :callback 'quit-drive
        
         :callback-type :interface)
   (deviation-score drive-display-pane
                    :title "Deviation Score: "
                    :accessor deviation-score
                    :visible-min-width 100
                    :visible-min-height '(:character 1))
   (correct-turns drive-display-pane
                  :title "Correct Turn: "
                  :accessor correct-turns
                  :visible-min-width 100
                  :visible-min-height '(:character 1))
   (place-holder drive-display-pane
                 :accessor place-holder
                 :visible-min-width 1
                 :visible-min-height 1
                 :background :white)
   (visual-directions drive-display-pane
                      :title "Direction to Turn: "
                      :accessor visual-directions
                      :visible-min-width 100
                      :visible-min-height 50
                      :x 800)
   (road capi:output-pane
         :accessor road
         :display-callback 'draw-background
         :visible-min-width 1000
         :visible-max-width 1000
         :visible-min-height 500
         :visible-max-height 500
         :foreground :darkgreen
         :background :white
          :input-model '(((#\j) key-press-j)
                        ((#\J) key-press-j)
                        ((#\l) key-press-l)
                        ((#\L) key-press-l)
                        ((#\a) key-press-a)
                        ((#\A) key-press-a)
                        ((#\d) key-press-d)
                        ((#\D) key-press-d)
                        ((#\v) escape-drive)
                        )
                        
         ))
  (:layouts
   (button-layout capi:column-layout '(start stop))
   (score-panels capi:row-layout '(correct-turns))
   (top-row capi:row-layout '(;button-layout
                              score-panels                    
                              (visual-directions)):gap 800)      
   (main-layout capi:column-layout '(top-row road)))
  (:default-initargs
   :layout 'main-layout
 ;  :destroy-callback (lambda(interface) (mp:process-kill (proc interface)))
   :x 130
   :y 100
   :title "Simple Navigation Task")
)



(capi:define-interface drive-interface2 ()
  ((arrow :initform (gp:read-external-image (merge-pathnames "mnt/arrow.bmp" (get-load-path)) :transparent-color-index 42) :accessor arrow)
   (arrow-rhalf :initform (gp:read-external-image (merge-pathnames "mnt/arrow-rhalf.bmp" (get-load-path)) :transparent-color-index 42) :accessor arrow-rhalf)
   (arrow-lhalf :initform (gp:read-external-image (merge-pathnames "mnt/arrow-lhalf.bmp" (get-load-path)) :transparent-color-index 42) :accessor arrow-lhalf)
   (arrow-rhoriz :initform (gp:read-external-image (merge-pathnames "mnt/arrow-rhoriz.bmp" (get-load-path)) :transparent-color-index 42) :accessor arrow-rhoriz)
   (arrow-lhoriz :initform (gp:read-external-image (merge-pathnames "mnt/arrow-lhoriz.bmp" (get-load-path)) :transparent-color-index 42) :accessor arrow-lhoriz)
   (proc :initform nil :accessor proc)
   (arrow-jitter :initform 465 :accessor arrow-jitter)
   (arrow-x :initform 465 :accessor arrow-x)
   (arrow-y :initform 450 :accessor arrow-y)
   (sqwidth :initform nil :accessor sqwidth)
   (topsqheight :initform nil :accessor topsqheight)
   (botsqheight :initform nil :accessor botsqheight)
   (topsqy :initform nil :accessor topsqy)
   (botsqy :initform nil :accessor botsqy)
   (top-dash :initform nil :accessor top-dash)
   (bot-dash :initform nil :accessor bot-dash)
   (new :initform 0 :accessor new)
   (arrow-obj :initform (make-instance 'screen-arrow :name 'arrow) :accessor arrow-obj)
   (rec-tl-obj :initform (make-instance 'screen-rec :name 'top-left) :accessor rec-tl-obj)
   (rec-tr-obj :initform (make-instance 'screen-rec :name 'top-right) :accessor rec-tr-obj)
   (rec-bl-obj :initform (make-instance 'screen-rec :name 'bottom-left) :accessor rec-bl-obj)
   (rec-br-obj :initform (make-instance 'screen-rec :name 'bottom-right) :accessor rec-br-obj)
   (turn :initform nil :accessor turn)
   (dirs-list :initform nil :accessor dirs-list)
   (users-turns :initform nil :accessor users-turns)
   (loc-users-turns :initform nil :accessor loc-users-turns)
   (loc-dirs-list :initform nil :accessor loc-dirs-list)
   (loc-perc-correct-turns :initform 0 :accessor loc-perc-correct-turns)
   (list-arrow-jitter :initform nil :accessor list-arrow-jitter)
   (total-devs :initform 0 :accessor total-devs)
   (loc-list-arrow-jitter :initform nil :accessor loc-list-arrow-jitter)
   (loc-total-devs :initform 0 :accessor loc-total-devs)
   (loc-deviation-score :initform 0 :accessor loc-deviation-score)
   (turn-count :initform 1 :accessor turn-count)
   (direction1 :initform nil :accessor direction1)
   (direction2 :initform nil :accessor direction2)
   (direction3 :initform nil :accessor direction3)
   (dir-step :initform nil :accessor dir-step)
   (current-step :initform nil :accessor current-step)
   (counting :initform 0 :accessor counting)
   (drive-speed :initform nil :accessor drive-speed)
   (curent-correct-dir :initform nil :accessor current-correct-dir)
   (speed-cond :initform 1 :accessor speed-cond)
   (on-screen :initform nil :accessor on-screen)
   (turn-time :initform nil :accessor turn-time)
   (time-until-dir :initform nil :accessor time-until-dir)
   (current-dev :initform nil :accessor current-dev)
  
   )
  
  (:panes
   (start capi:push-button
          :accessor start
          :text "Start"
          :callback 'start-drive
          :callback-type :interface)
   (stop capi:push-button
         :accessor stop
         :text "Quit"
         :callback 'quit-drive
         :callback-type :interface)
   (deviation-score drive-display-pane
                    :title "Deviation Score: "
                    :accessor deviation-score
                    :visible-min-width 100
                    :visible-min-height '(:character 1))
   (correct-turns drive-display-pane
                  :title "Correct Turn: "
                  :accessor correct-turns
                  :visible-min-width 150
                  :visible-min-height '(:character 1))
   (place-holder drive-display-pane
                 :accessor place-holder
                 :visible-min-width 1
                 :visible-min-height 1
                 :background :white)
   (visual-directions drive-display-pane
                      :title "Direction to Turn: "
                      :accessor visual-directions
                      :visible-min-width 100
                      :visible-min-height 50)
   (road capi:output-pane
         :accessor road
         :display-callback 'draw-background
         :visible-min-width 1000
         :visible-max-width 1000
         :visible-min-height 500
         :visible-max-height 500
         :foreground :darkgreen
         :background :white
          :input-model '(((#\j) key-press-j)
                        ((#\J) key-press-j)
                        ((#\l) key-press-l)
                        ((#\L) key-press-l)
                        ((#\a) key-press-a)
                        ((#\A) key-press-a)
                        ((#\d) key-press-d)
                        ((#\D) key-press-d))
         ))
  (:layouts
   (button-layout capi:column-layout '(start stop))
   (score-panels capi:row-layout '(correct-turns) :gap 350)
   (top-row capi:row-layout '(;button-layout
                              score-panels))                 
   (main-layout capi:column-layout '(top-row road)))
  (:default-initargs
   :layout 'main-layout
  ; :destroy-callback (lambda(interface) (mp:process-kill (proc interface)))
   :x 130
   :y 200
   :title "Simple Navigation Task")
)




;;;;;;;;;;LOGGING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun log-headers ()
  (log-info (list "SNT-EVENT" "SNT-STEP-HEADER" 
                  "Time"
                  "Top Left Rectangle X1" "Top Left Rectangle Y1" "Top Left Rectangle X2" "Top Left Rectangle Y2"
                  "Top Right Rectangle X1" "Top Right Rectangle Y1" "Top Rght Rectangle X2" "Top Right Rectangle Y2"
                  "Bottom Left Rectangle X1" "Bottom Left Rectangle Y1" "Bottom Left Rectangle X2" "Bottom Left Rectangle Y2"
                  "Bottom Right Rectangle X1" "Bottom Right Rectangle Y1" "Bottom Right Rectangle X2" "Bottom Left Rectangle Y2"
                  "Vertical Dashed Line X1" "Vertical Dashed Line Y1" "Vertical Dashed Line X2" "Vertical Dashed Line Y2"
                  "Bottom Dashed Line X1" "Bottom Dashed Line Y1" "Bottom Dashed Line X2" "Bottom Dashed Line Y2"
                  "Top Dashed Line X1" "Top Dashed Line Y1" "Top Dashed Line X2" "Top Dashed Line Y2"
                  "Arrow X" "Arrow Y" "Jitter Speed" "Drive Speed"))
  (log-info (list "SNT-EVENT" "SNT-STEP-HEADER-SPSS"
                  "TIME"
                  "TLR-X1" "TLR-Y1" "TLR-X2" "TLR-Y2" 
                  "TRR-X1" "TRR-Y1" "TRR-X2" "TRR-Y2"
                  "BLR-X1" "BLR-Y1" "BLR-X2" "BLR-Y2"
                  "BRR-X1" "BRR-Y1" "BRR-X2" "BRR-Y2"
                  "VDL-X1" "VDL-Y1" "VDL-X2" "VDL-Y2"
                  "BDL-X1" "BDL-Y1" "BDL-X2" "BDL-Y2"
                  "TDL-X1" "TDL-Y1" "TDL-X2" "TDL-Y2"
                  "ARROW-X" "ARROW-Y"))

  (log-info (list "SNT-EVENT" "SNT-ACTION-HEADER"
                  "Time"
                  "Turn" "Jitter Correction"))
  (log-info (list "SNT-EVENT" "SNT-ACTION-HEADER-SPSS"
                  "TIME"
                  "TURN" "JITT-CORR"))

  (log-info (list "SNT-EVENT" "SNT-DISPLAY-HEADER"
                  "Time"
                  "Local Deviation" "Local Percentage Correct Turns" "Direction"))
  (log-info (list "SNT-EVENT" "SNT-DISPLAY-HEADER-SPSS"
                  "TIME"
                  "LOC-DEV" "LOC-TURN-PERC" "DIR"))

  (log-info (list "SNT-EVENT" "SNT-SUMMARY-HEADER"
                  "Time"
                  "Condition" "Block"
                  "Deviation" "Total Deviation" "Percentage Correct Turns" "Total Percentage Correct Turns"))
  (log-info (list "SNT-EVENT" "SNT-SUMMARY-HEADER-SPSS"
                  "TIME"
                  "COND" "BLOCK"
                  "DEV" "TOTAL-DEV" "TURN-PERC" "TOTAL-TURN-PERC"))
)

(defun log-step (interface)
  (setf (time-until-dir interface) (- (dir-step interface) (current-step interface)))
  (setf (current-dev interface) (abs (- (arrow-jitter interface) 465)))
#|
  (if (or  
       ;(eql (current-step interface) 25)
       ;(eql (current-step interface) 30)
       (eql (current-step interface) 35)
       ;(eql (current-step interface) 40)
       ;(eql (current-step interface) 45)
       ;(> (current-step interface) 60)
       )
      (break "~S" (current-step interface))
      )
|#

  (log-info (list "SNT-EVENT" "SNT-STEP"
                  *tm* 
                  *block*
                  (current-dev interface)
                  (current-step interface)
                  (time-until-dir interface)
                  (current-correct-dir interface)
                  ))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun reset-dimensions (interface)
  ;(setf (arrow-jitter interface) 465)
  (setf (sqwidth interface) 420)
  (setf (topsqheight interface) 170)
  (setf (botsqheight interface) 170)
  (setf (botsqy interface) 330)
  (setf (counting interface) (+ (counting interface) 1))
 ; (setf (dirpos interface) (+ 350 (* (random 25) 5)))
  (let (ran)
    (setf ran (random 3))
    (cond ((eql ran 0)
           (setf (dir-step interface) 5))
          ((eql ran 1)
           (setf (dir-step interface) 17))
          ((eql ran 2)
           (setf (dir-step interface) 30)))
    (if (eql (turn-count interface) 1)
        (setf (dir-step interface) 5)))
  (setf (topsqy interface) 0)
  (setf (top-dash interface) -86)
  (setf (bot-dash interface) 249)
  (setf (current-step interface) 0)
  )




(defmethod draw-intersection ((pane capi:output-pane))
  (let ((interface (capi:element-interface pane)))
    (gp:draw-rectangle (road interface) 0 (topsqy interface) (sqwidth interface) (topsqheight interface) :filled t)                             
    (gp:draw-rectangle (road interface) 580 (topsqy interface) (sqwidth interface) (topsqheight interface) :filled t)                           
    (gp:draw-rectangle (road interface) 0 (botsqy interface) (sqwidth interface) (botsqheight interface) :filled t)                           
    (gp:draw-rectangle (road interface) 580 (botsqy interface) (sqwidth interface) (botsqheight interface) :filled t)                       
    (gp:draw-line (road interface) 499 0 501 500 :dashed t)
    (gp:draw-line (road interface) 0 (bot-dash interface) 1000 (+ (bot-dash interface) 2) :dashed t)
    (gp:draw-line (road interface) 0 (top-dash interface) 1000 (+ (top-dash interface) 2) :dashed t)))

(defmethod draw-intersection ((interface capi:interface)) 
  (capi:apply-in-pane-process (road interface) #'draw-intersection (road interface)))

(defmethod draw-background ((pane capi:output-pane) x y width height)
  (declare (ignore x y width height))
  (let ((interface (capi:element-interface pane)))
    (reset-dimensions interface)
    (draw-intersection pane)))

(defun stop-drive (interface)
  (mp:process-kill (proc interface))
  (setf *dirs-list* (dirs-list interface))
  (setf *users-turns* (users-turns interface))
  (setf *deviation-score* (- (float (/ (total-devs interface) (length (list-arrow-jitter interface)))) 465)))

(defmethod start-drive ((interface capi:interface))
  (setf (new interface) 1)
  (setf (counting interface) *count-start*)
  (reset-dimensions interface)
  ;(format t "~%Drive Process Started")
  (setf (proc interface) (mp:process-run-function "Drive Process" '(:priority 100) #'draw-process interface))
   
  (capi:set-pane-focus (road interface)))

(defparameter  *save-results* nil)
(defun quit-drive (interface)
  (capi:execute-with-interface interface 'capi:destroy interface)
  (log-info (list "SNT-EVENT" "SNT-SUMMARY" *tm* *condition* *block* *deviation-score* *total-deviation-score* 
                  *perc-correct-turns* *total-perc-correct-turns*))
  (setf *save-results* (list *deviation-score* *perc-correct-turns* ))
  (scores interface))

(defun scores (interface)      
  (cond ((< *block* (num-blocks +exp-cnd+))
         (give-feedback +exp-cnd+) 
         (mark-and-sweep 3)
         (incf *block*)
         ;(setf (drive-speed interface) 0)    
         (setf *deviation-score* 0)
         (setf *perc-correct-turns* 0)
         (drive)
         )     
        ((eql *block* (num-blocks +exp-cnd+))
         (give-feedback +exp-cnd+)    
         ;(capi:display-message "Your TOTAL Scores~%~%Total Deviation Score: ~A ~%Total Percentage of Correct Turns: ~A" 
         ;                      (round *total-deviation-score*) *total-perc-correct-turns*)
         (cw-task-finished ))))

(defmethod give-feedback ((cnd between-subj-cnd))
  ;(capi:display-message "Your Scores for BLOCK ~A ~%~%Deviation Score: ~A ~%Percentage of Correct Turns: ~A ~%" 
  ;                             *block* (round *deviation-score*) *perc-correct-turns*)
  )

(defmethod give-feedback ((cnd within-subj-cnd)) 
;  (capi:display-message "Your Scores for BLOCK ~A ~%~%Deviation Score: ~A ~%Percentage of Correct Turns: ~A ~%~%Next is ~A Memory Load" 
;                               *block* (round *deviation-score*) *perc-correct-turns* (if (eql *nback* 1) "1-Back" "3-Back"))
  )



(defun draw-process (interface)
    (sleep .2)
    (place-arrow (arrow interface) (arrow-jitter interface) 450 interface)
    (draw-intersection interface)
     ; loop experiment re-drawing process until block time runs out
    (while (< (get-universal-time) *tm*)
      (sleep .2)
      (move-intersection interface)
      (place-arrow (arrow interface) (arrow-jitter interface) 450 interface)
      (jitter interface))     
    (quit-drive interface))

(defmethod place-arrow (image x y (interface capi:interface))
  (if (and interface (road interface)
           (capi:interface-visible-p (road interface)))
      (capi:execute-with-interface
       interface
       #'(lambda ()
           (let ((new-image (gp:convert-external-image (road interface) image)))
             (setf (arrow-x interface) x)
             (setf (arrow-y interface) y)
             (capi:apply-in-pane-process (road interface) (lambda() (log-info `(draw-arrow ,x)) (gp:draw-image (road interface) new-image x y)))
             )))))

(defun move-intersection (interface)  
    (capi:apply-in-pane-process (road interface) 'gp:clear-rectangle (road interface) 0 0 1000 500)
    ;; random time for direction presentation
    (incf (current-step interface))
   
    (log-step interface)
    (when (eql (current-step interface) (dir-step interface))            ;;displays directions  
          (display-directions interface)
          (setf (on-screen interface) 1)
          ;(if (< (drive-speed interface) 1)
          ;    (setf (turn-time interface) (+ (current-step interface) 5))
          (setf (turn-time interface) (+ (current-step interface) 5))
          )
  
    (when (and (> (on-screen interface) 0) (> (current-step interface) (turn-time interface)))
      (setf (on-screen interface) 0)
      (setf (turn-time interface) 0)
      ;;displays directions for short amount of time       
      (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green.bmp" (get-load-path))))
      ;(format +actr-output+ "~%Clearing Direction")
      (setf (dir (arrow-obj interface)) nil) ;;;;;mjs model
      (display-drive-directions (format nil " ") (visual-directions interface)))

    (go-forward interface)

    (when (eql (topsqheight interface) 165)
      (push 'forward (users-turns interface))
      (push 'forward *tot-users-turns*)
      (push 'forward (loc-users-turns interface))
      (setf (dir (arrow-obj interface)) nil)                   ;;;;;mjs model
      (log-info (list "SNT-EVENT" "SNT-ACTION" *tm* 3 0))
      (reset-dimensions interface)
      (calc-perc-turns interface)
      )
    )

(defun update-dev-score (interface)
   (push (arrow-jitter interface) (loc-list-arrow-jitter interface))
   (push (arrow-jitter interface) (list-arrow-jitter interface))
   (push (arrow-jitter interface) *tot-list-arrow-jitter*)
   (setf (loc-total-devs interface) (+ (loc-total-devs interface) (abs (- (arrow-jitter interface) 465))))
   (setf (total-devs interface) (+ (total-devs interface) (abs (- (arrow-jitter interface) 465))))
   (setf *tot-total-devs* (+ *tot-total-devs* (abs (- (arrow-jitter interface) 465))))
   (calc-dev-score interface)
)

(defun calc-dev-score (interface)
  (setf (loc-deviation-score interface) (float (/ (loc-total-devs interface) (length (loc-list-arrow-jitter interface)))))
  (setf *deviation-score* (float (/ (total-devs interface) (length (list-arrow-jitter interface)))))
  (setf *total-deviation-score* (float (/ *tot-total-devs* (length *tot-list-arrow-jitter*))))
)

(defun jitter (interface)
  (let ((ran (random 100)) (image (arrow interface)) (dev) (init-jitter-chance) (cont-jitter-chance) (jitter-chance))
    (setf dev (abs (- 465 (arrow-jitter interface))))
    (if (< dev 5) (setf (arrow-jitter interface) 465))
    (setf dev (abs (- 465 (arrow-jitter interface))))
    (setf init-jitter-chance 25)
    (setf cont-jitter-chance (- 50 dev))
    (if (> dev 0) 
        (setf jitter-chance cont-jitter-chance)
      (setf jitter-chance init-jitter-chance))
    (cond ((eql (arrow-jitter interface) 465)
           (cond ((or (eql ran 0) (and (> ran 0) (< ran 25))) ;25% chance will jitter to the left
                  (setf (arrow-jitter interface) (- (arrow-jitter interface) 5))
                  (place-arrow image (arrow-jitter interface) 450 interface))
                 ((or (eql ran 75) (and (> ran 75) (< ran 100))) ;25% chance will jitter to the right
                  (setf (arrow-jitter interface) (+ (arrow-jitter interface) 5)))))
           ;once deviates to either right or left, 33% chance that it will deviate further
           ((and (< (arrow-jitter interface) 465) (> (arrow-jitter interface) 420)) 
            (cond ((or (eql ran 0) (and (> ran 0) (< ran jitter-chance))) 
                   (setf (arrow-jitter interface) (- (arrow-jitter interface) 5)))
                 ))
           ((and (> (arrow-jitter interface) 465) (< (arrow-jitter interface) 505))
            (cond ((or (eql ran 0) (and (> ran 0) (< ran jitter-chance)))
                   (setf (arrow-jitter interface) (+ (arrow-jitter interface) 5))))))
    (setf dev (abs (- (arrow-jitter interface) 465)))
    (place-arrow image (arrow-jitter interface) 450 interface)
    (update-dev-score interface)))

(defun jitter-l (pane x y g)
  (declare (ignore x y g))
  (let* ((interface (capi:element-interface pane)) (image (arrow interface)))   
    (if (eql (turn interface) nil)
        (progn 
          (log-info (list "SNT-EVENT" "SNT-ACTION" *tm*  0 1))   
          (cond ((not (> (arrow-jitter interface) 505))
                 (setf (arrow-jitter interface) (+ (arrow-jitter interface) 5))
                 (place-arrow image (arrow-jitter interface) 450 interface)))))))

(defun jitter-r (pane x y g)
  (declare (ignore x y g))
  (let* ((interface (capi:element-interface pane)) (image (arrow interface)))
    (if (eql (turn interface) nil)
        (progn
          (log-info (list "SNT-EVENT" "SNT-ACTION" *tm* 0 2))
          (cond ((not (< (arrow-jitter interface) 420))
                 (setf (arrow-jitter interface) (- (arrow-jitter interface) 5))
                 (place-arrow image (arrow-jitter interface) 450 interface)))))))

(defun calc-perc-turns (interface)
  (let ((count 0)
        (tot-count 0)
        (loc-count 0)
        (len (length (users-turns interface)))
        (tot-len (length *tot-users-turns*))
        (loc-len (length (loc-users-turns interface)))
        (temp-dirs-list (reverse (dirs-list interface)))
        (temp-users-turns (reverse (users-turns interface)))
        (temp-tot-dirs-list (reverse *tot-dirs-list*))
        (temp-tot-users-turns (reverse *tot-users-turns*))
        (temp-loc-dirs-list (reverse (loc-dirs-list interface)))
        (temp-loc-users-turns (reverse (loc-users-turns interface))))
  
    (if (eql len (length (dirs-list interface)))
        (dotimes (i len)
          (if (eql (nth i temp-users-turns) (nth i temp-dirs-list))
              (incf count)))
      (progn (pop (dirs-list interface))
        (dotimes (i len)
          (if (eql (nth i temp-users-turns) (nth i temp-dirs-list))
              (incf count)))))

    (if (eql tot-len (length *tot-dirs-list*))
        (dotimes (i tot-len)
          (if (eql (nth i temp-tot-users-turns) (nth i temp-tot-dirs-list))
              (incf tot-count)))
      (progn (pop *tot-dirs-list*)
        (dotimes (i tot-len)
          (if (eql (nth i temp-tot-users-turns) (nth i temp-tot-dirs-list))
              (incf tot-count)))))

    (if (eql loc-len (length (loc-dirs-list interface)))
        (dotimes (i loc-len)
          (if (eql (nth i temp-loc-users-turns) (nth i temp-loc-dirs-list))
              (incf loc-count)))
      (progn (pop (loc-dirs-list interface))
        (dotimes (i loc-len)
          (if (eql (nth i temp-loc-users-turns) (nth i temp-loc-dirs-list))
              (incf loc-count)))))

    (setf *perc-correct-turns* (round (float (* (/ count len) 100))))
    (setf *total-perc-correct-turns* (round (float (* (/ tot-count tot-len) 100))))
    (setf (loc-perc-correct-turns interface) (round (float (* (/ loc-count loc-len) 100))))
    (format +actr-output+ "~%TURNS ~S ~S ~S ~S" tot-count tot-len loc-count loc-len)

    (if (or (eql *condition* 1) (eql *condition* 2) (eql *condition* 3))
        (update-displays interface))))

(defmethod update-displays ((interface capi:interface))
  (let ((temp (if (eql (loc-perc-correct-turns interface) 100) 'yes 'no)))
   (capi:apply-in-pane-process (deviation-score interface) #'(setf capi:display-pane-text) 
                               (format nil "~S" (round (loc-deviation-score interface))) (deviation-score interface))
   (capi:apply-in-pane-process (correct-turns interface) #'(setf capi:display-pane-text) (format nil "~S" temp) (correct-turns interface))
   (log-info (list "SNT-EVENT" "SNT-DISPLAY" *tm* (loc-deviation-score interface) (loc-perc-correct-turns interface) 0))
   (setf (loc-list-arrow-jitter interface) nil)
   (setf (loc-total-devs interface) 0)
   (setf (loc-deviation-score interface) 0)
   (setf (loc-users-turns interface) nil)
   (setf (loc-dirs-list interface) nil)
   (setf (loc-perc-correct-turns interface) 0)
   ))

(defun update-arrow (interface)
  (cond ((and (< (arrow-jitter interface) 465) (< (bot-dash interface) 450) (eql (turn interface) 2))
         (setf (arrow-jitter interface) (+ 465 (- 450 (bot-dash interface))))) ;left of, below center; turn r
         ((and (< (arrow-jitter interface) 465) (> (bot-dash interface) 450) (eql (turn interface) 2))
          (setf (arrow-jitter interface) (- 465 (- (bot-dash interface) 450)))) ;left of, above center; turn l
         ((and (< (arrow-jitter interface) 465) (< (bot-dash interface) 450) (eql (turn interface) 1))
          (setf (arrow-jitter interface) (- 465 (- 450 (bot-dash interface))))) ;left of, below center; turn l
         ((and (< (arrow-jitter interface) 465) (> (bot-dash interface) 450) (eql (turn interface) 1))
          (setf (arrow-jitter interface) (+ 465 (- (bot-dash interface) 450)))) ;left of, above center; turn r

         ((and (> (arrow-jitter interface) 465) (< (bot-dash interface) 450) (eql (turn interface) 2))
          (setf (arrow-jitter interface) (+ 465 (- 450 (bot-dash interface))))) ;right of, below center; turn r
         ((and (> (arrow-jitter interface) 465) (> (bot-dash interface) 450) (eql (turn interface) 2))
          (setf (arrow-jitter interface) (- 465 (- (bot-dash interface) 450)))) ;right of, above center; turn r
         ((and (> (arrow-jitter interface) 465) (< (bot-dash interface) 450) (eql (turn interface) 1))
          (setf (arrow-jitter interface) (- 465 (- 450 (bot-dash interface))))) ;right of, below center; turn l
         ((and (> (arrow-jitter interface) 465) (> (bot-dash interface) 450) (eql (turn interface) 1))
          (setf (arrow-jitter interface) (+ 465 (- (bot-dash interface) 450)))) ;right of, above center; turn l
         ))

(defun turn-process (pane interface)
    (let ((image-lhalf (arrow-lhalf interface)) (image-lhoriz (arrow-lhoriz interface))
          (image-rhalf (arrow-rhalf interface)) (image-rhoriz (arrow-rhoriz interface))
          (arrow-pos (arrow-jitter interface)) (image (arrow interface)))
      (while (turn interface)
             (setf (dir (arrow-obj interface)) nil) ;;;;;mjs model
             (stop-drive interface)
             (cond ((eql (turn interface) 1)
                    (place-arrow image-lhalf (- arrow-pos 15) 425 interface)
                    (sleep .75)
                    (place-arrow image-lhoriz arrow-pos 425 interface)
                    (sleep .75)
                    (push 'left (users-turns interface))
                    (push 'left *tot-users-turns*)
                    (push 'left (loc-users-turns interface))
                    (log-info (list "SNT-EVENT" "SNT-ACTION" *tm* 1 0))
                    (calc-perc-turns interface)
                    (update-arrow interface)
                    (setf (turn interface) nil))
                   ((eql (turn interface) 2)
                    (place-arrow image-rhalf (- arrow-pos 5) 425 interface)
                    (sleep .75)
                    (place-arrow image-rhoriz arrow-pos 425 interface)
                    (sleep .75)
                    (push 'right (users-turns interface))
                    (push 'right *tot-users-turns*)
                    (push 'right (loc-users-turns interface))
                    (log-info (list "SNT-EVENT" "SNT-ACTION" *tm* 2 0))
                    (calc-perc-turns interface)
                    (update-arrow interface)
                    (setf (turn interface) nil)))
(setf (arrow-jitter interface) 465)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  ??????
              (place-arrow image (arrow-jitter interface) 450 interface)
             (start-drive interface)
             )))

(defun turn-left (pane x y g)
  (declare (ignore x y g))
  (let ((interface (capi:element-interface pane)))
    (if (eql (turn interface) nil)
        (cond ((or (> (botsqy interface) 450)
                   (and (> (botsqy interface) 130) (< (botsqy interface) 285)))
               (setf (turn interface) 1)
               (mp:process-run-function "Turn Process" '(:priority 100) #'turn-process pane interface))))))  ;;;:priority 100

(defun key-press-j (pane x y g)
  (cond ((> *turn-hand* 0)
         (jitter-r pane x y g))
        ((< *turn-hand* 1)
         (turn-left pane x y g))))

(defun key-press-l (pane x y g) 
  (cond ((> *turn-hand* 0)
         (jitter-l pane x y g))
        ((< *turn-hand* 1)
         (turn-right pane x y g))))

(defun key-press-a (pane x y g)
  (cond ((> *turn-hand* 0)
         (turn-left pane x y g))
        ((< *turn-hand* 1)
         (jitter-r pane x y g))))

(defun key-press-d (pane x y g)
  (cond ((> *turn-hand* 0)
         (turn-right pane x y g))
        ((< *turn-hand* 1)
         (jitter-l pane x y g))))
        
(defun escape-drive (pane x y g)
  (capi:apply-in-pane-process pane 'capi:quit-interface pane))

(defun turn-right (pane x y g)
  (declare (ignore x y g)) 
  (let ((interface (capi:element-interface pane)))
    (if (eql (turn interface) nil)
        (cond ((or (> (botsqy interface) 450)
                   (and (> (botsqy interface) 130) (< (botsqy interface) 285)))
               (setf (turn interface) 2)
               (mp:process-run-function "Turn Process" '(:priority 100) #'turn-process pane interface)))))) ;;

(defun go-forward (interface)
  (cond ((and (eql (topsqheight interface) 170) (< (topsqy interface) 175))
         (enter-intersection interface))
        ((eql (topsqy interface) 175) 
         (leave-intersection interface))
        ((< (topsqheight interface) 170)
         (in-intersection interface)))
 ; (format +actr-output+ "~% ~S ~S ~S " (bot-dash interface) (botsqy interface) (or (> (botsqy interface) 450)
 ;                  (and (> (botsqy interface) 130) (< (botsqy interface) 285))))
)

(defun update-dash (interface)
  (cond ((and (eql (topsqheight interface) 170) (eql (topsqy interface) 0))
         (setf (bot-dash interface) (+ 5 (top-dash interface)))
         (setf (top-dash interface) -86))
        ((eql (bot-dash interface) 500)
         (setf (bot-dash interface) 130)
         (setf (top-dash interface) (+ (top-dash interface) 5)))
        (t
         (setf (bot-dash interface) (+ (bot-dash interface) 5))
         (setf (top-dash interface) (+ (top-dash interface) 5)))))

(defun enter-intersection (interface)
  (setf (botsqheight interface) (- (botsqheight interface) 5))
  (setf (topsqy interface) (+ (topsqy interface) 5))
  (setf (botsqy interface) (+ (botsqy interface) 5))
  (update-dash interface)
  (draw-intersection interface))

(defun leave-intersection (interface)
  (setf (botsqy interface) (topsqy interface))
  (setf (topsqy interface) 0)
  (setf (topsqheight interface) 0)
  (setf (botsqheight interface) 170)
  (update-dash interface)
  (draw-intersection interface))

(defun in-intersection (interface)
  (setf (botsqy interface) (+ (botsqy interface) 5))
  (setf (topsqheight interface) (+ (topsqheight interface) 5))
  (update-dash interface)
  (draw-intersection interface))

(defun get-directions ()
  (let ((rannumb (random 99)))
    (cond ((and (or (eql rannumb 0) (> rannumb 0)) (< rannumb 33))
           'forward)
          ((and (or (eql rannumb 33) (> rannumb 33)) (< rannumb 66))
           'left)
          ((and (or (eql rannumb 66) (> rannumb 66)) (< rannumb 99))
           'right))))

(defmethod display-drive-directions (str (pane drive-display-pane) )
  (capi:apply-in-pane-process pane #'(setf capi:display-pane-text) str pane))

(defmethod display-initial-dirs ((interface capi:interface))
  (let ((pane (visual-directions interface)) )
    (setf (direction1 interface) (get-directions))
    (setf (direction2 interface) (get-directions))
    (setf (direction3 interface) (get-directions))
    (setf (turn-count interface) 0)
    (cond ((and (eql *modality* 1) (eql *nback* 2) (eql *dirtype* 2))
           (cond ((eql (direction1 interface) 'right)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-R.bmp" (get-load-path)))))
                 ((eql (direction1 interface) 'left)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-L.bmp" (get-load-path)))))
                 ((eql (direction1 interface) 'forward)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-F.bmp" (get-load-path))))))
           (setf (dir (arrow-obj interface)) (direction1 interface))
;(format +actr-output+ "~%New-Directions1 ~S" (direction1 interface))
           (place-arrow (arrow interface) (arrow-jitter interface) 450 interface)
           (draw-intersection interface)
           (sleep .5)
           (cond ((eql (direction2 interface) 'right)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-R.bmp" (get-load-path)))))
                 ((eql (direction2 interface) 'left)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-L.bmp" (get-load-path)))))
                 ((eql (direction2 interface) 'forward)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-F.bmp" (get-load-path))))))
           (setf (dir (arrow-obj interface)) (direction2 interface))
;(format +actr-output+ "~%New-Directions2 ~S" (direction2 interface))
           (place-arrow (arrow interface) (arrow-jitter interface) 450 interface)
           (sleep .5 )
           (cond ((eql (direction3 interface) 'right)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-R.bmp" (get-load-path)))))
                 ((eql (direction3 interface) 'left)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-L.bmp" (get-load-path)))))
                 ((eql (direction3 interface) 'forward)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-F.bmp" (get-load-path))))))
           (setf (dir (arrow-obj interface)) (direction3 interface))
;(format +actr-output+ "~%New-Directions3 ~S" (direction3 interface))
           (place-arrow (arrow interface) (arrow-jitter interface) 450 interface))
          ((and (eql *modality* 1) (eql *nback* 2) (eql *dirtype* 1))
;(format +actr-output+ "~S~%~S~%~S" (direction1 interface) (direction2 interface) (direction3 interface))
           (display-drive-directions (format nil "~S~%~S~%~S" (direction1 interface) (direction2 interface) (direction3 interface)) pane))
          ((and (eql *modality* 1) (eql *nback* 1) (eql *dirtype* 2))
           (cond ((eql (direction1 interface) 'right)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-R.bmp" (get-load-path)))))
                 ((eql (direction1 interface) 'left)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-L.bmp" (get-load-path)))))
                 ((eql (direction1 interface) 'forward)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-F.bmp" (get-load-path))))))
           (setf (dir (arrow-obj interface)) (direction1 interface))
 ;(format +actr-output+ "~%New-Directions ~S" (direction1 interface))
           (place-arrow (arrow interface) (arrow-jitter interface) 450 interface)
           (draw-intersection interface)
           (sleep .5))
          ((and (eql *modality* 1) (eql *nback* 1) (eql *dirtype* 1))
(format +actr-output+ "~%New-Directions ~S" (direction1 interface))
           (display-drive-directions (format nil "~S" (direction1 interface)) pane))
          ((and (eql *modality* 2) (eql *nback* 2))
           (mp:process-run-function "Auditory" '() #'cw-speak (format nil "~S" (direction1 interface)) )
 ;(format +actr-output+ "~%New-Directions1 ~S" (direction1 interface))
           (sleep .5)
           (mp:process-run-function "Auditory" '() #'cw-speak (format nil "~S" (direction2 interface)) )
 ;(format +actr-output+ "~%New-Directions2 ~S" (direction2 interface))
           (sleep .5)
           (mp:process-run-function "Auditory" '() #'cw-speak (format nil "~S" (direction3 interface)) )
 ;(format +actr-output+ "~%New-Directions3 ~S" (direction1 interface))
           )
          ((and (eql *modality* 2) (eql *nback* 1))
           (mp:process-run-function "Auditory" '() #'cw-speak (format nil "~S" (direction1 interface)) )
 ;(format +actr-output+ "~%New-Directions1 ~S" (direction1 interface))
           )   )
    (push (direction1 interface) (dirs-list interface))
    (push (direction1 interface) *tot-dirs-list*)
    (push (direction1 interface) (loc-dirs-list interface))       
    (log-info (list "SNT-EVENT" "SNT-DISPLAY" *tm* 0 0 (direction1 interface) (direction2 interface) (direction3 interface)))
  ))

(defmethod display-one-dir ((interface capi:interface))
  (let ((pane (visual-directions interface)) (dir-to-present nil))
    (setf (direction1 interface) (direction2 interface))
    (setf (direction2 interface) (direction3 interface))
    (setf (direction3 interface) (get-directions))
    (setf (current-correct-dir interface) (direction1 interface))   
    ; set dir-to-present based on n-back condition
    (if (eql *nback* 1)
        (setf dir-to-present (direction1 interface))
      (setf dir-to-present (direction3 interface)))
    ; set arrow image and direction
    (cond ((and (eql *modality* 1) (eql *dirtype* 1))
(format +actr-output+ "~%New-Directions ~S" dir-to-present )
           (display-drive-directions (format nil "~S" dir-to-present) pane))
          ((and (eql *modality* 1) (eql *dirtype* 2))
           (cond ((eql dir-to-present 'right)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-R.bmp" (get-load-path)))))
                 ((eql dir-to-present 'left)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-L.bmp" (get-load-path)))))
                 ((eql dir-to-present 'forward)
                  (setf (arrow interface) (gp:read-external-image (merge-pathnames "mnt/arrow-green-F.bmp" (get-load-path))))))
            (setf (dir (arrow-obj interface)) dir-to-present )
;(format +actr-output+ "~%New-Directions ~S" dir-to-present )
            )
          ((eql *modality* 2)
           (mp:process-run-function "Auditory" '() #'cw-speak (format nil "~S" dir-to-present))
;(format +actr-output+ "~%New-Directions ~S" dir-to-present )
           ))   
    (push (direction1 interface) (dirs-list interface))
    (push (direction1 interface) *tot-dirs-list*)
    (push (direction1 interface) (loc-dirs-list interface))     
    (log-info (list "SNT-EVENT" "SNT-DISPLAY" *tm* 0 0 (direction1 interface) (direction2 interface) (direction3 interface)))
  ))
        
(defmethod display-directions ((interface capi:interface))
  ;(capi:beep-pane)
  (let ((pane (visual-directions interface)) )
    (cond ((eql (turn-count interface) 0)
           (display-one-dir interface))
          ((eql (turn-count interface) 1)
           (display-initial-dirs interface)
           (setf (turn-count interface) 0))
          )))

(defmethod set-exp-parameters (condition (cnd between-subj-cnd))
  (cond ((equal condition "V-DB-N1")
           (setf *condition* 1)
           (setf *modality* 1)
           (setf *nback* 1)
           (setf *dirtype* 1))
          ((equal condition "V-DB-N3")
           (setf *condition* 1)
           (setf *modality* 1)
           (setf *nback* 2)
           (setf *dirtype* 1))
          ((equal condition "V-A-N1")
           (setf *condition* 1)
           (setf *modality* 1)
           (setf *nback* 1)
           (setf *dirtype* 2))
          ((equal condition "V-A-N3")
           (setf *condition* 1)
           (setf *modality* 1)
           (setf *nback* 2)
           (setf *dirtype* 2))
          ((equal condition "A-N1")
           (setf *condition* 2)
           (setf *modality* 2)
           (setf *nback* 1)
           (setf *dirtype* 1))
          ((equal condition "A-N3")
           (setf *condition* 2)
           (setf *modality* 2)
           (setf *nback* 2)
           (setf *dirtype* 1))))

(defmethod set-exp-parameters (condition (cnd within-subj-cnd))
  (cond ((equal condition "Direction Box")
           (setf *condition* 1)
           (setf *modality* 1)
           (setf *dirtype* 1))
          ((equal condition "Arrow")
           (setf *condition* 1)
           (setf *modality* 1)
           (setf *dirtype* 2))
          ((equal condition "Auditory")
           (setf *condition* 2)
           (setf *modality* 2)
           (setf *dirtype* 1))))

;;;;;;;;;CogWorld registration;;;;;;;;;;;;;;;
#+:cogworld
(let ((cw-task-object (register-task "Navback2" :run-function 'drive :configure-function 'display-config-win)))

 (defun display-config-win () (display-config-win1 +exp-cnd+))

 (defmethod  display-config-win1 ((cnd within-subj-cnd))
  (let ((condition (capi:prompt-with-list (list "Direction Box" "Arrow" "Auditory") "Please choose a condition: ")))
    (set-exp-parameters condition cnd)
    (configuration-done cw-task-object :condition condition)
    ))

 (defmethod display-config-win1 ((cnd between-subj-cnd))
  (let ((condition (capi:prompt-with-list (list "Visual-DB-Easy" "Visual-DB-Hard" "Visual-Arrow-Easy" "Visual-Arrow-Hard" "Auditory-Easy" "Auditory-Hard") 
                   "Please choose a condition: ")))
    (set-exp-parameters condition cnd)
    (configuration-done cw-task-object :condition condition)
    ))

(defun cw-task-finished () (task-finished cw-task-object))
)

(defun reset-model-turns ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;#+:act-r-6.0
;(load (current-pathname "Model/navback-model.lisp"))


           

   
                      

        






