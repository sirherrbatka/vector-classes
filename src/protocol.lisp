(in-package :vector-classes)


(eval-always
  (defclass fundamental-data ()
    ((%size :initarg :size
            :reader read-size
            :vector nil
            :initform 0))
    (:metaclass data-class)))


(eval-always
  (defgeneric allocate-data (class size arguments)
    (:method ((class fundamental-data) (size integer) arguments)
      (check-type size non-negative-fixnum)
      (check-type arguments list)
      (lret (result (apply #'allocate-instance class arguments))
        (setf (slot-value result '%size) size)))))


(eval-always
  (defgeneric initialize-slots (class instance arguments)))


(declaim (inline getf-one-of-many))
(eval-always
  (defun getf-one-of-many (place &rest arguments)
    (iterate
      (for v on place)
      (for p-v previous v)
      (for k initially t then (not k))
      (when (and k
                 (member p-v arguments))
        (return v)))))


(eval-always
  (defun generate-slot-initialization-form (slot
                                            instance-name
                                            initargs-name)
    (let* ((slot-name (c2mop:slot-definition-name slot))
           (initform-present-p (not (null (c2mop:slot-definition-initfunction slot))))
           (slot-initform (when initform-present-p
                            (c2mop:slot-definition-initform slot)))
           (slot-initargs (c2mop:slot-definition-initargs slot))
           (is-vector-p (read-vector slot))
           (type (c2mop:slot-definition-type slot))
           (count-arg (read-count-arg slot))
           (count-form (read-count-form slot))
           (!size (gensym)))
      (if is-vector-p
          (if (endp slot-initargs)
              (when initform-present-p
                `(let ((,!size (read-size ,instance-name)))
                   (setf #1=(slot-value ,instance-name ',slot-name)
                         (map-into (make-array ,!size :element-type ',type)
                                   (lambda () ,slot-initform)))))
              `(let ((,!size (read-size ,instance-name)))
                 (setf #1#
                       (map-into (make-array ,!size :element-type ',type)
                                 ,(if initform-present-p
                                      `(or (when-let ((val (getf-one-of-many ,initargs-name
                                                                             ,@slot-initargs)))
                                             (constantly val))
                                           (lambda () ,slot-initform)))))))
          (if (endp slot-initargs)
              (when initform-present-p
                `(setf #1#
                       ,slot-initform))
              (if initform-present-p
                  `(setf #1#
                         (or (getf-one-of-many ,initargs-name ,@slot-initargs)
                             ,slot-initform))
                  `(when-let ((value (getf-one-of-many ,initargs-name ,@slot-initargs)))
                     (setf #1# value))))))))


(eval-always
  (defun generate-initialization-function (class)
    `(lambda (class instance initiargs)
      ,@(let ((slots (c2mop:class-slots class)))
          (iterate
            (for slot in slots)
            (collecting (generate-slot-initialization-form
                         slot 'instance 'initargs)))))))


#|
We need to establish proper initialize-slots function for each class. This method will take care of that.
|#
(eval-always
  (defmethod shared-initialize ((instance data-class)
                                slot-names
                                &rest initargs
                                &key &allow-other-keys)
    (declare (ignore initargs))
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
