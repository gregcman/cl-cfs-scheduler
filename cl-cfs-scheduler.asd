(asdf:defsystem "cl-cfs-scheduler"
  :depends-on (;;:cl-telegram-bot
	       ;;:alexandria
	       ;;:utility

	       :uncommon-lisp
	       )
  :serial t
  :components ((:file "scheduler")))
