(defp *rehearse-task
 =goal> isa rehearse-task  state initial turn-dirs =c
 =contextual> isa mnt rehearse =id
 ?retrieval> state free
==>
 !output! (rehearsal sequence =id)
 +retrieval> =c
 =goal> state rehearse1
 )

(defp *rehearse-task-current-one-only
 =goal> isa rehearse-task state rehearse1
 =retrieval> isa turn-dir dir =dir episode =id 
 ?vocal> state free
==>
 !output! (Rehearsing curr-dir =id =dir)
 +vocal> isa subvocalize string =dir
 +aural-location> isa audio-event location internal
 +retrieval> isa turn-dir  episode =id
 =goal> state say-and-listen)

(defp *rehearse-task-listen
 =goal> isa rehearse-task state say-and-listen
 =aural-location> isa audio-event
 ;?aural-location> buffer requested
 ?aural> state free
==>
 +aural> isa sound event =aural-location
 =goal> state encode-sound)

(defp *rehearse-task-encode
 =goal> isa rehearse-task state encode-sound
 =aural> isa sound
 ;?aural> state free
==>
-goal>
 =goal> state initial)

(defp *rehearse-task-stop
 =goal> isa rehearse-task
 =contextual> isa mnt rehearse nil
==>
 -aural-location>
 -aural>
 -goal>
 )

(spp *rehearse-task-stop :u 10)


