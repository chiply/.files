(use-package dtache-consult
  ;; it is included in dtache
  :straight nil
  :after dtache
  :bind ([remap dtache-open-session] . dtache-consult-session))
