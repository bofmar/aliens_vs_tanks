;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname aliens_vs_tanks) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
(require test-engine/racket-tests)

;; Aliens vs Tanks
;; A simple game where the player takes the role of a tank, tasked with defending
;; the earth from the dastardly alien's invasion. The player can move left and right
;; and fire bullets directly up. The aliens appear from the top of the screen and move
;; on a 45 degree angle, either left or right. Game is over when an alien reaches the
;; bottom of the screen.

;; =================
;; Constants:
;; World Constants
(define WIDTH 600)
(define HEIGHT 400)
(define MTS (empty-scene WIDTH HEIGHT "black"))
;; Tank Constants
(define TANK-SHAPE (rectangle 60 30 "solid" "blue"))
(define TANK-SPEED 5)
(define TANKT-Y 0)
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

;; Alien
(define-struct alien (img x y direction))
;; Alien is (make-alien IMAGE NUMBER NUMBER BOOLEAN)
;; interp. an ellipse with an x and y position and a true or false direction
;; (true means the alien is movig left, false that it moves right)
(define A1 (make-alien ALIEN-SHAPE 10 20 false)) ;; alien moving right
(define A2 (make-alien ALIEN-SHAPE 10 20 true)) ;; alien moving left

;; Tank
(define-struct tank (img x y))
;; Tank is (make-tank IMAGE NUMBER NUMBER)
;; interp. a rectangle with an x and y position
(define T0 (make-tank TANK-SHAPE 0 TANKT-Y))
(define T1 (make-tank TANK-SHAPE 20 TANKT-Y))

;; Bullet
(define-struct bullet (img x y))
;; Bullet is (make-bullet IMAGE NUMBER NUMBER)
;; interp. a bullet with an x and y position
(define B1 (make-bullet BULLTET-SHAPE 30 10))

;; Points
(define-struct points (img x y))
;; Points is (make-points IMAGE NUMBER NUMBER)
;; interp. a points text with an x and y position
(define P1 (make-points (text 0 FONT-SIZE FONT-COLOR) POINTS-X POINTS-Y))

;; AliensList is one of:
;; - empty
;; - (const Alien AliensList)
(define AL1 (cons empty))
(define AL2 (list A1 A2))

;; BulletsList is one of:
;; - empty
;; - (const Bullet BulletsList)
(define BL1 (cons empty))
(define BL2 (list B1))

(define-struct game (tank alienList bulletList points state))
;; Game is (make-game Tank AlienList BulletList Points Boolean)
;; interp. If state is true then the game goes on. Else it's game over.
(define G1 (make-game T0 AL1 BL1 P1 true))


;; =================
;; Functions:

;; Game -> Game
;; start the world with initial state g, for example (main G1)
;; 
(define (main g)
  (big-bang g									; g
            (on-tick   handle-tick)             ; WS -> WS
            (to-draw   render-world)))			; WS -> Image
            ;;(stop-when ...)      ; WS -> Boolean
            ;;(on-key    ...)))    ; WS KeyEvent -> WS

;; WS -> WS
;; produce the next ...
;; !!!
(define (handle-tick g) ...)


;; WS -> Image
;; render ... 
;; !!!
(define (render-world g) ...)


(test)
