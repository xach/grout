;;;; package.lisp

(defpackage #:grout
  (:use #:cl)
  (:export #:client-login-token
           #:simpler-request
           #:authenticated-request
           #:*token*)
  (:shadowing-import-from #:drakma
                          #:http-request))

(in-package #:grout)

