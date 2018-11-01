(in-package :vector-classes)


(declaim (inline getf-one-of-many))
(defun getf-one-of-many (place &rest arguments)
  (iterate
    (for v on place)
    (for p-v previous v)
    (for k initially t then (not k))
    (when (and k
               (member p-v arguments))
      (return (values v t))))
  (values nil nil))


(defun unfold-array (array)
  (make-array (reduce #'* (array-dimensions array))
              :displaced-to array))