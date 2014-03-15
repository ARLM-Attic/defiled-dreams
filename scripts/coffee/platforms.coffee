
class Platform extends Phaser.Sprite
	constructor: (game, x, y, key, frame) ->
		super game,x,y,key,frame
		@body.allowGravity = false
		@body.immovable = true

	isReady: () ->
		@moveMod = +@moveMod or 0
		@delay = +@delay or 0
		@calcDist = Math.abs @moveMod

		opposite = String.fromCharCode not (@platType.charCodeAt()-120)+120

		#@game.time.events.add @delay, () ->
		if @moveMod isnt 0
			@game.time.events.loop 1, () -> 
				type = @platType
				@[opposite] = @base
				@body.velocity[opposite] = 0
				@basePos = @basePos or @[type] // 32
				@destPos = @destPos or @basePos + @calcDist
				@prevPos = @prevPos or @basePos

				cur = @[type] // 32

				@body.velocity[type] = (if @destPos - cur < 0 then -100 else 100)

				if cur is @destPos and @prevPos isnt @destPos
					@destPos = if @prevPos - cur > 0 then @basePos + @calcDist else @basePos - @calcDist

				@prevPos = cur

			, @
		#, @

class HorizontalPlatform extends Platform
	constructor: (game,x,y) ->
		@platType = 'x'
		@base = y
		super game,x,y,'platforms',1

class VerticalPlatform extends Platform
	constructor: (game,x,y) ->
		@platType = 'y'
		@base = x
		super game,x,y,'platforms',0
