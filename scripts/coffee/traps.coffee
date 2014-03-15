

class Trap extends GameObject
	constructor: (game, x, y, key, frame) ->
		super game,x,y,key,frame
		@body.moves = false

class FadingBlock extends Trap
	constructor: (game, x, y) ->
		super game,x,y,'fading-block', 0
		@animations.add 'fade', [0,0,0,0,1,2,3,2,1,0,0,0,0], 4, true
		@animations.add 'fade_once', [0,0,1,2,3,2,1,0,0,0,0], 4

	isReady: () ->
		return if not @auto
		delay = +@delay or 0
		@game.time.events.add delay, (() -> @animations.play 'fade'), @

class Spring extends Trap
	constructor: (game, x, y) ->
		super game,x,y,'environment_8', 2
		@animations.add 'spring', [3, 2], 10, false
		@body.setRectangle 24, 8, 4, 0

	isReady: () ->
		@forceX = +@forceX or 0
		@forceY = +@forceY or 0
		@frame = 2
		super()

class HiddenSpike extends Trap
	constructor: (game, x, y) ->
		super game,x,y,'environment_8', 1
		@animations.add 'reveal', [0, 1], 4
		@frame = 1

class SpikeFloor extends Trap
	constructor: (game, x, y) ->
		super game,x,y,'environment_16', 0
		@body.setRectangle 32,16,0,0