(use-package wombag
  :after (embark org)
  :straight (wombag :type git :host github :repo "karthink/wombag")

  :config
  (setq wombag-host "REMOVED-WALLABAG-HOST"
        wombag-username "REMOVED-WALLABAG-USERNAME"
        wombag-password "***REMOVED***"
        ;; workmac
        wombag-client-id "***REMOVED***"
        wombag-client-secret "***REMOVED***")

  (defun wombag-link-open (id _)
    (wombag-show-entry
     (nth 0 (let ((id id))
              (wombag-db-get-entries
               `[
                 :select ,(vconcat wombag-search-columns)
                 :from items
                 :where (= id ,id)]
               wombag-search-columns)))))

  (defun wombag-link-store-link ()
    (when (eq major-mode 'wombag-show-mode)
      (org-store-link-props
       :type "wombag"
       :link (format "wombag:%s" (alist-get 'id wombag-show-entry))
       :description (alist-get 'url wombag-show-entry))))

  (with-eval-after-load 'org
    (org-link-set-parameters
     "wombag"
     :follow #'wombag-link-open
     :store #'wombag-link-store-link))



  (general-define-key
   :keymaps 'wombag-search-mode-map
   "<return>" #'wombag-search-show-entry)
  (general-define-key
   :keymaps 'embark-url-map
   "w" #'wombag-add-entry))
