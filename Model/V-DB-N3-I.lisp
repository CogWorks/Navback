;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;v-DB-N3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp V-DB-N3-look-for-directions
 =goal> isa db-task state look-for-directions 
 ?imaginal>  state free 
 ?visual-location> buffer empty
 ==>
 +visual-location> isa visual-location :attended nil screen-y lowest kind text > screen-x 500)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp V-DB-N3-attend-turn-initial
 =goal> isa db-task state look-for-directions
 =contextual> isa mnt init t  
 =visual-location> isa visual-location kind text > screen-x 500 screen-y =y
 ?visual> state free
 =temporal> isa time ticks =ticks
==>
 =contextual> jitter nil
 =visual-location>
 +imaginal> isa turn-list
 =goal> state encode pos =y
 +visual> isa move-attention screen-pos =visual-location)

(spp V-DB-N3-attend-turn-initial :u 10)  ;;initialize each block????

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp V-DB-N3-encode-direction1-initial
 =goal> isa db-task state encode  pos =y
 =contextual> isa mnt  
 =visual> isa text value =dir
 =imaginal> isa turn-list dir1 nil ;;;mod turn-dir dir nil episode =id 
==>
 +visual-location> isa visual-location :attended nil > screen-y =y screen-y lowest kind text > screen-x 500
 =imaginal> dir1 =dir
 !output! (curr-dir =dir)
 =goal> state encode2)

(defp V-DB-N3-encode-direction1a
  =goal> isa db-task state encode2 
  =visual-location> isa visual-location kind text > screen-x 500 screen-y =y
 ?visual> state free
  
==>
 =goal> state encode2a pos =y
 +visual> isa move-attention screen-pos =visual-location
) 

(defp V-DB-N3-encode-direction2
 =goal> isa db-task state encode2a pos =y
 =visual> isa text value =dir 
 =imaginal> isa turn-list dir1 =dir1 dir2 nil
==>
 ;!eval! (print-visicon)
 =imaginal> dir2 =dir
 !output! (next =dir)
 =goal> state encode3
 +visual-location> isa visual-location :attended nil > screen-y =y  screen-y highest   > screen-x 500 kind text
 )

(defp V-DB-N3-encode-direction2a
  =goal> isa db-task state encode3
  =visual-location> isa visual-location kind text > screen-x 500 
 ?visual> state free 
==>
 ;!eval! (print-visicon)
 =goal> state encode3a
 =visual-location>
 +visual> isa move-attention screen-pos =visual-location
)

(defp V-DB-N3-encode-direction2a-error
  =goal> isa db-task state encode3
  ?visual-location> state error 
  =contextual> isa mnt
  =imaginal> isa turn-list dir2 =dir2 dir3 nil 
  =temporal> isa time ticks =ticks
==>
  -goal>
 !bind! =dir (nth (random 3) '("left" "right" "forward"))
 =imaginal> dir3 =dir episode =ticks
 -imaginal>
 !output! (last guess  =dir)
 !eval! (setf *current-episode* =ticks)
  !bind! =tm (check-intersection-tm =ticks)
  =contextual> jitter t rehearse =ticks  intersection =tm init nil
  +goal> isa arrow-task state find-arrow
  +goal> isa rehearse-task  state initial turn-dirs =imaginal )




(defp V-DB-N3-encode-direction3-error
 =goal> isa db-task state encode3a
 =contextual> isa mnt
 =imaginal> isa turn-list dir2 =dir2 dir3 nil 
 =temporal> isa time ticks =ticks
 ?visual> state error
==>
 -goal>
 -visual-location>
 !bind! =dir (nth (random 3) '("left" "right" "forward"))
 =imaginal> dir3 =dir episode =ticks
 -imaginal>
 !output! (last guess  =dir)
 !eval! (setf *current-episode* =ticks)
  !bind! =tm (check-intersection-tm =ticks)
  =contextual> jitter t rehearse =ticks  intersection =tm init nil
  +goal> isa arrow-task state find-arrow
  +goal> isa rehearse-task  state initial turn-dirs =imaginal )

(defp V-DB-N3-encode-direction3
 =goal> isa db-task state encode3a
 =contextual> isa mnt
 =visual> isa text value =dir
 =imaginal> isa turn-list dir2 =dir2 dir3 nil 
 =temporal> isa time ticks =ticks
==>
 -goal>
 -visual-location>
 =imaginal> dir3 =dir episode =ticks
 -imaginal>
 !output! (last =dir)
 !eval! (setf *current-episode* =ticks)
  !bind! =tm (check-intersection-tm =ticks)
  !eval! (remove-from-set 'arrow-task)
  =contextual> jitter t rehearse =ticks  intersection =tm init nil
  +goal> isa arrow-task state find-arrow
  +goal> isa rehearse-task  state initial turn-dirs =imaginal )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defp V-DB-N3-attend-turn-not-initial
 =goal> isa db-task state look-for-directions
 =contextual> isa mnt  rehearse nil init nil
 =visual-location> isa visual-location kind text > screen-x 500
 ?visual> state free
==>
  =contextual> jitter nil
 =goal> state encode
 +visual> isa move-attention screen-pos =visual-location)

(defp* V-DB-N3-encode-direction-not-initial
 =goal> isa db-task state encode
 =contextual> isa mnt rehearse nil init nil
 =visual> isa text value =dir
 =imaginal> isa turn-list dir3 nil
 =temporal> isa time ticks =ticks
==>
 -goal>
 !output! (new-direction =dir)
 =imaginal> dir3 =dir episode =ticks
 -imaginal>
 -visual-location>
 !eval! (setf *current-episode* =ticks)
 !bind! =tm (check-intersection-tm =ticks)
  =contextual>  intersection =tm jitter t rehearse =ticks
  !eval! (threaded-goal-reset (get-module goal))
  +goal> isa arrow-task state find-arrow
  +goal> isa rehearse-task  state initial turn-dirs =imaginal)
 
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
 -visual-location>
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
 -visual-location>
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



