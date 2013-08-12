;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;V-DB-N1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp V-DB-N1-look-for-directions-db
 =goal> isa db-task state look-for-directions 
 ?imaginal> buffer empty state free
 ?visual-location> buffer empty
 ?manual> state free
==>
 +visual-location> isa visual-location kind text > screen-x 500)

(defp V-DB-N1-attend-turn
 =goal> isa db-task state look-for-directions
 =visual-location> isa visual-location kind text > screen-x 500
 ?visual> state free 
 =temporal> isa time ticks =ticks
==>
 +imaginal> isa turn-dir
 =goal> state encode
 +visual> isa move-attention screen-pos =visual-location)

(defp V-DB-N1-endcode-direction1a
  =goal> isa db-task state encode
  =contextual> isa mnt
  =visual> isa text value =dir
  =imaginal> isa turn-dir dir nil
  =temporal> isa time ticks =ticks
==>
  -visual-location>
  =imaginal> dir =dir episode =ticks
  -imaginal>
  !bind! =tm (check-intersection-tm =ticks)
  =contextual> intersection =tm jitter t rehearse =ticks
  !eval! (threaded-goal-reset (get-module goal))   ;;;
  +goal> isa arrow-task state find-arrow
  +goal> isa rehearse-task turn-dirs =imaginal state initial)

(spp V-DB-N1-attend-turn :u 10)
(spp V-DB-N1-endcode-direction1a :u 10)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;V-DB;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;don't look for new directions while in intersection
;;;

(pdisable-fct '(*turn-complete))

(defp *turn-complete-in-intersection
 =goal> isa arrow-task state turn-done
 =contextual> isa mnt
 !eval! (turn (get-interface))
 =temporal> isa time ticks =ticks
==>
 -visual-location>
 =contextual> init nil jitter t
 -aural>
 +goal> isa arrow-task state find-arrow
 !bind! =tm (+ =ticks 1)
 +goal> isa db-task state check-intersection  monitor-tm =tm )

(defp *turn-complete-not-in-intersection
 =goal> isa arrow-task state turn-done
 =contextual> isa mnt
 !eval! (null (turn (get-interface))) 
 =temporal> isa time ticks =ticks
==>
 -visual-location>
 =contextual> init nil jitter t
 -aural>
 +goal> isa arrow-task state find-arrow
 !bind! =tm (+ =ticks 1)
 +goal> isa db-task state look-for-directions monitor-tm =tm)

(defp V-DB-check-intersection1 
 =goal> isa db-task state check-intersection 
 =visual-location> isa rec-location kind rec name bottom-right  >= screen-y 330 < screen-y 475  ;;not 
==>
 -visual-location>
 =goal> state look-for-directions)

(spp V-DB-check-intersection1  :u 10)

(defp V-DB-check-intersection2 
 =goal> isa db-task state check-intersection <= monitor-tm =tm
 =temporal> isa time ticks =tm
 =visual-location> isa rec-location kind rec name bottom-right
==>
 +visual-location> isa rec-location kind rec name bottom-right
 !bind! =tm1 (+ =tm 1)
 =goal> monitor-tm =tm1  )

(defp V-DB-check-intersection3 
 =goal> isa db-task state check-intersection <= monitor-tm =tm
 =temporal> isa time ticks =tm
 ?visual-location> buffer empty
==>
 ;!eval! (print-visicon)
 +visual-location> isa rec-location kind rec name bottom-right
 !bind! =tm1 (+ =tm 1)
 =goal> monitor-tm =tm1  )






  
