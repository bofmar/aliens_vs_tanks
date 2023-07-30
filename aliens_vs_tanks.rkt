;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname aliens_vs_tanks) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
(require test-engine/racket-tests)

;; Aliens vs Tanks

;; =================
;; Constants:
;; World Constants
(define WIDTH 600)
(define HEIGHT 400)
(define MTS (empty-scene WIDTH HEIGHT "black"))
;; Tank Constants
(define TANK-SHAPE (rectangle 60 30 "solid" "blue"))
(define TANK-SPEED 5)
;; Bullet Constants
(define BULLTET-SHAPE (rectangle 10 30 "solid" "white"))
(define BULLET-SPEED 5)
;; ALien constants
(define ALIEN-SHAPE (ellipse 60 30 "solid" "gray"))
(define ALIEN-SPEED 5)
(define SPAWN-Y 0)
;; Points constants
(define POINTS-X (/ WIDTH 2))
(define POINTS-Y 30)
(define FONT-COLOR "white")
(define FONT-SIZE 16)




;; =================
;; Data definitions:

;; WS is ... (give WS a better name)



;; =================
;; Functions:

;; WS -> WS
;; start the world with ...
;; 
(define (main ws)
  (big-bang ws                   ; WS
            (on-tick   tock)     ; WS -> WS
            (to-draw   render)   ; WS -> Image
            (stop-when ...)      ; WS -> Boolean
            (on-mouse  ...)      ; WS Integer Integer MouseEvent -> WS
            (on-key    ...)))    ; WS KeyEvent -> WS

;; WS -> WS
;; produce the next ...
;; !!!
(define (tock ws) ...)


;; WS -> Image
;; render ... 
;; !!!
(define (render ws) ...)


(test)
