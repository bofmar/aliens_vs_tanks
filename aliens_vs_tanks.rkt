;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname aliens_vs_tanks) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
(require test-engine/racket-tests)
(require racket/list)

;; Aliens vs Tanks
;; A simple game where the player takes the role of a tank, tasked with defending
;; the earth from the dastardly alien's invasion. The player can move left and right
;; and fire bullets directly up. The aliens appear from the top of the screen and move
;; on a 45 degree angle, either left or right. Game is over when an alien reaches the
;; bottom of the screen.

;; =================
;; Constants:
;; World Constants
(define WIDTH  300)
(define HEIGHT 500)
(define INVADE-RATE 100)
(define BACKGROUND (empty-scene WIDTH HEIGHT))
;; Tank Constants
(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body
(define TANK-SPEED 2)
(define TANK-HEIGHT/2 (/ (image-height TANK) 2))
(define TANK-HEIGHT (image-height TANK))
(define TANK-WIDTH/2 (/ (image-width TANK) 2))
;; Missile Constants
(define MISSILE-SPEED 10)
(define HIT-RANGE 10)
(define MISSILE (ellipse 5 15 "solid" "red"))
(define MISSILE-HEIGHT/2 (/ (image-height MISSILE) 2))
;; Invader constants
(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer
(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define INVADER-WIDTH/2 (/ (image-width INVADER) 2))

;; =================
;; Data definitions:
(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))

(define GX (make-game (list (make-invader 150 100 12) (make-invader 100 100 -12))
                      (list (make-missile 150 300) (make-missile 100 200))
                      (make-tank 50 1)))
(define G4 (make-game (list (make-invader 150 100 1.5) (make-invader 100 100 -1.5))
                      (list (make-missile 150 300) (make-missile 100 200))
                      (make-tank 50 1)))

(define LOM1 (list M1 M2 (make-missile 100 200)))
(define LOI1 (list I1 (make-invader 100 100 -10)))

;; =================
;; Functions:

;; Game -> Game
;; start the world with initial state g, for example (main G1)
;; 
(define (main g)
  (big-bang g									; g
            (on-tick   handle-tick)             ; g -> g
            (to-draw   render-world)))			; g -> Image
            ;;(stop-when ...)      ; WS -> Boolean
            ;;(on-key    ...)))    ; WS KeyEvent -> WS

;; Game -> Game
;; produce the next game state
;; !!!
(check-expect (handle-tick G1) G1) ;; Return the same world if no enemies and bullets exist
(check-expect (handle-tick G2) (make-game T1 (list (make-alien ALIEN-SHAPE (- 10 ALIEN-SPEED) (+ 20 ALIEN-SPEED) false) 
												   (make-alien ALIEN-SHAPE (+ 20 ALIEN-SPEED) (+ 30 ALIEN-SPEED) true))
										  (list (make-bullet BULLTET-SHAPE 30 (- 810  BULLET-SPEED))
												(make-bullet BULLTET-SHAPE 10 (- 900  BULLET-SPEED)))
										  P2 true)) ;; advance the game normaly

(define (handle-tick g)
  (make-game (game-tank g)
             (advance-aliens (game-alienList g))
             (advance-bullets (game-bulletList g))
             (game-points g)
             true))

;; Game -> Game
;; Consumes the current game state and removes items that have collided
(check-expect (filter-colided G1) G1)
(check-expect (filter-colided G3) (make-game T0 empty empty (make-points (text (number->string 1) FONT-SIZE FONT-COLOR) POINTS-X POINTS-Y) true))

(define (filter-colided g)
  (

;; AlienList -> AlienList
;; Advance all the aliens
(check-expect (advance-aliens empty) empty)
(check-expect (advance-aliens AL2) (list (make-alien ALIEN-SHAPE (- 10 ALIEN-SPEED) (+ 20 ALIEN-SPEED) false)
										 (make-alien ALIEN-SHAPE (+ 10 ALIEN-SPEED) (+ 20 ALIEN-SPEED) true)))

(define (advance-aliens al)
		(cond [(empty? al) empty]
			  [else (cons (get-advanced-alien (first al)) (advance-aliens (rest al)))]))

;; Alien -> Alien
;; Consumes an alien and produces a new one with the correct new co-ordinates
(check-expect (get-advanced-alien A1) (make-alien ALIEN-SHAPE (- 10 ALIEN-SPEED) (+ 20 ALIEN-SPEED) false))
(check-expect (get-advanced-alien A2) (make-alien ALIEN-SHAPE (+ 10 ALIEN-SPEED) (+ 20 ALIEN-SPEED) true))
(check-expect (get-advanced-alien (make-alien ALIEN-SHAPE ALIEN-SPEED 10 false))
								  (make-alien ALIEN-SHAPE 0 (+ 10 ALIEN-SPEED) true)) ;; change direction
(check-expect (get-advanced-alien (make-alien ALIEN-SHAPE (- WIDTH ALIEN-SPEED) 10 true))
								  (make-alien ALIEN-SHAPE WIDTH (+ 10 ALIEN-SPEED) false)) ;; change direction

(define (get-advanced-alien a)
  (cond [(and (boolean=? (alien-direction a) true) (< (+ (alien-x a) ALIEN-SPEED) WIDTH))
			(make-alien ALIEN-SHAPE (+ (alien-x a) ALIEN-SPEED) (+ (alien-y a) ALIEN-SPEED) true)]
		[(and (boolean=? (alien-direction a) true) (>= (+ (alien-x a) ALIEN-SPEED) WIDTH))
			(make-alien ALIEN-SHAPE WIDTH (+ (alien-y a) ALIEN-SPEED) false)]
		[(and (boolean=? (alien-direction a) false) (> (- (alien-x a) ALIEN-SPEED) 0))
			(make-alien ALIEN-SHAPE (- (alien-x a) ALIEN-SPEED) (+ (alien-y a) ALIEN-SPEED) false)]
		[else (make-alien ALIEN-SHAPE 0 (+ (alien-y a) ALIEN-SPEED) true)]))


;; BulletList -> BulletList
;; Advance all bullets
(check-expect (advance-bullets empty) empty)
(check-expect (advance-bullets BL2) (list (make-bullet BULLTET-SHAPE 30 (- 810 BULLET-SPEED))))
(check-expect (advance-bullets (list (make-bullet BULLTET-SHAPE 10 HEIGHT))) empty) ;;remove bullets when they go out of the screen
(check-expect (advance-bullets (list (make-bullet BULLTET-SHAPE 10 HEIGHT) B1)) (list (make-bullet BULLTET-SHAPE 30 (- 810 BULLET-SPEED))))

(define (advance-bullets bl)
		(cond [(empty? bl) empty]
			  [(> (+ (bullet-y (first bl)) BULLET-SPEED) HEIGHT) (advance-bullets (rest bl))]
			  [else (cons (make-bullet BULLTET-SHAPE (bullet-x (first bl)) (- (bullet-y (first bl)) BULLET-SPEED))
						  (advance-bullets (rest bl)))]))
		

;; Game -> Image
;; render all items in their propper positions
(check-expect (render-world G1) (place-images
                                 (list TANK-SHAPE (points-img P1))
								 (list (make-posn (/ WIDTH 2) TANK-Y)
									   (make-posn POINTS-X POINTS-Y)) MTS))
(check-expect (render-world (make-game T1 (list A1 A3) (list B1 B2) P2 true))
			  (place-images (list TANK-SHAPE ALIEN-SHAPE ALIEN-SHAPE BULLTET-SHAPE BULLTET-SHAPE (points-img P2))
							(list (make-posn 20 TANK-Y) (make-posn 10 20)
								  (make-posn 20 30) (make-posn 30 810)
								  (make-posn 10 900) (make-posn POINTS-X POINTS-Y)) MTS))

(define (render-world g)
	(place-images (get-images-list g)
                      (get-positions g) MTS))

;; Game -> ListOfImage
;; Takes the game and produces an image for every object in it
(check-expect (get-images-list G1) (list TANK-SHAPE (points-img P1)))
(check-expect (get-images-list G2) (list TANK-SHAPE ALIEN-SHAPE ALIEN-SHAPE BULLTET-SHAPE BULLTET-SHAPE (points-img P2)))

(define (get-images-list g)
  (flatten (cons TANK-SHAPE (cons (get-alien-images (game-alienList g)) 
		(cons (get-bullet-images (game-bulletList g)) (cons (points-img (game-points g)) empty))))))
																								
;; AliensList -> ListOfImage
;; Takes a list of aliens and returns their images
(check-expect (get-alien-images empty) empty)
(check-expect (get-alien-images AL2) (list ALIEN-SHAPE ALIEN-SHAPE))

(define (get-alien-images al)
  (cond [(empty? al) empty]
		[else (cons ALIEN-SHAPE (get-alien-images (rest al)))]))

;; BulletList -> ListOfImage
;; Takes a list of bullets and returns their images
(check-expect (get-bullet-images empty) empty)
(check-expect (get-bullet-images BL2) (list BULLTET-SHAPE))

(define (get-bullet-images bl)
  (cond [(empty? bl) empty]
		[else (cons BULLTET-SHAPE (get-bullet-images (rest bl)))]))

;; Game -> ListOfPositions
;; Takes the game and produces an posn for every object in it
(check-expect (get-positions G1) 
			  (list (make-posn (tank-x (game-tank G1)) TANK-Y) (make-posn POINTS-X POINTS-Y)))
(check-expect (get-positions G2) (list (make-posn 20 TANK-Y) (make-posn 10 20)
								  (make-posn 20 30) (make-posn 30 810)
								  (make-posn 10 900) (make-posn POINTS-X POINTS-Y)))

(define (get-positions g)
  (flatten (cons (make-posn (tank-x (game-tank g)) TANK-Y)
				 (cons (get-alien-positions (game-alienList g))
					   (cons (get-bullet-positions (game-bulletList g))
							 (cons (make-posn POINTS-X POINTS-Y) empty))))))
																								
;; AliensList -> ListOfPosn
;; Takes a list of aliens and returns their posn
(check-expect (get-alien-positions empty) empty)
(check-expect (get-alien-positions AL3) (list (make-posn 10 20) (make-posn 20 30)))

(define (get-alien-positions al)
  (cond [(empty? al) empty]
		[else (cons (make-posn (alien-x (first al)) (alien-y (first al)))
							   (get-alien-positions (rest al)))]))

;; BulletList -> ListOfPosn
;; Takes a list of bullets and returns their positions
(check-expect (get-bullet-positions empty) empty)
(check-expect (get-bullet-positions BL2) (list (make-posn 30 810)))

(define (get-bullet-positions bl)
  (cond [(empty? bl) empty]
		[else (cons (make-posn (bullet-x (first bl)) (bullet-y (first bl)))
					(get-bullet-positions (rest bl)))]))

(test)
;;(main G1)
;;(main G2)
