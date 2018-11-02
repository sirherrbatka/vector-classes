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
              :displaced-to array
              :element-type (array-element-type array)))


(eval-always
  (defun slot-of-name (class slot-name)
    (check-type class cl:class)
    (let ((slots (c2mop:class-slots class)))
      (find slot-name slots :key #'c2mop:slot-definition-name))))
