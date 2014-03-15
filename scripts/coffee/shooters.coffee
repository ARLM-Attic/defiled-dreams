

class Shooter extends GameObject

	projectileMap:
		"Arrow": Arrow
		"Laser": Laser
		"Bullet": Bullet

	constructor: (game, x, y, key, frame) ->
		super game,x,y,key,frame
		@body.moves = false

		#shoot arrows by default
		@projectile = "Arrow"
		@projAngle = 0

	recalculate: () ->

	isReady: () ->
		@delay = +@delay or 2000
		@projOffX = +@projOffX or 0
		@projOffY = +@projOffY or 0
		@projVelX = +@projVelX or 0
		@projVelY = +@projVelY or 0
		@minProjAngle = +@minProjAngle or 0
		@maxProjAngle = +@maxProjAngle or 0
		@projAngle = +@projAngle or 0
		@force = +@force or 200
		@rotate = +@rotate or 0

		@setBaseVariables()

		projectileClass = Shooter::projectileMap[@projectile]

		@game.time.events.loop @delay, () -> 
			bullet = new projectileClass @game, @x + @projOffX,	@y + @projOffY, @projVelX, @projVelY
			Playing::bullets.add bullet
			bullet.rotateProj @projAngle
			@recalculate bullet
		, @
		super()

	setBaseVariables: () ->
		switch @rotate
			when 0
				@projOffX = @projOffX or 22
				@projOffY = @projOffY or -8
				@projAngle = @projAngle or 90
				@projVelY = @projVelY or -@force
			when 90
				@projOffY = @projOffY or 10
				@projOffX = @projOffX or 4
				@projVelX = @projVelX or @force
			when -90
				@projOffY = @projOffY or -21
				@projOffX = @projOffX or -18
				@projVelX = @projVelX or -@force
			when 180,-180
				@projOffX = @projOffX or -10
				@projOffY = @projOffY or 4
				@projAngle = @projAngle or 90
				@projVelY = @projVelY or @force

class ArrowCannon extends Shooter
	constructor: (game, x, y) ->
		super game,x,y,'shooters',0

class LaserCannon extends Shooter
	constructor: (game, x, y) ->
		super game,x,y,'shooters',1
		@projectile = "Laser"

class ArcCannon extends Shooter
	constructor: (game, x, y) ->
		super game,x,y,'shooters',2
		@projectile = "Bullet"
		@projAngle = 90

	recalculate: (bullet) ->
		@projOffX = ((@projOffX + 1) % 32)
		if @projOffX is 0 then @projOffX = 8
		angle = (((bullet.x - @x) / 32) * (@maxProjAngle - @minProjAngle) + @minProjAngle)
		bullet.body.velocity.rotate @x + @width/2, 
									@y + @height/2, 
									angle, 
									true
		bullet.angle = angle
