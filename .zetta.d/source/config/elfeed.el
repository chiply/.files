(use-package elfeed
  :config
  ;; break these out by category and assemble the list with append
  (setq elfeed-feeds
        '("http://nullprogram.com/feed/"
          "https://planet.emacslife.com/atom.xml"
          ;; aws docs rss feeds
          "https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-ec2-release-notes.rss"
          "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/amazon-ecs-release-notes.rss"
          "https://docs.aws.amazon.com/AmazonECR/latest/userguide/amazon-ecr-release-notes.rss"
          "https://docs.aws.amazon.com/quicksight/latest/user/amazon-quicksight-doc-release-notes.rss"
          "https://docs.aws.amazon.com/athena/latest/ug/amazon-athena-release-notes.rss"
          "https://docs.aws.amazon.com/streams/latest/dev/aks-release-notes.rss"
          "https://docs.aws.amazon.com/firehose/latest/dev/akf-release-notes.rss"
          "https://xkcd.com/rss.xml"
          ""
          ;;aws blogs from https://jiripik.com/2021/09/02/list-of-all-amazon-aws-rss-feeds/
          ;;"aws.amazon.com/blogs/architecture/feed/"
          ;;"aws.amazon.com/blogs/aws-cost-management/feed/"
          ;;"aws.amazon.com/blogs/apn/feed/"
          ;;"aws.amazon.com/podcasts/aws-podcast/"
          ;;"aws.amazon.com/blogs/awsmarketplace/feed/"
          "aws.amazon.com/blogs/aws/feed/"
          ;;"aws.amazon.com/blogs/big-data/feed/"
          ;;"aws.amazon.com/blogs/business-productivity/feed/"
          ;;"aws.amazon.com/blogs/compute/feed/"
          ;;"aws.amazon.com/blogs/contact-center/feed/"
          ;;"aws.amazon.com/blogs/containers/feed/"
          ;;"aws.amazon.com/blogs/database/feed/"
          ;;"aws.amazon.com/blogs/desktop-and-application-streaming/feed/"
          ;;"aws.amazon.com/blogs/developer/feed/"
          ;;"aws.amazon.com/blogs/devops/feed/"
          ;;"aws.amazon.com/blogs/enterprise-strategy/feed/"
          ;;"aws.amazon.com/blogs/mobile/feed/"
          ;;"aws.amazon.com/blogs/gametech/feed/"
          ;;"aws.amazon.com/blogs/hpc/feed/"
          ;;"aws.amazon.com/blogs/infrastructure-and-automation/feed/"
          ;;"aws.amazon.com/blogs/industries/feed/"
          ;;"aws.amazon.com/blogs/iot/feed/"
          ;;"aws.amazon.com/blogs/machine-learning/feed/"
          ;;"aws.amazon.com/blogs/mt/feed/"
          ;;"aws.amazon.com/blogs/media/feed/"
          ;;"aws.amazon.com/blogs/messaging-and-targeting/feed/"
          ;;"aws.amazon.com/blogs/networking-and-content-delivery/feed/"
          ;;"aws.amazon.com/blogs/opensource/feed/"
          ;;"aws.amazon.com/blogs/publicsector/feed/"
          ;;"aws.amazon.com/blogs/quantum-computing/feed/"
          ;;"aws.amazon.com/blogs/robotics/feed/"
          ;;"aws.amazon.com/blogs/awsforsap/feed/"
          ;;"aws.amazon.com/blogs/security/feed/"
          ;;"aws.amazon.com/blogs/startups/feed/"
          ;;"aws.amazon.com/blogs/storage/feed/"
          ;;"aws.amazon.com/blogs/training-and-certification/feed/"
          ;;"aws.amazon.com/blogs/modernizing-with-aws/feed/"

          ;; youtube
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCHnyfMqiRRG1u-2MsSQLbXA"
          "https://www.youtube.com/feeds/videos.xml?channel_id=UCAiiOTio8Yu69c3XnR7nQBQ"
          ))
  )

;;(use-package elfeed-tube
  ;;:config
  ;;;; (setq elfeed-tube-auto-save-p nil) ; default value
  ;;;; (setq elfeed-tube-auto-fetch-p t)  ; default value
  ;;(elfeed-tube-setup)
;;
  ;;:bind (:map elfeed-show-mode-map
         ;;("F" . elfeed-tube-fetch)
         ;;([remap save-buffer] . elfeed-tube-save)
         ;;:map elfeed-search-mode-map
         ;;("F" . elfeed-tube-fetch)
         ;;([remap save-buffer] . elfeed-tube-save)))
