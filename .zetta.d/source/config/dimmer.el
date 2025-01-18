(use-package dimmer
  :demand
  :init
  (defun advise-dimmer-config-change-handler ()
    "Advise to only force process if no predicate is truthy."
    (let ((ignore (cl-some (lambda (f) (and (fboundp f) (funcall f)))
                           dimmer-prevent-dimming-predicates)))
      (unless ignore
        (when (fboundp 'dimmer-process-all)
          (dimmer-process-all t)))))

  (defun corfu-frame-p ()
    "Check if the buffer is a corfu frame buffer."
    (string-match-p "\\` \\*corfu" (buffer-name)))

  (defun dimmer-configure-corfu ()
    "Convenience settings for corfu users."
    (add-to-list
     'dimmer-prevent-dimming-predicates
     #'corfu-frame-p))

  (defun minimap-frame-p ()
    "Check if the buffer is a minimap frame buffer."
    (string-match-p "\\` \\*MINIMAP" (buffer-name)))

  (defun dimmer-configure-minimap ()
    "Convenience settings for minimap users."
    (add-to-list
     'dimmer-prevent-dimming-predicates
     #'minimap-frame-p))

  :config
  (dimmer-configure-posframe)
  (dimmer-configure-which-key)
  (dimmer-configure-magit) ;; transient
  (dimmer-configure-org) ;; org select and agenda
  (advice-add
   'dimmer-config-change-handler
   :override 'advise-dimmer-config-change-handler)
  (dimmer-configure-corfu)
  (dimmer-configure-minimap)
  (setq dimmer-fraction 0.4)
  (setq dimmer-watch-frame-focus-events nil)
  (dimmer-mode t))



