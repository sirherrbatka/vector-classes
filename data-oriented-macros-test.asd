#|
  This file is a part of data-oriented-macros project.
  Copyright (c) 2018 Marek Kochanowicz (sirherrbatka@gmail.com)
|#

(defsystem "data-oriented-macros-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Marek Kochanowicz"
  :license "Simplified BSD"
  :depends-on ("data-oriented-macros"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "data-oriented-macros"))))
  :description "Test system for data-oriented-macros"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
