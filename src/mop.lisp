(in-package :vector-classes)


(eval-always
  (defclass data-slot-definition (c2mop:standard-slot-definition)
    ((%dimensions-arg :initarg :dimensions-arg
                      :reader read-dimensions-arg)
     (%dimensions-form :initarg :dimensions-form
                       :reader read-dimensions-form
                       :initform nil)
     (%array :initarg :array
             :reader read-array
             :type boolean
             :initform nil))))


(eval-always
  (defclass direct-data-slot-definition (data-slot-definition
                                         c2mop:standard-direct-slot-definition)
    ()))


(eval-always
  (defmethod initialize-instance :after ((instance direct-data-slot-definition) &rest args)
    (declare (ignore args))
    (when (read-array instance)
      (setf #1=(c2mop:slot-definition-type instance)
            `(simple-array ,#1#)))))


(eval-always
  (defclass effective-data-slot-definition (data-slot-definition
                                            c2mop:standard-effective-slot-definition)
    ()))


(eval-always
  (defclass data-class (closer-mop:standard-class)
    ()))


(eval-always
  (defmethod c2mop:validate-superclass ((class data-class)
                                        (super c2mop:standard-class))
    t))


(eval-always
  (defmethod c2mop:direct-slot-definition-class ((class data-class)
                                                 &rest initargs)
    (declare (ignore initargs))
    (find-class 'direct-data-slot-definition)))


(eval-always
  (defmethod c2mop:effective-slot-definition-class ((class data-class)
                                                    &rest initargs)
    (declare (ignore initargs))
    (find-class 'effective-data-slot-definition)))


(eval-always
  (defun forward-added-slots (effective-slot direct-slot)
    (setf (slot-value effective-slot '%array) (slot-value direct-slot '%array)
          (slot-value effective-slot '%dimensions-form)
          (slot-value direct-slot '%dimensions-form))
    effective-slot))


(eval-always
  (defun direct-slot-definitions-compatible-p (direct-slot-definitions)
    (let ((all-array (mapcar #'read-array direct-slot-definitions))
          (all-allocation (mapcar #'c2mop:slot-definition-allocation direct-slot-definitions)))
      (and (every (curry #'eql (first all-array))
                  (rest all-array))
           (every (lambda (array allocation)
                    (or (not array)
                        (eq allocation :instance)))
                  all-array
                  all-allocation)))))


(eval-always
  (defmethod c2mop:compute-effective-slot-definition
      ((class data-class) name direct-slot-definitions)
    (declare (ignore name))
    (unless (direct-slot-definitions-compatible-p direct-slot-definitions)
      (error "Slot definitions are incompatible."))
    (lret ((result (call-next-method)))
      (forward-added-slots result (car direct-slot-definitions))
      (setf (slot-value result '%dimensions-arg)
            (iterate
              (for slot in direct-slot-definitions)
              (when (slot-boundp slot '%dimensions-arg)
                (collecting (read-dimensions-arg slot))))))))
