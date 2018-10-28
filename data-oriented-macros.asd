#|
  This file is a part of data-oriented-macros project.
  Copyright (c) 2018 Marek Kochanowicz (sirherrbatka@gmail.com)
|#

#|
  Author: Marek Kochanowicz (sirherrbatka@gmail.com)
|#

(asdf:defsystem "data-oriented-macros"
  :version "0.1.0"
  :author "Marek Kochanowicz"
  :license "Simplified BSD"
  :depends-on (:alexandria
               :serapeum
               :iterate
               :closer-mop
               :metabang-bind)
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "data-oriented-macros"))))
  :description ""
  :in-order-to ((test-op (test-op "data-oriented-macros-test"))))
