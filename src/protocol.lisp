(in-package :vector-classes)


(eval-always
  (defun fixed-dimensions-p (slot)
    (check-type slot effective-data-slot-definition)
    (endp (read-dimensions-arg slot))))


(eval-always
  (defun generate-array-initialization-form (slot size initargs)
    (let* ((initform-present-p (not (null (c2mop:slot-definition-initfunction slot))))
           (slot-initform (when initform-present-p
                            (c2mop:slot-definition-initform slot)))
           (slot-initargs (c2mop:slot-definition-initargs slot))
           (type (c2mop:slot-definition-type slot))
           (dimensions-arg (read-dimensions-arg slot))
           (dimensions-form (read-dimensions-form slot))
           (!dims (gensym))
           (!array (gensym))
           (!val (gensym))
           (!found (gensym)))
      `(let* ((,!dims ,(if dimensions-arg
                           `(or (getf-one-of-many ,initargs ,@dimensions-arg)
                                ,dimensions-form)
                           dimensions-form))
              (,!array (make-array (cons ,size ,!dims) :element-type ',type))
              (,!val (bind (((:values ,!val ,!found)
                             (getf-one-of-many ,initargs ,@slot-initargs)))
                       (if ,!found
                           (constantly ,!val)
                           ,(if initform-present-p
                                `(lambda () ,slot-initform)
                                nil)))))
         (when ,!val
           (map-into (unfold-array ,!array) ,!val))
         ,!array))))


(eval-always
  (defun generate-slot-initialization-form (slot
                                            instance-name
                                            initargs-name)
    (let* ((slot-name (c2mop:slot-definition-name slot))
           (initform-present-p (~> slot c2mop:slot-definition-initfunction
                                   null not))
           (slot-initform (when initform-present-p
                            (c2mop:slot-definition-initform slot)))
           (slot-initargs (c2mop:slot-definition-initargs slot))
           (is-array-p (read-array slot)))
      (if is-array-p
          `(setf #1=(slot-value ,instance-name ',slot-name)
                 ,(generate-array-initialization-form slot
                                                      `(read-size ,instance-name)
                                                      initargs-name))
          (if (endp slot-initargs)
              (when initform-present-p
                `(setf #1#,slot-initform))
              (if initform-present-p
                  `(setf #1#
                         (or (getf-one-of-many ,initargs-name ,@slot-initargs)
                             ,slot-initform))
                  `(when-let ((value (getf-one-of-many ,initargs-name ,@slot-initargs)))
                     (setf #1# value))))))))


(eval-always
  (defun generate-initialization-function (class)
    `(lambda (class instance initargs)
       (declare (ignore class)
                #+sbcl(sb-ext:muffle-conditions sb-ext:compiler-note))
      ,@(iterate
          (for slot in (c2mop:class-slots class))
          (collecting (generate-slot-initialization-form
                       slot 'instance 'initargs))))))


(eval-always
  (defgeneric initialize-slots (class instance arguments)))


#|
We need to establish proper initialize-slots function for each class. This method will take care of that.
|#
(eval-always
  (defmethod shared-initialize ((instance data-class)
                                slot-names
                                &rest initargs
                                &key &allow-other-keys)
    (declare (ignore initargs))
    (call-next-method)
    (c2mop:ensure-finalized instance)
    (let* ((gf #'initialize-slots)
           (lambda-form (generate-initialization-function instance)))
      (add-method gf
                  (make-instance 'standard-method
                                 :function (compile nil lambda-form)
                                 :specializers (list (find-class 'data-class)
                                                     instance
                                                     (find-class 'list))
                                 :qualifiers nil
                                 :lambda-list '(class instance initargs))))))


(eval-always
  (defclass fundamental-data ()
    ((%size :initarg :size
            :reader read-size
            :reader size
            :array nil
            :initform 0))
    (:metaclass data-class)))


(eval-always
  (defgeneric allocate-data (class size arguments)
    (:method ((class fundamental-data) (size integer) arguments)
      (check-type size non-negative-fixnum)
      (check-type arguments list)
      (lret (result (apply #'allocate-instance class arguments))
        (setf (slot-value result '%size) size)))))
