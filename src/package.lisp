(defpackage vector-classes
  (:use :cl)
  (:import-from :serapeum
                #:lret #:not #:eval-always
                #:flip)
  (:import-from :metabang-bind
                #:bind)
  (:import-from :alexandria
                #:if-let #:non-negative-fixnum
                #:compose
                #:curry #:rcurry #:when-let)
  (:import-from :iterate
                #:iterate #:sum #:collecting
                #:in #:for #:values))
