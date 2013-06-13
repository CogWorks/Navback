(defp *rehearse-task
 =goal> isa rehearse-task  state initial turn-dirs =c
 =contextual> isa mnt rehearse =id
 ?retrieval> state free buffer empty

==>
; !eval! (print-audicon)
 !output! (rehearsal sequence =id)
 +retrieval> =c
 )

(defp *rehearse-task-dir1
 =goal> isa rehearse-task state initial
 =retrieval> isa turn-list dir1 =dir
 ?vocal> state free
 ?retrieval> state free
==>
 !output! (Rehearsing curr-dir =dir)
 +vocal> isa subvocalize string =dir
 +retrieval> =retrieval
 =goal> state subvocal1)

(defp *rehearse-subvocal1
  =goal> isa rehearse-task state subvocal1
  ?vocal> state free
==>
  +aural-location> isa audio-event location internal :attended nil
  =goal> state hear1)

(defp *rehearse-task-hear1
 =goal> isa rehearse-task state hear1
 =aural-location> isa audio-event location internal
 ?aural> state free
==>
 +aural> isa sound event =aural-location
 =goal> state encode1)

(defp *rehearse-task-encode1
 =goal> isa rehearse-task state encode1
 =aural> isa sound
 ?aural> state free
 =retrieval> isa turn-list dir2 =dir
==> 
 +retrieval> =retrieval
 +vocal> isa subvocalize string =dir
 =goal> state subvocal2)

(defp *rehearse-task-subvocal2
 =goal> isa rehearse-task state subvocal2
 ?vocal> state free
==>
  +aural-location> isa audio-event location internal :attended nil
  =goal> state hear2)

(defp *rehearse-hear2
 =goal> isa rehearse-task state hear2
 =aural-location> isa audio-event location internal
 ?aural> state free
==>
 +aural> isa sound event =aural-location
 =goal> state encode2) ;;;

(defp *rehearse-task-encode2
 =goal> isa rehearse-task state encode2
 =aural> isa sound
 ?aural> state free
 =retrieval> isa turn-list dir3 =dir
==> 
 +retrieval> =retrieval
 +vocal> isa subvocalize string =dir
 =goal> state subvocal3)

(defp *rehearse-subvocal3
 =goal> isa rehearse-task state say-subvocal3
 ?vocal> state free
==>
  +aural-location> isa audio-event location internal :attended nil
  =goal> state hear3)

(defp *rehearse-hear3
 =goal> isa rehearse-task state hear3
 =aural-location> isa audio-event location internal
 ?aural> state free
==>
 +aural> isa sound event =aural-location
 =goal> state encode3)

(defp *rehearse-task-encode3
 =goal> isa rehearse-task state encode3
 =contextual> isa mnt rehearse =id 
 =aural> isa sound
 ?aural> state free
==> 
 -goal>
 =contextual> rehearse nil)

(defp *rehearse-task-stop
 =goal> isa rehearse-task
 =contextual> isa mnt rehearse nil
==>
 -aural-location>
 -aural>
 -goal>
 )

(spp *rehearse-task-stop :u 10)



#|
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp *restart-tasks
 =goal> isa arrow-task state turn-complete
 =contextual> isa mnt
 =retrieval> isa turn-dir episode =id
==>
 =contextual> jitter t rehearse =id
 +goal> isa arrow-task state find-arrow
 +goal> isa rehearse-task  state switch)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

|#

 

