;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;V-DB;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;don't look for new directions while in intersection
;;;

(pdisable-fct '(*turn-complete))

(defp *turn-complete-in-intersection
 =goal> isa arrow-task state turn-done
 =contextual> isa mnt
 =retrieval> isa turn-list dir2 =dir2 dir3 =dir3
 !eval! (turn (get-interface))
 =temporal> isa time ticks =ticks
==>
 =contextual> init nil jitter t
 -aural>
 +imaginal> isa turn-list dir1 =dir2 dir2 =dir3
 +goal> isa arrow-task state find-arrow
 !bind! =tm (+ =ticks 1)
 +goal> isa db-task state check-intersection  monitor-tm =tm )

(defp *turn-complete-not-in-intersection
 =goal> isa arrow-task state turn-done
 =contextual> isa mnt
 =retrieval> isa turn-list dir2 =dir2 dir3 =dir3
 !eval! (null (turn (get-interface))) 
 =temporal> isa time ticks =ticks
==>
 =contextual> init nil jitter t
 -aural>
 +imaginal> isa turn-list dir1 =dir2 dir2 =dir3
 +goal> isa arrow-task state find-arrow
 !bind! =tm (+ =ticks 1)
 +goal> isa db-task state look-for-directions monitor-tm =tm)


(defp V-DB-check-intersection1 
 =goal> isa db-task state check-intersection 
 =visual-location> isa rec-location kind rec name bottom-right  >= screen-y 330 < screen-y 475  ;;not 
==>
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



