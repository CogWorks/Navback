;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;V-A-N3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(push :NAVBACK-R *features*)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defp *rehearse-task-encode2-only
 =goal> isa rehearse-task state encode2
 ;=aural> isa sound
 ?aural> state free
 =retrieval> isa turn-list dir3 nil
 =contextual> isa mnt
==> 
-goal>
-aural>
 =contextual> rehearse nil)


(pdisable-fct '(*turn-complete))

(defp *turn-complete2
 =goal> isa arrow-task state turn-done
 =contextual> isa mnt
 =retrieval> isa turn-list dir2 =dir2 dir3 =dir3
==>
 +imaginal> isa turn-list dir1 =dir2 dir2 =dir3
 =goal> state turn-done2)



(defp *turn-complete2a
 =goal> isa arrow-task state turn-done2
 =contextual> isa mnt
 =imaginal> isa turn-list dir3 nil
 =temporal> isa time ticks =ticks
==>
 -visual-location>
 =imaginal> episode =ticks
 -imaginal>
 -aural>
 =contextual> init nil jitter t rehearse =ticks
 +goal> isa rehearse-task state initial turn-dirs =imaginal
 +goal> isa arrow-task state find-arrow)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defp V-A-N3-attend-direction-one ;;;Fill 1 
 =goal> isa arrow-task  state proc-arrow 
 =contextual> isa mnt rehearse nil init nil
 =visual> isa arrow dir =dir
 ?retrieval> state free
==>
 +imaginal> isa turn-list 
 =goal>   state last
 +retrieval> isa meaning sym =dir)

(spp V-A-N3-attend-direction-one :u 10)


(defp V-A-N3-endcode-arrow-one 
  =goal> isa arrow-task state last
  =contextual> isa mnt rehearse nil init nil
  =retrieval> isa meaning means =dir
  =imaginal> isa turn-list dir3 nil
  =temporal> isa time ticks =ticks
==> 
  !eval! (clear-dir)
  =imaginal> dir3 =dir episode =ticks
 
  +retrieval> isa turn-list dir3 nil
  =goal> state last1
)

(defp V-A-N3-endcode-arrow-one-a-error
  =goal> isa arrow-task state last1
  =contextual> isa mnt rehearse nil init nil
  =imaginal> isa turn-list
  ?retrieval> state error
==>
  +retrieval> isa turn-list dir3 nil)

(defp V-A-N3-endcode-arrow-one-a
  =goal> isa arrow-task state last1
  =contextual> isa mnt rehearse nil init nil
  =imaginal> isa turn-list
  =retrieval> isa turn-list dir1 =dir1 dir2 =dir2
  =temporal> isa time ticks =ticks
==>
  -visual-location>
  =imaginal> dir1 =dir1 dir2 =dir2 episode =ticks
  -imaginal>
  !bind! =tm (check-intersection-tm =ticks)
  !eval! (setf *current-episode* =ticks)
  =contextual>  intersection =tm jitter t rehearse =ticks
  !eval! (threaded-goal-reset (get-module goal))
  +goal> isa arrow-task state find-arrow
  +goal> isa rehearse-task state initial turn-dirs =imaginal )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun chk-dir (n dir)
  (if (not (eql (slot-value (get-interface) n) (read-from-string dir))) (break)))

(defp V-A-N3-attend-direction-initial ;;;Fill 3 
 =goal> isa arrow-task  state proc-arrow 
 =contextual> isa mnt rehearse nil init t
 =visual> isa arrow dir =dir
 =temporal> isa time ticks =ticks
 ?visual> buffer requested
==>
 =contextual> jitter nil
 +retrieval> isa meaning sym =dir
 +imaginal> isa turn-list
 =goal>  state curr-dir )

(spp V-A-N3-attend-direction-initial :u 10)

(defp V-A-N3-endcode-arrow-1 
  =goal> isa arrow-task state curr-dir
  =imaginal> isa turn-list dir1 nil
  =retrieval> isa meaning means =dir
==> 
  !output! (Curr-Dir =dir)
  ;!eval! (chk-dir 'direction1 =dir)
  =imaginal> dir1 =dir
  +visual-location> isa visual-location kind arrow
  =goal> state next
  )


(defp V-A-N3-get-direction-2 ;;; Fill 2 
 =goal> isa arrow-task state next
 =visual-location> isa visual-location kind arrow
 ?visual> state free
==>
 +visual> isa move-attention screen-pos =visual-location)

(defp V-A-N3-attend-direction-2 
 =goal> isa arrow-task state next
 =visual> isa arrow dir =dir
 ?visual> buffer requested
==>
 +retrieval> isa meaning sym =dir
 )

(defp V-A-N3-encode-direction-2 
 =goal> isa arrow-task state next
 =imaginal> isa turn-list dir1 =dir1 dir2 nil
 =retrieval> isa meaning means =dir
==>
 !output! (Next =dir)
 ;!eval! (chk-dir 'direction2 =dir)
 =imaginal> dir2 =dir
 +visual-location> isa visual-location kind arrow
 =goal> state last)
 
(defp V-A-N3-get-direction-3 ;;; Fill 3
 =goal> isa arrow-task state last
 =contextual> isa mnt init t
 =visual-location> isa visual-location kind arrow
 ?visual> state free
==>
 +visual> isa move-attention screen-pos =visual-location) 
  

(defp V-A-N3-attend-direction-3 
 =goal> isa arrow-task state last
 =contextual> isa mnt init t
 =visual> isa arrow dir =dir
 ?visual> state free
==>
 +retrieval> isa meaning sym =dir
 =goal> state encode-last
 ) 

(defp V-A-N3-Missed-3
 =goal> isa arrow-task state last
 =contextual> isa mnt init t
 =visual> isa arrow dir nil
==>
 !bind! =dir (get-random-dir)
 +retrieval> isa meaning sym =dir
 )

(defp V-A-N3-endcode-direction-3 
  =goal> isa arrow-task state encode-last
  =imaginal> isa turn-list dir2 =dir2 dir3 nil
  =retrieval> isa meaning means =dir
  =temporal> isa time ticks =ticks
  =contextual> isa mnt init t
==> 
  !output! (Last =dir)
  ;!eval!  !eval! (chk-dir 'direction3 =dir)
  =imaginal> dir3 =dir episode =ticks
  -imaginal>
  -visual-location>
  !eval! (setf *current-episode* =ticks)
  !bind! =tm (check-intersection-tm =ticks)
  =contextual> jitter t rehearse =ticks  intersection =tm
  +goal> isa arrow-task state find-arrow
  +goal> isa rehearse-task  state initial turn-dirs =imaginal)
  


