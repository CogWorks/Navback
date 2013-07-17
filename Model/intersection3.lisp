(defp *find-intersection
 =goal> isa arrow-task state attend-arrow
 =contextual> isa mnt  intersection =ticks1
                   <=  intersection =ticks
 =temporal> isa time ticks =ticks 
 ?visual> state free
  =visual-location> isa visual-location kind arrow screen-x =x  screen-y =y
==>
 =goal> state calc-pos   
 +visual-location> isa rec-location name bottom-right )

(spp *find-intersection :u 10)

(defp *not-in-intersection?
  =goal> isa arrow-task  state calc-pos
  =contextual> isa mnt
  =visual-location> isa rec-location kind rec name bottom-right  >= screen-y 330 < screen-y 475
 ?retrieval> state free
  =temporal> isa time ticks =ticks
==>
 -visual-location>
 !bind! =tm (check-intersection-tm =ticks)
 =goal> state find-arrow
 =contextual> intersection =tm
 )

(spp *not-in-intersection? :u 10)

(defparameter rerror 0)
(defparameter rtotal 0)

(defp *in-intersection
  =goal> isa arrow-task state calc-pos
  =contextual> isa mnt ;;;rehearse =id
   =visual-location> isa rec-location kind rec name bottom-right  
  ?retrieval> state free
==>
 -visual-location>
 -aural>
 !eval! (incf rtotal)
 +retrieval> isa turn-list 
 =goal> state recall-dir 
 =contextual> intersection nil rehearse nil 
 )

(defp *intersection-error1
 =goal> isa arrow-task state recall-dir
 =contextual> isa mnt
 ?manual> state free
; ?retrieval> state error
 =retrieval> isa turn-list dir2 =dir2 dir3 nil
==>
 !eval! (incf *retrieve-error*)
 !eval! (format +actr-output+ "~%Wrong retrieval")
 !bind! =dir (nth (random 3) '("left" "right" "forward"))   ;;;guess
 =retrieval> dir3 =dir
 =goal> state =dir
 =contextual> intersection nil rehearse nil
 )

(spp *intersection-error1 :u 10)

(defp *intersection-error2
 =goal> isa arrow-task state recall-dir
 =contextual> isa mnt
 ?manual> state free
 ?retrieval> state error
==>
 !eval! (format +actr-output+ "~%Retrieval Error")
 +retrieval> isa turn-list 
 =goal> state recall-dir 
 !eval! (incf *retrieve-error*)
 )


(defp do-turn
 =goal> isa arrow-task state recall-dir
 =temporal> isa time ticks =ticks
 =retrieval> isa turn-list dir1 =turndir episode =e
 ?manual> state free
==>
!bind! =x *current-direction*
 !output! (Turn-retrieval =ticks =e =turndir =x )
 =retrieval>
 =goal> state  =turndir )
 

(defp *turn-right
 =goal> isa arrow-task state "right"
 =contextual> isa mnt
 ?manual> state free
==>
 =goal> state maybe-check-feedback 
 !output! (Turning Right)
 +manual> isa press-key key "l"
 =contextual> jitter nil)

(defp *turn-left
 =goal> isa arrow-task state "left" 
 =contextual> isa mnt
 ?manual> state free
==>
 =goal> state maybe-check-feedback 
 !output! (Turning Left)
 +manual> isa press-key key "j"
 =contextual> jitter nil)

(defp *turn-forward
 =goal> isa arrow-task state "forward"
 =contextual> isa mnt
 ?manual> state free
==>
 !output! (Turning Forward)
 =goal> state maybe-check-feedback-forward
 )

(defp *dont-check-feedback-forward
 =goal> isa arrow-task state maybe-check-feedback-forward
 =contextual> isa mnt
 ?manual> state free
==>
 
 =goal> state turn-done)

(defp *dont-check-feedback
 =goal> isa arrow-task state maybe-check-feedback
 ?manual> state free
 ;!eval! (null (turn (get-interface)))
==>
 +visual-location> isa arrow-location kind arrow 
 ;!eval! (print-visicon)
 =goal> state turning)

(defp *turning
 =goal> isa arrow-task state turning
 
 =visual-location> isa arrow-location value turning
==>
 +visual-location> isa arrow-location
 =goal> state maybe-check-feedback)

(defp *turning1
 =goal> isa arrow-task state turning
 
 =visual-location> isa arrow-location 
 !eval! (turn (get-interface))
==>
 +visual-location> isa arrow-location
 =goal> state maybe-check-feedback)

(spp *turning :u 10)

(defp *turn-done
 =goal> isa arrow-task state turning
 =contextual> isa mnt
 !eval! (null (turn (get-interface)))
==>
 =goal> state turn-done)

(defp *turn-complete
 =goal> isa arrow-task state turn-done
 =contextual> isa mnt
 =retrieval> isa turn-list dir2 =dir2 dir3 =dir3
==>
 -visual-location>
 =contextual> init nil jitter t
 -aural>
 +imaginal> isa turn-list dir1 =dir2 dir2 =dir3
 =goal> state find-arrow)
 

 
#|
(defp *check-feedback
  =goal> isa mnt 
         state maybe-check-feedback
  ?manual> state free
  !eval! (null (turn (get-interface)))
==>
  !eval! (print-visicon)
  +visual-location> isa visual-location kind text < screen-x 100
  =goal> state check-feedback)

(defp *check-feedback1
  =goal> isa mnt  state check-feedback     
  =visual-location> isa visual-location kind text < screen-x 100 color =col value =val
  ?visual> state free
==>
 !output! (Feedback =val =col)
 +visual> isa move-attention screen-pos =visual-location
 =goal> state attend-feedback)

(defp *check-feedback1-error
  =goal> isa mnt  state check-feedback     
  ?visual-location> state error
==>
  +visual-location> isa visual-location kind text < screen-x 100
  =goal> state check-feedback)

(defp *check-feedback2
  =goal> isa mnt  state attend-feedback
  =visual> isa text value "no"
==>
 =goal> rebuild fill1 state turn-complete)

(defp *check-feedback3
  =goal> isa mnt  state attend-feedback
  =visual> isa text value "yes"
==>
  =goal> state turn-complete)
|#
#|
(defp *in-intersection-guess
  =goal> isa mnt
         rebuild =fill
         state calc-pos
  =imaginal> isa spatial-rep arrow-loc =loc

  ?visual-location> state error
  ?retrieval> state free
==>
 +retrieval> isa instruction-list  - dir1 nil :recently-retrieved t
 =imaginal> in? t
 !bind! =dir (nth (random 3) '("left" "right" "forward")) 
 =goal> state =dir
        intersection nil
 )
|#

