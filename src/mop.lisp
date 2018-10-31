(in-package :vector-classes)


(defclass data-slot-definition (closer-mop:slot-definition)
  ((%count-arg :initarg :count-arg
               :reader read-count-arg
               :initform nil)
   (%scalar :initarg :scalar
            :reader read-scalar
            :initform t)
   (%count-form :initarg :count-form
                :reader read-count-form
                :initform 1)))

(defclass direct-data-slot-definition (data-slot-definition
                                       c2mop:direct-slot-definition)
  ())


(defclass effective-data-slot-definition (data-slot-definition
                                          c2mop:effective-slot-definition)
  ())


(defclass data-class (closer-mop:standard-class)
  ())


(defmethod c2mop:validate-superclass ((class data-class)
                                      (super c2mop:standard-class))
  t)


(defmethod c2mop:direct-slot-definition-class ((class data-class)
                                               &rest initargs)
  (declare (ignore initargs))
  (find-class 'direct-data-slot-definition))


(defmethod c2mop:effective-slot-definition-class ((class data-class)
                                                  &rest initargs)
  (declare (ignore initargs))
  (find-class 'effective-data-slot-definition))


(defclass fundamental-data ()
  ((%size :initarg :size
          :reader read-size
          :scalar t
          :initform 0))
  (:metaclass data-class))


