
	
class Projectile extends Phaser.Sprite
	constructor: (game, x, y, key, frame, velX, velY) ->
		super game,x,y,key,frame
		@outOfBoundsKill = true
		@body.velocity = new Phaser.Point velX, velY

	rotateProj: (angle) ->
		@angle = angle
		if angle isnt 0 and angle isnt 180
			@body.polygon.translate 0, -@height
			@body.polygon.rotate (angle-180)*Math.PI/180
			@body.polygon.translate 0, @height

class Arrow extends Projectile
	constructor: (game, x, y, velX, velY) ->
		super game, x, y, 'bullets', 5, velX, velY
		@body.linearDamping = 0.1

class Laser extends Projectile
	constructor: (game, x, y, velX, velY) ->
		super game, x, y, 'bullets', 4, velX, velY
		@body.allowGravity = false

class Bullet extends Projectile
	constructor: (game, x, y, velX, velY) ->
		super game, x, y, 'bullets', 3, velX, velY
		@body.allowGravity = false