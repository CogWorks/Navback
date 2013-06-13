(defp *rehearse-task-encode2-only
 =goal> isa rehearse-task state encode2
 =aural> isa sound
 ?aural> state free
 =retrieval> isa turn-list dir3 nil
==> 
-goal>
 =contextual> rehearse nil)
)

(pdisable-fct '(*turn-complete))

(defp *turn-complete2
 =goal> isa arrow-task state turn-done
 =contextual> isa mnt
 =retrieval> isa turn-list dir2 =dir2 dir3 =dir3
==>
 =contextual> init nil jitter t
 -aural>
 +imaginal> isa turn-list dir1 =dir2 dir2 =dir3
 =goal> state turn-done2)

(defp *turn-complete2a
 =goal> isa arrow-task state turn-done
 =contextual> isa mnt
 =imaginal> isa turn-list dir3 nil
 =temporal> isa time ticks =ticks
==>
 =contextual> init nil jitter t rehearse =ticks
 +goal> isa rehearse-task state initial turn-dirs =imaginal
 +goal> isa arrow-task state find-arrow)

