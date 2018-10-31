(in-package :vector-classes)

(eval-always
  (defclass data-slot-definition (c2mop:standard-slot-definition)
    ((%count-arg :initarg :count-arg
                 :reader read-count-arg
                 :initform nil)
     (%vector :initarg :vector
              :reader read-vector
              :type boolean
              :initform nil)
     (%count-form :initarg :count-form
                  :reader read-count-form
                  :initform 1))))

(eval-always
  (defclass direct-data-slot-definition (data-slot-definition
                                         c2mop:standard-direct-slot-definition)
    ()))

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
  (defmethod c2mop:compute-effective-slot-definition
      ((class data-class) name direct-slot-definitions)
    (declare (ignore name))
    (let ((result (call-next-method)))
      result)))

(eval-always
  (defclass fundamental-data ()
    ((%size :initarg :size
            :reader read-size
            :vector nil
            :initform 0))
    (:metaclass data-class)))
