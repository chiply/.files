(use-package wombag
  :after (embark org)
  :ensure (wombag :host github :repo "karthink/wombag")

  :config
  (setq wombag-host "https://app.wallabag.it"
        wombag-username "charliebkr707"
        wombag-password "Emaj7#13"
        ;; workmac
        wombag-client-id "25972_3dslc2j6jpc0k0ksgcwks0k8g8s0wos0o0gw4ksk4okc8o8c80"
        wombag-client-secret "2lkyuyw9282sw0cog4g8o04480g4ogksow8w8ccg0kossow408")

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
