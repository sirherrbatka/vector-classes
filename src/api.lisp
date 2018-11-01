(in-package :vector-classes)


(defmacro define-data (name direct-superclasses direct-slots &rest options)
  `(eval-always
     (defclass ,name (,@direct-superclasses fundamental-data)
       ,direct-slots
       ,@options
       (:metaclass data-class))))


(defgeneric make-data (type size &rest arguments))


(defmethod make-data (type size &rest arguments)
  (let* ((class (find-class type))
         (instance (allocate-data class size arguments)))
    (initialize-slots class instance arguments)
    instance))
