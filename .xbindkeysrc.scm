(define (normal-bindings)
  "Non-ergonomic bindings"
  (xbindkey-function '("m:0x0" "c:66")
					 (lambda()
					   (if (and (interval?) released) (ergo-bindings))))
  (xbindkey '(Shift Mod4 grave) "dunstctl history-pop")
  (xbindkey '(Mod4 grave) "dunstctl close")
  (xbindkey '(Mod4 a) "rofi -show combi -modi combi -combi-modi drun,run -display-combi Launch -disable-history")
  (xbindkey '(Mod4 b) "blueman-manager")
  (xbindkey '(Mod4 c) "qalculate-gtk")
  (xbindkey '(Mod4 j) "\"$HOME\"/.local/lib/dotfiles/misc_scripts/word_count")
  (xbindkey '(Mod4 p) "keepassxc")
  (xbindkey '(Mod4 s) "flameshot gui")
  (xbindkey '(Mod4 u) "gucharmap")
  (xbindkey '(Mod4 v) "pavucontrol")
  (xbindkey '(Mod4 w) "firefox")
  (xbindkey '(Shift Mod4 w) "firefox --private-window")
  (xbindkey '(Mod1 Mod4 w) "chromium")
  (xbindkey '(Shift Mod1 Mod4 w) "chromium --incognito")

  (xbindkey '("b:9") "xdotool key Ctrl+Next")
  (xbindkey '("b:8") "xdotool key Ctrl+Prior")

  (xbindkey '(Mod4 comma) "playerctl previous")
  (xbindkey '(Mod4 n) "\"$HOME\"/.local/lib/dotfiles/misc_scripts/now_playing")
  (xbindkey '(Mod4 period) "playerctl next")
  (xbindkey '(Mod4 space) "playerctl play-pause")
  (xbindkey '(Shift Mod4 n) "\"$HOME\"/.local/lib/dotfiles/misc_scripts/select_player")
  (xbindkey '(XF86AudioNext) "playerctl next")
  (xbindkey '(XF86AudioPause) "playerctl pause")
  (xbindkey '(XF86AudioPlay) "playerctl play-pause")
  (xbindkey '(XF86AudioPrev) "playerctl previous")
  (xbindkey '(XF86AudioStop) "playerctl stop")

  ;; MS keys
  (xbindkey '(Control Shift Mod1 Mod4 m) "gtk-launch chrome-ocdlmjhbenodhlknglojajgokahchlkk-Default.desktop")
  (xbindkey '(Control Shift Mod1 Mod4 n) "mate-terminal --name vim -e vim --disable-factory")
  (xbindkey '(Control Shift Mod1 Mod4 o) "libreoffice")
  (xbindkey '(Control Shift Mod1 Mod4 space) "xdotool click 1")
  (xbindkey '(Control Shift Mod1 Mod4 t) "gtk-launch chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Default.desktop")
  )

(define released #t)
(define pressed #f)
(define last-keypress (get-internal-real-time))
(define old-time last-keypress)
(define (interval?)
  "Make sure time since last keypress is long enough"
  (set! old-time last-keypress)
  (set! last-keypress (get-internal-real-time))
  (> (- last-keypress old-time) 60000000))

(define (reset-normal-bindings)
  "Reset bindings"
  (ungrab-all-keys)
  (remove-all-keys)
  (normal-bindings)
  (grab-all-keys))

(define (ergo-cmd cmd)
  "Run an ergonomic command"
  (set! pressed #t)
  (set! key-repeat 0)
  (if released (reset-normal-bindings))
  (run-command cmd))

(define (launch-or-focus query cmd)
  "Return a string shell command for focusing a window matching the query or launching a program if the query is not matched"
  (string-append/shared "if id=$(xdotool search --desktop \"$(xdotool get_desktop)\" " query "); then xdotool windowactivate $id; else " cmd "; fi"))

(use-modules (ice-9 popen) (ice-9 rdelim))
(define x-offset -1)
(define y-offset -1)
(define (set-window-offsets)
  (if (and (eq? x-offset -1) (eq? y-offset -1))
	  (let
		((xprop-list
		   (string-split
			 (substring
			   (let*
				 ((port (open-input-pipe "xdotool getactivewindow | xargs xprop _NET_FRAME_EXTENTS -id"))
				  (str (read-line port)))
				 (close-pipe port) str) 31) #\,)))
		(set! x-offset (string->number (list-ref xprop-list 0)))
		(set! y-offset (string->number (substring (list-ref xprop-list 2) 1))))))

(define (move-window x y)
  (set-window-offsets)
  (if (not (eq? key-repeat 0))
  	(begin
  	  (set! x (* key-repeat x))
  	  (set! y (* key-repeat y))))
  (string-append/shared "xdotool getactivewindow windowmove --relative -- " (number->string (- x x-offset)) " " (number->string (- y y-offset))))

(define key-repeat 0)
(define fold-depth 4)
(define (key-repeat-enter num)
  (set! key-repeat (+ (* key-repeat 10) num)))

(define web (launch-or-focus "--classname '^(Navigator|chromium)$'" "firefox"))
(define email (launch-or-focus "--classname '^evolution$'" "evolution"))
(define spotify (launch-or-focus "--classname '^spotify$'" "spotify"))
(define office (launch-or-focus "--classname '^(libreoffice|lyx|code)$'" "\"$HOME\"/.local/lib/dotfiles/misc_scripts/launch_office"))
(define terminal (launch-or-focus "--classname '^mate-terminal$'" "mate-terminal"))

(define (ergo-bindings)
  "Ergonomic bindings"
  (ungrab-all-keys)
  (remove-all-keys)
  (set! pressed #f)
  (set! released #f)

  (xbindkey-function '(Escape) reset-normal-bindings)
  (xbindkey-function '("m:0x0" release "c:66")
					 (lambda ()
					   (if (interval?)
						 (if (and released (not pressed))
						   (ergo-cmd "rofi -show window -kb-remove-char-forward 'Control+d' -kb-delete-entry 'Delete' -window-close-on-delete false -window-command 'xdotool windowminimize {window}' -kb-accept-alt 'Alt+d'")
						   (if (or released pressed) (reset-normal-bindings))))
					   (set! released #t)))

  (xbindkey-function '("0") (lambda () (key-repeat-enter 0)))
  (xbindkey-function '("1") (lambda () (key-repeat-enter 1)))
  (xbindkey-function '("2") (lambda () (key-repeat-enter 2)))
  (xbindkey-function '("3") (lambda () (key-repeat-enter 3)))
  (xbindkey-function '("4") (lambda () (key-repeat-enter 4)))
  (xbindkey-function '("5") (lambda () (key-repeat-enter 5)))
  (xbindkey-function '("6") (lambda () (key-repeat-enter 6)))
  (xbindkey-function '("7") (lambda () (key-repeat-enter 7)))
  (xbindkey-function '("8") (lambda () (key-repeat-enter 8)))
  (xbindkey-function '("9") (lambda () (key-repeat-enter 9)))

  (xbindkey-function '(c) (lambda ()
							(if (eq? key-repeat 0)
							  (ergo-cmd "wmctrl -ic $(xdotool getactivewindow)")
							  (ergo-cmd (string-append/shared "window_stack -vafter_active=1 -vnum_windows=" (number->string key-repeat) " | xargs -n1 wmctrl -ic")))))
  (xbindkey-function '(d) (lambda () (ergo-cmd "xdotool getactivewindow windowstate --toggle SHADED")))
  (xbindkey-function '(e) (lambda () (ergo-cmd email)))
  (xbindkey-function '(f) (lambda () (if (not (eq? key-repeat 0))
										(set! fold-depth key-repeat))
									  (if (eq? fold-depth 1)
										(ergo-cmd "window_stack -vcurr_workspace=1 -vafter_active=1 -vprint_prefix='windowactivate ' -vreverse=1 | xdotool -")
										(ergo-cmd (string-append/shared "window_stack -vcurr_workspace=1 -vafter_active=1 -vprint_prefix='windowactivate ' -vnum_windows=" (number->string fold-depth) " -vreverse=1 | xdotool -")))))
;  (xbindkey-function '(f) (lambda ()
;							(ergo-cmd (string-append/shared "window_stack -vprint_prefix='windowactivate ' -vskip_first=1 -vnum_windows=" (number->string key-repeat) " | xdotool -"))))
  (xbindkey-function '(g) (lambda () (ergo-cmd office)))
  (xbindkey-function '(grave) (lambda () (ergo-cmd "dunstctl action 0")))
  (xbindkey-function '(q) (lambda () (ergo-cmd "focus_stack")))
  (xbindkey-function '(space) (lambda () (ergo-cmd "focus_stack 0.7")))
  (xbindkey-function '(t) (lambda () (ergo-cmd terminal)))
  (xbindkey-function '(w) (lambda () (ergo-cmd web)))
  (xbindkey-function '(y) (lambda () (ergo-cmd spotify)))

  (xbindkey-function '(h) (lambda () (ergo-cmd "focus_direction left")))
  (xbindkey-function '(j) (lambda () (ergo-cmd "focus_direction down")))
  (xbindkey-function '(k) (lambda () (ergo-cmd "focus_direction up")))
  (xbindkey-function '(l) (lambda () (ergo-cmd "focus_direction right")))

  (xbindkey-function '(period) (lambda () (ergo-cmd (move-window 100 0))))
  (xbindkey-function '(comma) (lambda () (ergo-cmd (move-window 0 -100))))
  (xbindkey-function '(m) (lambda () (ergo-cmd (move-window 0 100))))
  (xbindkey-function '(n) (lambda () (ergo-cmd (move-window -100 0))))

  (grab-all-keys))

(normal-bindings)
