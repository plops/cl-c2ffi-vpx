;; socat "UNIX-LISTEN:/var/run/user/1000/wayland-0,reuseaddr,fork"


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
                       (autowrap::list "/tmp/usb0.h"
                                       "-D" "null"
                                       "-M" "/tmp/vpx_decoder_macros.h"
                                       "-A" "x86_64-pc-linux-gnu"))
  (with-open-file (s "/tmp/usb1.h"
                     :direction :output
                     :if-does-not-exist :create
                     :if-exists :supersede)
    (format s "#include \"/tmp/vpx0.h\"~%")
    (format s "#include \"/tmp/vpx_decoder_macros.h\"~%")))

(autowrap:c-include "/tmp/usb1.h"
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
                    :exclude-sources ("/usr/include/linux/types.h"
                                      "/usr/include/linux/magic.h")
                    :include-sources ("/usr/include/linux/ioctl.h")
                    :trace-c2ffi t)

(autowrap:c-include "/usr/include/vpx/vpx_decoder.h"
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
		    :exclude-sources ("/usr/include/"
				      "/usr/include/bits/"
				      "/usr/include/sys/")
		    :include-sources ())

#+nil
(cffi:use-foreign-library "libwayland-client.so")

;; example code from https://github.com/hdante/hello_wayland/helpers.c
#+nil
(defpar *display* (wl-display-connect (cffi:null-pointer)))

;; wl-display-get-registry is an inline function WHY?

#+nil
(defpar *registry*
    (wl-proxy-marshal-constructor *display* 
				  +WL-DISPLAY-GET-REGISTRY+
				  WL-REGISTRY-INTERFACE
				  ;; NULL but i don't know how to pass that
				  ))
#+nil
(wl-display-roundtrip *display*) ;; => 19

#+nil
(wl-proxy-destroy *registry*)

;; image = open image.bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; wl_proxy_marshal_constructor ((struct wl_proxy *) wl_shm,	  ;;
;;  WL_SHM_CREATE_POOL, &wl_shm_pool_interface, NULL, fd, size) ; ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;wl-registry-bind registry name wl-shm-interface (min version 1)
;(wl-proxy-marshal-constructor wl_shm)

;; create_memory_pool(image)
;; create_surface
;; create_buffer
;; bind_buffer
;; set_cursor_from_pool
;; set_button_callback

;; while !done
;; (wl-display-dispatch *display*)
