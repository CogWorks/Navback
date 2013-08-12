;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;A-N1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defp A-N1-listen-for-directions
 =contextual> isa mnt jitter t 
 =aural-location> isa audio-event kind word 
 ?aural> state free
 ?imaginal> buffer empty state free
 =temporal> isa time ticks =ticks
==>
 +imaginal> isa turn-dir episode =ticks
 +aural> isa sound event =aural-location
)

(defp A-N1-attend-to-directions-audio
 =contextual> isa mnt jitter t rehearse nil intersection nil 
 =aural> isa sound kind word content =str
 =imaginal> isa turn-dir dir nil
 =temporal> isa time ticks =ticks
==>
 !output! (Directions =str)
 =imaginal> dir =str episode =ticks
 -imaginal>
 !bind! =tm (+ =ticks 2)
 =contextual> intersection =tm jitter t rehearse =ticks
 +goal> isa rehearse-task turn-dirs =imaginal state initial)
