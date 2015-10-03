(begin
  (define defrule-52
    '(defrule 52
       if
       (site culture is blood)
       (gram organism is neg)
       (morphology organism is rod)
       (burn patient is serious)n
       then .4
       (identity organism is pseudonomas)))

  (define true          +1.0)
  (define false         -1.0)
  (define unknown 0.0)
  (define cf-or
    (lambda (a b)
      "Combine the certainty factors fo rthe formula (A or B).
       This is used when two rules support the same conclusion."
      (cond ((and (> a 0) (> b 0))
             (+ a b (* -1 a b)))
            ((and (< a 0) (< b 0))
             (+ a b (* a b)))
            (#t (/ (+ a b)
                   (- 1 (min (abs a) (abs b))))))))
  (define cf-and
    (lambda  (a b)
      "Combine the certanty factors for the formula (A and B)."
      (min a b)))
  
  ;; below this certainty we cut off search.
  (define cf-cut-off 0.2)

      
  (define true-p
    ;; is this certainty factor considered true?
    (lambda (cf)
      (and
       (cf-p cf)
       (> cf cf-cut-off))))

  (define false-p
    ;; is this certainty factor considered false?
    (lambda (cf)
      (and
       (cf-p cf)
       (< cf (- cf-cut-off 1.0)))))

  (define cf-p
    ;; is x a valid numeric certainty factor?
    (lambda (x)
      (and
       (numberp x)
       (<= false x true))))


  (cf-and 1 1)
  (cf-or 0 0))
