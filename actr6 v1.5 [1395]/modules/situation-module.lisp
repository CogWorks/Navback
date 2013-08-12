(defstruct situation-module delay esc busy)

(defun create-situation-module (model-name)
  (declare (ignore model-name))
  (make-situation-module))

(defun reset-situation-module (situation)
  (declare (ignore situation))
  (chunk-type situation-output value))

(defun delete-situation-module (situation)
  (declare (ignore situation)))

(defun situation-module-params (situation param)
  )

(defun situation-module-requests (situation buffer spec)
  (if (eq buffer 'contextual)
     (situation-chunk situation spec)
    (situation-handle-print-out spec)))


(defun situation-handle-print-out (spec)
  (let* ((type (chunk-spec-chunk-type spec))
         (value? (slot-in-chunk-spec-p spec 'value))
         (v1 (when value? (chunk-spec-slot-spec spec 'value))))
     (if (eq type 'situation-output)
         (if value?
             (if (= (length v1) 1)
                 (if (eq (caar v1) '=)
                     (model-output "Value: ~s" (caddar v1))
                   (model-warning "Invalid slot modifier ~s in output buffer request" (caar v1)))
               (model-warning "Value slot specified multiple times in output buffer request"))
           (model-warning "Value slot missing in output buffer request"))
       (model-warning "bad chunk-type in request to output buffer"))))

(defun situation-chunk (situation spec)
   (if (situation-module-busy situation)
      (model-warning "Cannot handle request when busy")
     (let* ((chunk-def (chunk-spec-to-chunk-def spec))
            (chunk (when chunk-def
                    (car (define-chunks-fct (list chunk-def))))))
        (when chunk
          (let ((delay (if (situation-module-esc situation) 
                           (situation-module-delay situation)
                         0)))
            (setf (situation-module-busy situation) t)
            (schedule-set-buffer-chunk 'contextual  chunk 0 :module 'situation)
            (schedule-event-relative delay 'free-situation-module :params (list situation) :module 'situation))))))

(defun free-situation-module (situation)
  (setf (situation-module-busy situation) nil))


(defun situation-module-queries (situation buffer query value)
  (declare (ignore buffer))
  (case query
    (state
     (case value
       (busy (situation-module-busy situation))
       (free (not (situation-module-busy situation)))
       (error nil)
       (t (print-warning "Bad state query to the ~s buffer" buffer))))
    (t (print-warning "Invalid query ~s to the ~s buffer" query buffer))))





(define-module-fct 'situation
                   '(contextual) 
  nil ;;no-paramters

   :request 'situation-module-requests
   :query 'situation-module-queries

   :version "1.0a1"
   :documentation "A module to provide context for multitask communication"
   :creation 'create-situation-module
   :reset 'reset-situation-module 
   :delete 'delete-situation-module
   :params 'situation-module-params
)


#|
(trace demo-module-requests demo-module-queries create-demo-module reset-demo-module delete-demo-module demo-module-params)


; Loading C:\Documents and Settings\Root\Desktop\demo-model.lisp
 0[4]: (CREATE-DEMO-MODULE TEST-DEMO-MODULE)
 0[4]: returned #S(DEMO-MODULE :DELAY NIL :BUSY NIL :ESC NIL)
 0[4]: (RESET-DEMO-MODULE #S(DEMO-MODULE :DELAY NIL :BUSY NIL :ESC NIL))
 0[4]: returned DEMO-OUTPUT
 0[4]: (DEMO-MODULE-PARAMS #S(DEMO-MODULE :DELAY NIL :BUSY NIL :ESC NIL) (:CREATE-DELAY . 0.1))
 0[4]: returned 0.1
 0[4]: (DEMO-MODULE-PARAMS #S(DEMO-MODULE :DELAY 0.1 :BUSY NIL :ESC NIL) (:ESC))
 0[4]: returned NIL
 0[4]: (DEMO-MODULE-PARAMS #S(DEMO-MODULE :DELAY 0.1 :BUSY NIL :ESC NIL) (:ESC . T))
 0[4]: returned T
 0[4]: (DEMO-MODULE-PARAMS #S(DEMO-MODULE :DELAY 0.1 :BUSY NIL :ESC T) (:CREATE-DELAY . 0.15))
 0[4]: returned 0.15

CG-USER(27): (run .25)
     0.000   PROCEDURAL             CONFLICT-RESOLUTION 
 0[4]: (DEMO-MODULE-QUERIES #S(DEMO-MODULE :DELAY 0.15 :ESC T :BUSY NIL) CREATE STATE FREE)
 0[4]: returned T
     0.000   PROCEDURAL             PRODUCTION-SELECTED P1 
     0.000   PROCEDURAL             QUERY-BUFFER-ACTION CREATE 
     0.050   PROCEDURAL             PRODUCTION-FIRED P1 
     0.050   PROCEDURAL             MODULE-REQUEST CREATE 
 0[4]: (DEMO-MODULE-REQUESTS #S(DEMO-MODULE :DELAY 0.15 :ESC T :BUSY NIL) CREATE
                             #S(ACT-R-CHUNK-SPEC :TYPE #S(ACT-R-CHUNK-TYPE :NAME VISUAL-LOCATION
                                                                           :DOCUMENTATION NIL
                                                                           :SUPERTYPES (VISUAL-LOCATION)
                                                                           :SUBTYPES (CHAR-PRIMITIVE VISUAL-LOCATION)
                                                                           :SLOTS (SCREEN-X SCREEN-Y DISTANCE KIND COLOR VALUE HEIGHT WIDTH SIZE)
                                                                           :EXTENDED-SLOTS NIL)
                                                 :SLOTS (#S(ACT-R-SLOT-SPEC :MODIFIER = :NAME SCREEN-X :VALUE 10)
                                                         #S(ACT-R-SLOT-SPEC :MODIFIER = :NAME SCREEN-Y :VALUE 20))))
 0[4]: returned
         #S(ACT-R-EVENT :TIME 0.2
                        :PRIORITY 0
                        :ACTION FREE-DEMO-MODULE
                        :MODEL TEST-DEMO-MODULE
                        :MP DEFAULT
                        :MODULE DEMO
                        :DESTINATION NIL
                        :PARAMS (#S(DEMO-MODULE :DELAY 0.15 :ESC T :BUSY T))
                        :DETAILS NIL
                        :OUTPUT T
                        :WAIT-CONDITION NIL)
     0.050   PROCEDURAL             CLEAR-BUFFER CREATE 
     0.050   PROCEDURAL             CONFLICT-RESOLUTION 
 0[4]: (DEMO-MODULE-QUERIES #S(DEMO-MODULE :DELAY 0.15 :ESC T :BUSY T) CREATE STATE FREE)
 0[4]: returned NIL
     0.200   DEMO                   SET-BUFFER-CHUNK CREATE VISUAL-LOCATION0 
     0.200   DEMO                   FREE-DEMO-MODULE #S(DEMO-MODULE :DELAY 0.15 :ESC T :BUSY T) 
     0.200   PROCEDURAL             CONFLICT-RESOLUTION 
     0.200   PROCEDURAL             PRODUCTION-SELECTED P2 
     0.200   PROCEDURAL             BUFFER-READ-ACTION CREATE 
     0.250   PROCEDURAL             PRODUCTION-FIRED P2 
     0.250   PROCEDURAL             MODULE-REQUEST OUTPUT 
 0[4]: (DEMO-MODULE-REQUESTS #S(DEMO-MODULE :DELAY 0.15 :ESC T :BUSY NIL) OUTPUT
                             #S(ACT-R-CHUNK-SPEC :TYPE #S(ACT-R-CHUNK-TYPE :NAME DEMO-OUTPUT
                                                                           :DOCUMENTATION NIL
                                                                           :SUPERTYPES (DEMO-OUTPUT)
                                                                           :SUBTYPES (DEMO-OUTPUT)
                                                                           :SLOTS (VALUE)
                                                                           :EXTENDED-SLOTS NIL)
                                                 :SLOTS (#S(ACT-R-SLOT-SPEC :MODIFIER = :NAME VALUE :VALUE VISUAL-LOCATION0-0))))
Value: VISUAL-LOCATION0-0
 0[4]: returned NIL
     0.250   PROCEDURAL             CLEAR-BUFFER CREATE 
     0.250   PROCEDURAL             CLEAR-BUFFER OUTPUT 
     0.250   PROCEDURAL             CONFLICT-RESOLUTION 
 0[4]: (DEMO-MODULE-QUERIES #S(DEMO-MODULE :DELAY 0.15 :ESC T :BUSY NIL) CREATE STATE FREE)
 0[4]: returned T
     0.250   PROCEDURAL             PRODUCTION-SELECTED P1 
     0.250   PROCEDURAL             QUERY-BUFFER-ACTION CREATE 
     0.250   ------                 Stopped because time limit reached 
0.25
22
NIL
CG-USER(31): (clear-all)
 0[4]: (DELETE-DEMO-MODULE #S(DEMO-MODULE :DELAY 0.15 :BUSY NIL :ESC T))
 0[4]: returned NIL
NIL

|#