;; TODO selecting, acting on multiple candidates -- what happens when search is backspaced do we lose the selection?
;; TODO inputting multiple searhc strings
;; what are the other patterns... let's say we wanted multiple for... realistically we want a logical or for the styyle dispathers
;; som limited ability per command... we have regexes at our disposal, so an individual regex can have the logical or (\|)
;; another pattern to this could be that we typically don't want to do this, and if we done, then create mutliple export buffers?  


;; TODO flat has issues with going to next, want scroll margin
;; TODO right click to embark act on item

;; TODO look into completing read multiple
;; TODO using cape to merge capf functions; tried, couuldn't get it workinig
;; TODO consult future
;; TODO history element!  this seems odd by defautl... I want 1) incremental history search and 2) history scoped to command
;; TODO reverse is happening in flat... doesn't make sense, need to override?

;; prevent blank space until a char is typed in?

;; TODO! formalize all features of a completion/action paradigm,
;; sometimies it isn't obvous where features come from... eg style
;; dispatchers within orderless.

(setq enable-recursive-minibuffers t)

(require 'sh-script)
(defun my-sh-completion-at-point ()
  (let ((end (point))
        (beg (save-excursion (sh-beginning-of-command))))
    (when (and beg (> end beg))
      (bash-completion-dynamic-complete-nocomint beg end t))))


;;;;;;;;;;;;;;;;;;;;;;;;; CAP
;;;;;;;;;;; FILENAMES
;;;;;;;;;; BUFFER TEXT, with dabbrev
(defun z-completion-at-point (arg)
  "A very flexible and broadly scoped completion function.  This
combines functionality from a lot of different completion packages and
prioritizes them in an order that makes sense in almost all cases.
The completion strategy used (caveat: ambiguous for
[completion-at-point]) is reported to the end-user.  The order of
high-level completion strategies:

1. static expansion (abbrev and yasnippet)

    1. abbreviations (abbrev)

    2. snippets (yas)

notes: expansion is the keyword here, static is used as a descriptor
since literal matches would only ever correspond to one candidate

2. dynamic completion (completion at point)

The specific strategy is determined by a precedence of
completion-at-point functions, specified in this function.  As this
grows in complexity, we would likely separate this out

notes: completion is the keyword here, since multiple candidates will
exist and some ui will be required to incrementally narrowing
autocomplete down to the desired candidate

3. dynamic expansion (hippie expand)

The specific strategy is determined by a precedence of functions in
z-hippie-expand

notes: expansion is the keyword here, dynamic is used as a descriptor
since there can be multiple candidates.  expansion is preferred over
completion in this case because some completion functions (eg dabbrev
all buffers) can be very computationally intensive.  This is a natural
consequence of this strategy being so far down the precedence (eg
other options have been exhausted).  expansion itself is useful in
mitigate this compute problem as it avoids computing a potentially
huge list oof candidates.  hippie-expand is useful to this same end as
it allows the setting of precedence (eg dabbrev, then dabbrev visible,
then dabbrev all buffers).

Guidelines:

- Given the precendence in step 1, it is recommended that abbrev keys
  and yas keys are globally unique.

Design Notes:

- lsp is intentionally not included here as this is seen as a
  particularly heavy form of expansion.  It is also seen as a special
  case of completion that should be handled in a dedicated way,
  outside of this function

TODO -- usage of arg to control 1 fo two pathways... ispell for
example, this probably warrents implementation will be that prefix arg
use brings up a menu where we can chose some non-default (ispell,
tempel expand?)
"  
  (interactive "P")
  (or ;; the or causes this to exit when the first condition is matched
   ;;;;;;;;;;;;;;;;; Literal Matches (Static Expansion)
   ;; Abbrev
   (when (expand-abbrev) (message "[Abbrev]"))
   ;; Snippets
   (when
       (if (member (thing-at-point 'word) (yas-active-keys))
           (yas-expand)
         nil)
     (message "[Yas]")
     )
   ;;;;;;;;;;;;;;;;; Dynamic Completion (Incremental Narrowing Completion)
   (when
       (let* ((mode-capf (cond
                          ((or (string= major-mode "emacs-lisp-mode")
                               (string= major-mode "lisp-interaction-mode"))
                           ;; todo -- not making it through to ispell... why?
                           '(elisp-completion-at-point cape-file))
                          ((string= major-mode "python-ts-mode")
                           '(python-completion-at-point cape-file))
                          ((string= major-mode "org-mode")
                           '(cape-file
                             org-roam-complete-everywhere
                             org-roam-tag-completions
                             org-roam-complete-link-at-point
                             cape-ispell))
                          ((string= major-mode "yaml-mode")
                           '(cape-file))
                          ((string= major-mode "sh-mode")
                           '(cape-file
                             my-sh-completion-at-point))
                          ))
              (completion-at-point-functions mode-capf))
         (completion-at-point))
     (message "[completion-at-point]"))
   ;;;;;;;;;;;;;;;; Hippie (Dynamic Expansion)
   (let ((hippie-expand-try-functions-list '(try-expand-dabbrev
                                             try-expand-dabbrev-visible
                                             try-expand-dabbrev-all-buffers
                                             try-expand-whole-kill
                                             )))
     (hippie-expand arg)) ;; takes care of its own messaging
   (when
       (let* ((mode-capf (cond
                          ((or (string= major-mode "emacs-lisp-mode")
                               (string= major-mode "lisp-interaction-mode"))
                           ;; todo -- not making it through to ispell... why?
                           '(cape-ispell))
                          ((string= major-mode "python-ts-mode")
                           '(cape-ispell))
                          ((string= major-mode "org-mode")
                           '(cape-ispell))))
              (completion-at-point-functions mode-capf))
         (completion-at-point))
     (message "[ispell]"))
   ))






(general-define-key
 :states '(insert)
 :keymaps '(python-ts-mode-map
            lisp-interaction-mode-map
            emacs-lisp-mode-map
            lisp-mode-map
            sql-mode-map
            web-mode-map
            js2-mode-map
            rjsx-mode-map
            text-mode-map
            org-mode-map
            bibtex-mode-map
            sh-mode-map
            lark-mode-map
            dockerfile-mode-map
            terraform-mode-map
            )
 "C-;" 'indent-for-tab-command
 "<tab>" 'z-completion-at-point
 )


;;-- LEFT OFF NEED A MAIN ORG-ROAM CAPTURE TEMPLATE THAT STORES A LINK FROM EWW
;;
;;-- order of operations for z-wget (rename to z-remote-pdf-to-node)
;;-- order of operations for z-wget (rename to z-webpage-to-node)
;;
;;-- url is captured
;;-- a roam node is created and the url is provided as a ref
;;-- user edits title, this will get converted into a bibtex key, so iuf you want certain prefixes, then apply them in the node title
;;-- no bibtex is entered by default, but one (must) can be provided when a pdf is to be stored locally.  Think about this step as simply creatinga  local  copy.  We try not to apply edits directly on top of external resources (pdfs)
;;
;;-- function: z-roam-download-pdf-from-ref












