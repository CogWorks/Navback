(defp *find-arrow
 =goal> isa arrow-task  state find-arrow
 =contextual> isa mnt jitter t
 ?manual> state free
==>
 =goal> state attend-arrow
 +visual-location> isa visual-location kind arrow)

(defp *attend-arrow
 =goal> isa arrow-task state attend-arrow 
 =visual-location> isa visual-location kind arrow screen-x =x  
 ?visual> state free
 ?visual-location> buffer requested
==>
; !output! (attend arrow = =x )
 =goal> state proc-arrow
 +visual> isa move-attention screen-pos =visual-location)

(defp *attend-arrow-error
 =goal> isa arrow-task state attend-arrow    
 ?visual> state error 
==>
 +visual> isa clear
 -visual-location>
 =goal> state find-arrow
)

(defp *jitter-left
 =goal> isa arrow-task state proc-arrow 
 =visual> isa arrow < value 465 value =x
 ?manual> state free
==>
; !output! (proc-arrow = =x left)
 +manual> isa press-key key "d"
 =goal> state find-arrow
)

(defp *jitter-right
 =goal> isa arrow-task state proc-arrow 
 =visual> isa arrow > value 465 value =x
 ?manual> state free
==>
 ;!output! (proc-arrow = =x right)
 +manual> isa press-key key "a"
=goal> state find-arrow
)

(defp *jitter-middle
 =goal> isa arrow-task state proc-arrow
 =visual> isa arrow = value 465 value =x
 ?manual> state free
==>
;!output! (proc-arrow = =x middle)
=goal> state find-arrow
)
