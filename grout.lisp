;;;; grout.lisp

(in-package #:grout)

(defvar *client-identification* "xach-grout-1")

(defvar *token*)

;;; ClientLogin style

(defvar *client-login-endpoint*
  "https://www.google.com/accounts/ClientLogin")

(defvar *known-services*
  '("cl" "gbase" "blogger" "cp" "writely" "lh2" "apps" "wise" "youtube"))

(defun simpler-request (uri &key content (method :get) parameters)
  (multiple-value-bind (body status headers uri stream must-close reason)
      (http-request uri
                    :want-stream nil
                    :keep-alive nil
                    :redirect nil
                    :method method
                    :content content
                    :parameters parameters)
    (declare (ignore must-close headers uri))
    (ignore-errors (close stream))
    (values body status reason)))

(defun authenticated-request (uri &key content (method :get) parameters
                              content-type)
  (multiple-value-bind (body status headers uri stream must-close reason)
      (http-request uri
                    :want-stream nil
                    :keep-alive nil
                    :redirect nil
                    :method method
                    :content-type content-type
                    :content content
                    :external-format-out :utf-8
                    :additional-headers (list (cons "Authorization"
                                                    (format nil "GoogleLogin auth=~A" grout:*token*))
                                              (cons "GData-Version" "2"))
                    :parameters parameters)
    (declare (ignore must-close headers uri))
    (ignore-errors (close stream))
    (values body status reason)))


                    
                    
(defun starts-with (prefix string)
  (and (<= (length prefix) (length string))
       (= (mismatch prefix string) (length prefix))))


(defun client-login-token (email password service)
  (assert (member service *known-services* :test 'string=))
  (let ((response
         (simpler-request *client-login-endpoint*
                          :method :post
                          :parameters (list (cons "Email" email)
                                            (cons "Passwd" password)
                                            (cons "service" service)
                                            (cons "accountType" "HOSTED_OR_GOOGLE")
                                            (cons "source" *client-identification*)))))
    (with-input-from-string (stream response)
      (loop for line = (read-line stream nil)
            while line
            when (starts-with "Auth=" line)
            return (subseq line 5)))))

