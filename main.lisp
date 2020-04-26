(uiop/package:define-package :cl-sesame/main (:nicknames :cl-sesame) (:use :cl)
                             (:shadow) (:import-from :jonathan)
                             (:import-from :dexador)
                             (:export :*endpoint* :*authkey* :sesame
                              :list-sesames :get-sesame-status :control-sesame
                              :action-result)
                             (:intern))
(in-package :cl-sesame/main)
;;don't edit above

(defvar *endpoint* "https://api.candyhouse.co/public")
(defvar *authkey* nil)

(defclass sesame ()
  ((name :initarg :|nickname| :reader sesame-name)
   (serial :initarg :|serial| :reader sesame-serial)
   (id :initarg :|device_id| :reader sesame-id)))

(defmethod print-object ((obj sesame) out)
  (print-unreadable-object (obj out :type t)
    (format out "~s" (sesame-name obj))))

(defun list-sesames (&key (authkey *authkey*))
  (assert authkey)
  (mapcar (lambda (x) (apply #'make-instance 'sesame x))
          (jojo:parse (dex:get (format nil "~A/sesames" *endpoint*)
                               :headers `(("Authorization" . ,authkey))))))

(defun get-sesame-status (sesame &key (authkey *authkey*))
  (assert authkey)
  (jojo:parse (dex:get (format nil "~A/sesame/~A" *endpoint* (sesame-id sesame))
                       :headers `(("Authorization" . ,authkey)))))

(defun control-sesame (sesame command &key (authkey *authkey*))
  (assert authkey)
  (assert (find command '("lock" "unlock" "sync") :test 'equal))
  (jojo:parse (dex:post (format nil "~A/sesame/~A" *endpoint* (sesame-id sesame))
                        :headers `(("Authorization" . ,authkey)
                                   ("Content-Type" . "application/json"))
                        :content (jojo:to-json `(:|command| ,command)))))

(defun action-result (task-id &key (authkey *authkey*))
  (assert authkey)
  (jojo:parse (dex:get (format nil "~A/action-result?task_id=~A" *endpoint* task-id)
                       :headers `(("Authorization" . ,authkey)))))
