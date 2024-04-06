(use-package transient
  ;;:config
  ;;(setq transient-history-file
        ;;(expand-file-name ".data/transient/history" user-emacs-directory))
  )

(require 'ert)

(ert-deftest test-fn0 ()
  (should (length> (transient-act) 0)))

;; tests
;; (ert 'test-fn0)

;; once all tests pass
;;(with-simulated-input
;;    "-s-ad"
;; (transient0)
;; )
;;
;;
;;(setq foo (progn 
;;  (transient0)
;;  (execute-kbd-macro "-s-ad")))
;;
