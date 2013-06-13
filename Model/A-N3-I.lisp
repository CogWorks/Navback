;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;A-N3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp A-N3-listen-for-directions-not-initial
 =contextual> isa mnt jitter t init nil
 =aural-location> isa audio-event kind word location external
 ?aural> state free
==>
 +aural> isa sound event =aural-location
)

(defp* A-N3-attend-to-directions-not-initial
  =contextual> isa mnt jitter t rehearse nil init nil
  =aural> isa sound kind word content =str  
  =imaginal> isa turn-list dir3 nil 
  =temporal> isa time ticks =ticks
==>
  !output! (New Last =str)
  =imaginal> dir3 =str episode =ticks
  -imaginal>
  !bind! =tm (+ =ticks 2)
  =contextual> intersection =tm rehearse =ticks
  +goal> isa rehearse-task state initial turn-dirs =imaginal) 


(spp A-N3-listen-for-directions-not-initial :u 10)

(spp A-N3-attend-to-directions-not-initial :u 10)
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defp A-N3-listen-for-directions-initial 
 =contextual> isa mnt jitter t rehearse nil init t
 =aural-location> isa audio-event kind word location external
 ?aural> state free
 ?imaginal> buffer empty state free
 =temporal> isa time ticks =ticks
==>
 +imaginal> isa turn-list 
 +aural> isa sound event =aural-location
 
)
(spp A-N3-listen-for-directions-initial :u 10) 

(defp A-N3-attend-to-directions
 =contextual> isa mnt jitter t  rehearse nil init t
 =aural-location> isa audio-event kind word 
 ?aural> state free buffer empty
==>
 +aural> isa sound event =aural-location
)

(defp A-N3-attend-to-directions-1
 =contextual> isa mnt jitter t  rehearse nil init t
 =aural> isa sound kind word content =str
 =imaginal> isa turn-list dir1 nil
==>
 !output! (Curr-Dir =str)
 =imaginal> dir1 =str 
 +aural-location> isa audio-event :attended nil location external
 )

(defp A-N3-attend-to-directions-2
 =contextual> isa mnt jitter t rehearse nil init t
 =aural> isa sound kind word content =str
 =imaginal> isa turn-list dir1 =dir dir2 nil
 ?aural> state free
==>
 !output! (Next =str)
 =imaginal> dir2 =str
 +aural-location> isa audio-event :attended nil location external
 )

(defp A-N3-attend-to-directions-3
 =contextual> isa mnt jitter t rehearse nil init t
 =aural> isa sound kind word content =str
 =imaginal> isa turn-list dir2 =dir dir3 nil
 =temporal> isa time ticks =ticks
 ?aural> state free
==>
 !output! (Last =str)
 =imaginal> dir3 =str episode =ticks
 -imaginal>
 !bind! =tm (+ =ticks 2)
  =contextual> intersection =tm rehearse =ticks
  +goal> isa rehearse-task  state initial turn-dirs =imaginal
)
