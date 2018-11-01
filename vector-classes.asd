#|
  This file is a part of data-oriented-macros project.
  Copyright (c) 2018 Marek Kochanowicz (sirherrbatka@gmail.com)
|#

(asdf:defsystem "vector-classes"
  :author "Marek Kochanowicz"
  :license "Simplified BSD"
  :depends-on (:alexandria :serapeum :iterate :metabang-bind
               :closer-mop)
  :pathname "src"
  :components ((:file "package")
               (:file "utils")
               (:file "mop")
               (:file "protocol")
               (:file "api"))
  :description "Provides metaclass for classes storing vectors of heterogenous types.")
