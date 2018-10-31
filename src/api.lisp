(in-package :vector-classes)


(defmacro define-data (name direct-superclasses direct-slots &rest options)
  `(eval-always
     (defclass ,name (,@direct-superclasses fundamental-data)
       ,direct-slots
       ,@options
       (:metaclass data-class))))
