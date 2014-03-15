

class GameObject extends Phaser.Sprite
	constructor: (game, x, y, key, frame) ->
		super game,x,y,key,frame

	rotateObj: (angle) ->
		@angle = angle
		@y -= 32 if angle > 0
		@x += 32 if angle < 0 or angle is 180

		@body.polygon.translate 0, -@height
		@body.polygon.rotate angle*Math.PI/180
		@body.polygon.translate 0, @height

	isReady: () ->
		return if not ('rotate' of @)
		@rotateObj +@rotate

class Slope extends GameObject
	constructor: (game, x, y) ->
		super game,x,y,'slopes',4
		@body.moves = false
		@body.setPolygon 0,32,32,32,32,0

class Ladder extends GameObject
	constructor: (game, x, y) ->
		super game,x,y,'environment_16',1
		@body.moves = false
		@angle = 90
		@x+=8
		@y-=32
		@body.setRectangle 16, 32, 0, 0

class SavePoint extends GameObject
	constructor: (game, x, y) ->
		super game,x,y,'save',0
		@body.moves = false
		@body.setCircle 10
		@animations.add 'ping', [3,2,1,2,3,1,2,3,2,1,3,1,2,3,1,0], 10, false
		@frame = 0

class Warp extends GameObject
	constructor: (game, x, y) ->
		super game,x,y,'warp',0
		@body.moves = false
		@animations.add 'warp', [0,1,2,3,4], 10, true
		@animations.play 'warp'

	isReady: () ->
		@offX = +@offX or 0
		@offY = +@offY or 0
