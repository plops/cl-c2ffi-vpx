(eval-when (:compile-toplevel)
  (ql:quickload :cl-autowrap))
(defpackage :vpx
  (:use  :cl #:autowrap))
(in-package :vpx)

(defparameter *spec-path* (merge-pathnames
			   "stage/cl-c2ffi-vpx/"
			   (user-homedir-pathname)))
(progn
  (with-open-file (s "/tmp/vpx0.h"
                     :direction :output
                     :if-does-not-exist :create
                     :if-exists :supersede)
    (format s "#include \"/usr/include/vpx/vpx_decoder.h\"~%"))
  (autowrap::run-check autowrap::*c2ffi-program*
                       (autowrap::list "/tmp/vpx0.h"
                                       "-D" "null"
                                       "-M" "/tmp/vpx_decoder_macros.h"
                                       "-A" "x86_64-pc-linux-gnu"))
  (with-open-file (s "/tmp/vpx1.h"
                     :direction :output
                     :if-does-not-exist :create
                     :if-exists :supersede)
    (format s "#include \"/tmp/vpx0.h\"~%")
    (format s "#include \"/tmp/vpx_decoder_macros.h\"~%")))

(autowrap:c-include "/tmp/vpx1.h"
                    :spec-path *spec-path*
                    :exclude-arch ("arm-pc-linux-gnu"
                                   "i386-unknown-freebsd"
                                   "i686-apple-darwin9"
                                   "i686-pc-linux-gnu"
                                   "i686-pc-windows-msvc"
                                   "x86_64-apple-darwin9"
                                        ;"x86_64-pc-linux-gnu"
                                   "x86_64-pc-windows-msvc"
                                   "x86_64-unknown-freebsd")
                    :exclude-sources ()
                    :include-sources ()
                    :trace-c2ffi t)


#+nil
(cffi:use-foreign-library "libvpx.so")

;; example code from https://chromium.googlesource.com/webm/libvpx/+/master/examples/simple_decoder.c
;; https://github.com/webmproject/libvpx/blob/master/examples/simple_decoder.c

(defparameter *fn* (merge-pathnames
			   "stage/sb-httpd-nonblock/screen_animation.webm"
			   (user-homedir-pathname)))

;; in order to decode an ivf file i need to translate the code from
;; ivfdec.c and video_reader.c. parsing webm seems even more difficult

(defparameter *reader* (v))
