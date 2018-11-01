(defpackage vector-classes
  (:use :cl)
  (:import-from :serapeum
                #:lret #:not #:eval-always)
  (:import-from :alexandria
                #:if-let #:non-negative-fixnum
                #:curry #:rcurry #:when-let)
  (:import-from :iterate
                #:iterate #:sum #:collecting
                #:in #:for #:values))
