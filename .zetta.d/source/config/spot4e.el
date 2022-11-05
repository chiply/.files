;; spotify
;;(use-package spot4e
;;:straight nil
;;:load-path "~/.files/.zetta.d/zettapkg/spot4e"
;;:demand t
;;
;;:init
;;(run-with-timer 0 (* 60 59) 'spot4e-refresh)
;;
;;:general
;;(
;;:keymaps 'evil-insert-state-map
;;(general-chord ",q") 'hydra-spot4e/body
;;)
;;(
;;:states '(normal visual)
;;:keymaps 'override
;;:prefix ","
;;"q" 'hydra-spot4e/body
;;)
;;
;;:hydra
;;(defhydra+ hydra-spot4e ()
;;("s" hydra-spot4e-search/body "Search" :exit t)
;;("p" hydra-spot4e-play/body "Player" :exit t)
;;("b" hydra-spot4e-browse/body "Browse" :exit t))
;;
;;(defhydra+ hydra-spot4e-play ()
;;("<backspace>" hydra-spot4e/body :exit t)
;;("P" spot4e-player-play "play" :column "Toggle")
;;("p" spot4e-player-pause "pause")
;;("j" spot4e-player-next "next" :column "Seek")
;;("k" spot4e-player-previous "previous")
;;("s" spot4e-save-default "save current track" :column "Save")
;;("S" spot4e-save-to-playlist "save current track to playlist")
;;)
;;
;;(defhydra+ hydra-spot4e-browse ()
;;("<backspace>" hydra-spot4e/body :exit t)
;;("c" spot4e-helm-search-categories "By category" :column "Playlists")
;;("f" spot4e-helm-search-featured-playlists "Features playlists")
;;("t" spot4e-helm-search-recommendation-tracks "By Track" :column "Recommendations")
;;("g" spot4e-helm-search-recommendation-genres "By Genre")
;;("n" spot4e-helm-search-new-releases "releases" :column "New")
;;)
;;
;;(defhydra+ hydra-spot4e-search ()
;;("<backspace>" hydra-spot4e/body :exit t)
;;("t" spot4e-helm-search-tracks "tracks" :column "Search") 
;;("a" spot4e-helm-search-artists "artists")
;;("A" spot4e-helm-search-albums "albums")  
;;("ut" spot4e-helm-search-user-tracks "your tracks" :column "User")
;;("up" spot4e-helm-search-user-playlists "your playlists")
;;("ua" spot4e-helm-search-user-artists "your artists")
;;("ur" spot4e-helm-search-recent-tracks "recent tracks")
;;)
;;)
