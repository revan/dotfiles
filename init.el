(require 'evil)
(evil-mode 1)

(require 'linum-relative)
(setq linum-relative-current-symbol "->" )
(global-linum-mode 1)

(require 'git-gutter-fringe+)
(global-git-gutter+-mode t)
(fringe-mode)

(setq prelude-guru nil)

(setq-default indent-tabs-mode t)
(setq c-default-style "linux"
	  c-basic-offset 4)
(setq-default tab-width 4)

(setq prelude-whitespace nil)

(smart-tabs-insinuate 'c 'javascript 'python)

(global-set-key (kbd "RET") 'newline-and-indent)

(require 'rainbow-delimiters)
(global-rainbow-delimiters-mode)
