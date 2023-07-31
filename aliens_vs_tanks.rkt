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
(define WIDTH 600)
(define HEIGHT 1000)
(define MTS (empty-scene WIDTH HEIGHT "black"))
;; Tank Constants
(define TANK-HEIGHT 30)
(define TANK-SHAPE (rectangle 60 TANK-HEIGHT "solid" "blue"))
(define TANK-SPEED 5)
(define TANK-Y (- HEIGHT (/ TANK-HEIGHT 2) 5))
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
(define FONT-SIZE 32)


;; =================
;; Data definitions:

;; Alien
(define-struct alien (img x y direction))
;; Alien is (make-alien IMAGE NUMBER NUMBER BOOLEAN)
;; interp. an ellipse with an x and y position and a true or false direction
;; (true means the alien is movig rigth, false that it moves left)
(define A1 (make-alien ALIEN-SHAPE 10 20 false)) ;; alien moving right
(define A2 (make-alien ALIEN-SHAPE 10 20 true)) ;; alien moving left
(define A3 (make-alien ALIEN-SHAPE 20 30 true)) ;; alien moving left

;; Tank
(define-struct tank (img x y))
;; Tank is (make-tank IMAGE NUMBER NUMBER)
;; interp. a rectangle with an x and y position
(define T0 (make-tank TANK-SHAPE (/ WIDTH 2) TANK-Y))
(define T1 (make-tank TANK-SHAPE 20 TANK-Y))

;; Bullet
(define-struct bullet (img x y))
;; Bullet is (make-bullet IMAGE NUMBER NUMBER)
;; interp. a bullet with an x and y position
(define B1 (make-bullet BULLTET-SHAPE 30 810))
(define B2 (make-bullet BULLTET-SHAPE 10 900))

;; Points
(define-struct points (img x y))
;; Points is (make-points IMAGE NUMBER NUMBER)
;; interp. a points text with an x and y position
(define P1 (make-points (text (number->string 0) FONT-SIZE FONT-COLOR) POINTS-X POINTS-Y))
(define P2 (make-points (text (number->string 20) FONT-SIZE FONT-COLOR) POINTS-X POINTS-Y))

;; AliensList is one of:
;; - empty
;; - (const Alien AliensList)
(define AL1 empty)
(define AL2 (list A1 A2))
(define AL3 (list A2 A3))

;; BulletsList is one of:
;; - empty
;; - (const Bullet BulletsList)
(define BL1 empty)
(define BL2 (list B1))

(define-struct game (tank alienList bulletList points state))
;; Game is (make-game Tank AlienList BulletList Points Boolean)
;; interp. If state is true then the game goes on. Else it's game over.
(define G1 (make-game T0 AL1 BL1 P1 true))
(define G2 (make-game T1 (list A1 A3) (list B1 B2) P2 true))


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
												   (make-alien ALIEN-SHAPE (+ 20 ALIEN-SPEED) (+ 31 ALIEN-SPEED) true))
										  (list (make-bullet BULLTET-SHAPE 30 (+ 810  BULLET-SPEED))
												(make-bullet BULLTET-SHAPE 10 (+ 900  BULLET-SPEED)))
										  P2 true)) ;; advance the game normaly

(define (handle-tick g)
  (flatten (cons (game-tank g) (cons (advance-aliens (game-alienList g))
							  (cons (advance-bullets (game-bulletList g))
									(cons (game-points g)
                                                                              (cons true empty)))))))

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

(define (advance-bullets bl) bl)
		

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
