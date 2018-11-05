(in-package :vector-classes)


(declaim (notinline getf-one-of-many))
(defun getf-one-of-many (place &rest arguments)
  (iterate
    (for v on (rest place))
    (for p-v previous v
         initially place)
    (for k initially t then (not k))
    (when (and k (member (first p-v) arguments))
      (leave (values (first v) t)))
    (finally (return (values nil nil)))))


(defun unfold-array (array)
  (make-array (reduce #'* (array-dimensions array))
              :displaced-to array
              :element-type (array-element-type array)))


(eval-always
  (defun slot-of-name (class slot-name)
    (check-type class cl:class)
    (let ((slots (c2mop:class-slots class)))
      (or (find slot-name slots :key #'c2mop:slot-definition-name)
          (error "Slot ~a not found in the class." slot-name)))))
