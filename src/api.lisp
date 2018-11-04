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


(eval-always
  (defun generate-let-binding-forms (bindings instance)
    (mapcar (lambda (form)
              (bind (((binding slot-name) form))
                `(,binding (slot-value ,instance ',slot-name))))
            bindings)))


(eval-always
  (defun generate-type-forms (bindings class)
    (unless (null class)
      (let ((class (find-class class)))
        (cons 'cl:declare
              (mapcar (lambda (form)
                        (bind (((binding slot-name) form)
                               (slot (slot-of-name class slot-name))
                               (type (c2mop:slot-definition-type slot))
                               (array (read-array slot))
                               (fixed-dimensions (fixed-dimensions-p slot))
                               (dimensions (read-dimensions-form slot)))
                          (unless array
                            (error "Slot ~a is not array in the class." slot-name))
                          (if fixed-dimensions
                              `(type (simple-array ,type (* ,@dimensions)) ,binding)
                              `(type (simple-array ,type) ,binding))))
                      bindings))))))


(eval-always
  (defun generate-macrolet-binding-forms (bindings index-form)
    (mapcar (lambda (form)
              (let ((binding (car form)))
                `(,binding
                  (&rest args)
                  `(aref ,,binding ,',index-form ,@args))))
            bindings)))


(defmacro with-data ((bindings instance index-form &optional class) &body body)
  `(let ,(generate-let-binding-forms bindings instance)
     ,(generate-type-forms bindings class)
     (macrolet ,(generate-macrolet-binding-forms bindings index-form)
       ,@body)))
