;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;V-A-N1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp V-A-N1-attend-turn-direction  
 =goal> isa arrow-task state proc-arrow       
 =visual> isa arrow dir =dir
 =temporal> isa time ticks =ticks
 ?retrieval> state free
==>
 +retrieval> isa meaning sym =dir
 +imaginal> isa turn-dir  episode =ticks
 =goal> state proc-dir)


(defp V-A-N1-endcode-arrow 
  =goal> isa arrow-task  state proc-dir
  =contextual> isa mnt
  =imaginal> isa turn-dir dir nil episode =id
  =retrieval> isa meaning means =dir
  =temporal> isa time ticks =ticks
==> 
  !output! (Directions =dir)
  =imaginal> dir =dir 
  -imaginal>
  !bind! =tm (+ =ticks 2)
  =contextual> intersection =tm jitter t rehearse =id
  +goal> isa arrow-task state find-arrow 
  +goal> isa rehearse-task turn-dirs =imaginal state initial)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;