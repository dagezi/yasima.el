;;; yasima.el
;;; dagezi@gmail.com 2011-03-25 (Fri)
;;; Do as you like.

(require 'url)

(defconst yasima-interval (* 12 60))
(defconst yasima-tepco-usage-api-url "http://tepco-usage-api.appspot.com/latest.json")

(defvar yasima-timer nil)
(defvar yasima-string nil "")
  
(defun yasima-update (status)
  (let (usage capacity)
    (goto-char (point-min))
    (or (and (re-search-forward "\"usage\":\\s +\\([0-9]+\\)")
	     (setq usage (string-to-number (match-string 1)))
	     (progn (goto-char (point-min)) t)
	     (re-search-forward "\"capacity\":\\s +\\([0-9]+\\)")
	     (setq capacity (string-to-number (match-string 1)))
	     (setq yasima-string 
		   (format "%2d%%" (/ (* usage 100) capacity))))
	(setq yasima-string "%%%")))
  (force-mode-line-update)
  (sit-for 0))

(defun yasima-event-handler ()
  (url-retrieve yasima-tepco-usage-api-url #'yasima-update))

;;;###autoload
(define-minor-mode yasima-mode
  "Show power usage of Tokyo Denryoku in modeline"
  :global t
  (and yasima-timer (cancel-timer yasima-timer))
  (setq yasima-timer nil)
  (setq yasima-string "")
  (or global-mode-string (setq global-mode-string '("")))
  (if yasima-mode
      (progn
	(or (memq 'yasima-string global-mode-string)
	    (setq global-mode-string
		  (append global-mode-string '(yasima-string))))
	(setq yasima-timer
	      (run-at-time nil yasima-interval #'yasima-event-handler)))))

	