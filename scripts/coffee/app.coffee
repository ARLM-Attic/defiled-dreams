
class Boot extends Phaser.State

    preload: () ->
        @load.image 'preloadBar', './assets/img/pregame/loader.png'

    create: () ->
        #device settings / changing them
        
        @game.state.start 'Preloader', true, false


class Game extends Phaser.Game

	MAX_LEVELS: 2

	constructor: () ->
		super 32*24, 32*20, Phaser.CANVAS, 'Defiled Dreams', null
		
		@state.add 'Boot', Boot, false
		@state.add 'Preloader', Preloader, false
		@state.add 'MainMenu', MainMenu, false

		@state.start 'Boot'

	saveData: (savePoint, mapName) ->
		localforage.setItem "savePoint-#{mapName}", {x: savePoint.x, y: savePoint.y, map: mapName}
		@player.savedX = savePoint.x
		@player.savedY = savePoint.y

	loadData: (mapName, callback) ->
		localforage.getItem "savePoint-#{mapName}", (coordinates) =>
			callback?(if coordinates then coordinates else {x: null, y: null, map: null} )
			@isLoaded = true



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


class MainMenu extends Phaser.State

	preload: () ->
		#reset old data
		@game.physics.gravity.y = 0
		@game.camera.follow null
		@buttons = []

		@load.spritesheet 'electric', './assets/img/game/electric.png', 32, 32

		@style = {font: "32px Arial", fill: "#fff", align: "center"}
		@headText = @game.add.text (@game.canvas.width/2)-130, 0, "Defiled Dreams", @style

		@game.stage.backgroundColor = '#aaaaaa'

	create: () ->
		for i in [1..@game.MAX_LEVELS]
			@buttons.push new MenuTextButton @game, 140+(32*i-1)+(3*i-1), 140, "#{i}"


class MenuTextButton
	constructor: (@game, x, y, text) ->
		@button = @game.add.button x,y,'electric', (()->@game.state.start "world-#{text}"), @, 1,0,2
		@text = @game.add.text x+8, y, text, @style

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

class Player

    moveSpeed: 250
    jumpSpeed: 350
    climbSpeed: 150

    pendingCallbacks: {}

    constructor: (@game, @savedX, @savedY, name) ->
        @ref = @game.add.sprite @savedX, @savedY, name

        @ref.body.maxVelocity.x = 400

        @cursors = @game.input.keyboard.createCursorKeys()

        @ref.body.bounce.y = 0.01
        @ref.body.collideWorldBounds = true
        @ref.body.rebound = false

        @ref.animations.add 'right', [14, 18, 22, 26], 10, true
        @ref.animations.add 'left', [15, 19, 23, 27], 10, true
        @ref.animations.add 'death', [0,1,2,3,4,5,6,7,8,9], 20

        @respawnKey = @game.input.keyboard.addKey Phaser.Keyboard.R

        @game.camera.follow @ref

        @initControllers()

    initControllers: () ->
        @game.input.gamepad.start()

    update: () ->

        #handle respawns
        respawnButtonIsDown = @respawnKey.isDown or
                @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_RIGHT_TRIGGER

        @respawn() if respawnButtonIsDown

        return if not @ref.alive

        moveLeftButtonIsDown = @cursors.left.isDown or
            @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_DPAD_LEFT

        moveRightButtonIsDown = @cursors.right.isDown or
            @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_DPAD_RIGHT

        jumpButtonIsDown = @cursors.up.isDown or
            @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_A

        climbButtonIsDown = @cursors.up.isDown or
            @game.input.gamepad.isDown Phaser.Gamepad.XBOX360_DPAD_UP

        isOnFloor = @ref.body.onFloor() or @ref.body.touching.down

        moveTolerance = @moveSpeed * (@game.time.elapsed / 1000)

        if (not moveLeftButtonIsDown) and 
           (not moveRightButtonIsDown)
            if -moveTolerance < @ref.body.velocity.x < moveTolerance
                @ref.body.velocity.x = 0
                @ref.body.acceleration.x = 0
            else
                delta = @ref.body.deltaX()
                @ref.body.acceleration.x = -@moveSpeed*delta

        #ladders
        if climbButtonIsDown and @canLadder
            @ref.body.allowGravity = false
            @ref.body.velocity.y = -@climbSpeed
            @ref.frame = 13

        else
            @ref.body.allowGravity = true

        #horizontal movement
        if moveLeftButtonIsDown
            @ref.body.acceleration.x = -@moveSpeed
            @ref.animations.play 'left'

        else if moveRightButtonIsDown
            @ref.body.acceleration.x = @moveSpeed
            @ref.animations.play 'right'

        else if not (@canLadder and climbButtonIsDown)
            @ref.animations.stop()
            @ref.frame = if @ref.body.velocity.y > 60 and not isOnFloor then 16 else 0

        #jump
        if jumpButtonIsDown and isOnFloor
            @ref.body.velocity.y = -@jumpSpeed

    die: (trap, pendingCallback) ->
        @pendingCallbacks[trap.x+","+trap.y] = pendingCallback
        return if not @ref.alive
        @ref.alive = false
        @ref.body.velocity.y = 0
        @ref.body.velocity.x = 0
        @ref.body.acceleration.x = 0
        @ref.body.acceleration.y = 0
        @ref.animations.play 'death'

    respawn: () ->
        return if @ref.alive
        @ref.x = @savedX
        @ref.y = @savedY

        @game.time.events.add 50, () =>
            @ref.alive = true
            @ref.frame = 0
            @pendingCallbacks[obj]?() for obj of @pendingCallbacks
            @pendingCallbacks = {}

class Playing extends Phaser.State

	noises:
		spring: null
		death: null
		save: null
		bgm: null

	gids:
		PLATFORM_VERTICAL: 40
		PLATFORM_HORIZONTAL: 41

		LADDER: 32

		SAVE: 20

		BLOCK_FADE: 24
		SPRING_UP: 36

		SPIKE_HIDDEN: 33
		SPIKE_FLOOR: 31

		SLOPE_EQUILATERAL: 29

		SHOOTER_PEWPEW: 39
		SHOOTER_LASER: 38
		SHOOTER_ARROW: 37

		WARP: 43

	create: () ->
		@setupGroups()
		@setupGameSettings()
		@loadSounds()
		@loadMapData()
		@loadPlatforms()
		@loadTraps()
		@loadSlopes()
		@loadShooters()
		@loadSaves()
		@loadWarps()
		@loadPlayer()
		@setupText()
		@postLoad()

	setupGroups: () ->
		@fadingBlocks = @game.add.group()

		@ladders = @game.add.group()

		@hiddenSpikeTraps = @game.add.group()
		@normalSpikeTraps = @game.add.group()

		@horizPlatforms = @game.add.group()
		@vertPlatforms = @game.add.group()
		
		@springs = @game.add.group()

		@platforms = @game.add.group()
		@platforms.add @horizPlatforms
		@platforms.add @vertPlatforms

		@slopes = @game.add.group()

		@lasers = @game.add.group()
		@arrows = @game.add.group()
		@arcs = @game.add.group()

		@shooters = @game.add.group()
		@shooters.add @lasers
		@shooters.add @arrows
		@shooters.add @arcs

		Playing::bullets = @game.add.group()

	setupText: () ->
		@text = @game.add.group()

		style = {font: "32px Arial", fill: "#000", align: "left"}
		@respawnText = @game.add.text 0, 0, "press r to respawn", style, @text
		@respawnText.fixedToCamera = true
		@respawnText.alpha = 0.3
		@respawnText.cameraOffset = new Phaser.Point 10,10
		@respawnText.renderable = false

		@saveText = @game.add.text 0, 0, "saving...", style, @text
		@saveText.fixedToCamera = true
		@saveText.alpha = 0.3
		@saveText.cameraOffset = new Phaser.Point 10,10
		@saveText.renderable = false

		@game.add.tween(@respawnText).to { alpha: 1 }, 1000, Phaser.Easing.Circular.InOut, true, 0, 1000, true
		@game.add.tween(@saveText).to { alpha: 1 }, 1000, Phaser.Easing.Circular.InOut, true, 0, 1000, true

	loadSounds: () ->
		@noises.spring = game.add.audio 'spring', 1, false
		@noises.death = game.add.audio 'death', 1, false
		@noises.save = game.add.audio 'save', 1, false
		@noises.bgm = game.add.audio 'bgm', 0.5, true

	setupGameSettings: () ->
		@game.stage.backgroundColor = '#aaaaaa'
		@game.physics.gravity.y = 730

	injectMapFunctionality: (map) ->
		map.createFromObjects = (name, gid, key, frame, exists = true, autoCull = true, group = @game.world, ctor = Phaser.Sprite) ->
			if not @objects[name]
				console.warn "Tilemap.createFromObjects: invalid objectgroup name given: #{name}"
				return

			i = 0
			len = @objects[name].length

			while i < len
				if @objects[name][i].gid is gid
					sprite = new ctor @game, @objects[name][i].x, @objects[name][i].y, key, frame
					sprite.exists = exists
					sprite.anchor.setTo 0, 1
					sprite.name = @objects[name][i].name
					sprite.visible = @objects[name][i].visible
					sprite.autoCull = autoCull
					group.add sprite
					for property of @objects[name][i].properties
						group.set sprite, property, @objects[name][i].properties[property], false, false, 0

					sprite.isReady() if 'isReady' of sprite and typeof sprite.isReady is 'function'
				i++

	loadMapData: () ->

		#load map
		@map = @game.add.tilemap "world-#{@levelNumber}"
		@map.addTilesetImage 'tiles', 'tiles'

		@injectMapFunctionality @map

		#main tiles
		@tileLayer = @map.createLayer 'MainLayer'
		@tileLayer.resizeWorld()

	loadPlatforms: () ->

		@map.createFromObjects 'PlatformLayer', @gids.LADDER, 'environment_16', 1, true, false, @ladders, Ladder

		@map.createFromObjects 'PlatformLayer', @gids.PLATFORM_HORIZONTAL, 'platforms', 2, true, false, @horizPlatforms, HorizontalPlatform

		@map.createFromObjects 'PlatformLayer', @gids.PLATFORM_VERTICAL, 'platforms', 1, true, false, @vertPlatforms, VerticalPlatform

	loadTraps: () ->

		@map.createFromObjects 'TrapLayer', @gids.BLOCK_FADE, 'fading-block', 0, true, false, @fadingBlocks, FadingBlock

		@map.createFromObjects 'TrapLayer', @gids.SPRING_UP, 'environment_8', 2, true, false, @springs, Spring

		@map.createFromObjects 'TrapLayer', @gids.SPIKE_HIDDEN, 'environment_8', 1, true, false, @hiddenSpikeTraps, HiddenSpike

		@map.createFromObjects 'TrapLayer', @gids.SPIKE_FLOOR, 'environment_16', 0, true, false, @normalSpikeTraps, SpikeFloor

	loadSlopes: () ->
		@map.createFromObjects 'SlopeLayer', @gids.SLOPE_EQUILATERAL, 'slopes', 4, true, false, @slopes, Slope

	loadShooters: () ->
		@map.createFromObjects 'TrapLayer', @gids.SHOOTER_ARROW, 'shooters', 0, true, false, @arrows, ArrowCannon

		@map.createFromObjects 'TrapLayer', @gids.SHOOTER_LASER, 'shooters', 1, true, false, @lasers, LaserCannon

		@map.createFromObjects 'TrapLayer', @gids.SHOOTER_PEWPEW, 'shooters', 2, true, false, @lasers, ArcCannon

	loadSaves: () ->
		@saves = @game.add.group()
		@map.createFromObjects 'SaveLayer', @gids.SAVE, 'save', 0, true, false, @saves, SavePoint

	loadWarps: () ->
		@warps = @game.add.group()
		@map.createFromObjects 'TrapLayer', @gids.WARP, 'warp', 0, true, false, @warps, Warp

	postLoad: () ->

		#collide with everything except nothing
		@map.setCollisionByExclusion [0]
		
		#@bgm.play '', 0, 1, true
	
	loadPlayer: () ->
		@players = @game.add.group()
		#load saved data if any
		@game.loadData @map.key, (coordinates) =>
			if @map.key isnt coordinates.map
				coordinates.x = 96
				coordinates.y = @map.heightInPixels - 96

			if coordinates.x is null or coordinates.y is null
				coordinates.x ?= 96
				coordinates.y ?= @map.heightInPixels - 96

			@game.player = new Player @game, coordinates.x, coordinates.y, 'player'
			@players.add @game.player.ref

	update: () ->
		return if not @game.isLoaded

		@respawnText.renderable = not @game.player.ref.alive

		[oldVelX, oldVelY] = [@game.player.ref.body.velocity.x, @game.player.ref.body.velocity.y]

		restoreVelocity = false

		@game.physics.collide @game.player.ref, @tileLayer

		@game.physics.collide @game.player.ref, @slopes

		@game.physics.collide @bullets, @tileLayer, (bullet) =>
			bullet.kill()

		@game.physics.collide @game.player.ref, @bullets, 
			(player, bullet) =>
				@killPlayer bullet
				bullet.kill()
			,
			(player, bullet) =>
				return player.alive

		@game.physics.collide @game.player.ref, @fadingBlocks, 
			(ref, block) => 
				if ref.body.touching.down
					@game.player.onBlock = true 
				else
					restoreVelocity = true
			,
			(ref, block) => 
				block.animations.play 'fade_once' if not ('auto' of block)
				return block.currentFrame.index is 0
		
		@game.physics.collide @game.player.ref, @platforms, 
			(player, platform) => 
				if player.body.touching.down
					@game.player.onPlatform = true
					player.x += platform.body.deltaX()
					player.y += platform.body.deltaY()
				else 
					restoreVelocity = true

		@game.physics.overlap @game.player.ref, @hiddenSpikeTraps, 
			(player, trap) =>
				trap.frame = 0
				@killPlayer trap, () ->
					trap.frame = 1
			,
			(player, trap) =>
				return player.alive

		@game.physics.collide @game.player.ref, @normalSpikeTraps, 
			(player, trap) =>
				@killPlayer trap
			,
			(player, trap) =>
				return player.alive

		@game.physics.overlap @game.player.ref, @springs, 
			(player, spring) => 
				spring.animations.play 'spring'
				@noises.spring.play '', 0, 0.5
				@game.player.ref.body.velocity.add spring.forceX, spring.forceY
			,
			(player, spring) =>
				return player.alive

		@game.physics.overlap @game.player.ref, @saves, 
			(player, save) => 
				return if not @game.player.ref.alive
				return if save.animRef and save.animRef.isPlaying
				@savePlayer save

		@game.physics.overlap @game.player.ref, @ladders, (player, ladder) =>
			@game.player.canLadder = true

		if restoreVelocity
			[@game.player.ref.body.velocity.x, @game.player.ref.body.velocity.y] = [oldVelX, oldVelY]

		@game.player.update()

		@game.physics.overlap @game.player.ref, @warps, (player, warp) =>
			if warp.offX is 0 and warp.offY is 0
				@finishLevel()
			else
				@game.player.ref.x = warp.x + warp.offX
				@game.player.ref.y = warp.y + warp.offY

		@game.player.canLadder = false
		@game.player.onPlatform = false
		@game.player.onBlock = false

	showSaveText: () ->
		@saveText.renderable = true
		@game.time.events.add 2000, () =>
			@saveText.renderable = false

	savePlayer: (save) ->
		save.animRef = save.animations.play 'ping'
		@game.saveData save, @map.key
		@noises.save.play '', 0, 0.5
		@showSaveText()

	killPlayer: (trap, callback) ->
		@noises.death.play '', 0, 0.5 if @game.player.ref.alive 
		@game.player.die trap, callback 

	finishLevel: () ->
		@game.state.start 'MainMenu'

	#render: () ->
	#    @bullets.forEach (o) =>
	#        @game.debug.renderSpriteBounds o, "#0f0"
	#        @game.debug.renderPhysicsBody o.body

class GameLevel extends Playing
	constructor: (@levelNumber) ->

	preload: () ->
		@game.load.tilemap "world-#{@levelNumber}", "./assets/maps/world-#{@levelNumber}.json", null, Phaser.Tilemap.TILED_JSON

class Preloader extends Phaser.State

	preload: () ->
		@preloadBar = @add.sprite 175, 250, 'preloadBar'
		@load.setPreloadSprite @preloadBar

		style = {font: "32px Arial", fill: "#fff", align: "left"}

		#maybe use game.timer.loop to do this?

		@loadText = @game.add.text (@game.canvas.width/2)-50, @game.canvas.height/2, "loading...", style

		@load.spritesheet 'save', './assets/img/game/save.png', 32, 32
		@load.spritesheet 'player', './assets/img/game/player.png', 32, 32
		@load.spritesheet 'warp', './assets/img/game/warp.png', 32, 32
		@load.spritesheet 'slopes', './assets/img/game/tiles/slopes.png', 32, 32
		@load.spritesheet 'bullets', './assets/img/game/bullets.png', 16, 8
		@load.spritesheet 'shooters', './assets/img/game/shooters.png', 32, 8
		@load.spritesheet 'platforms', './assets/img/game/tiles/platforms.png', 32, 16
		@load.spritesheet 'environment_8', './assets/img/game/tiles/environment_8.png', 32, 8
		@load.spritesheet 'environment_16', './assets/img/game/tiles/environment_16.png', 32, 16
		@load.spritesheet 'environment_32', './assets/img/game/tiles/environment_32.png', 32, 32
		@load.spritesheet 'fading-block', './assets/img/game/tiles/fading-block.png', 32, 32

		@load.image 'tiles', './assets/img/game/tiles/tiles.png'

		@load.audio 'bgm', ['./assets/sfx/bg.wav']
		@load.audio 'save', ['./assets/sfx/save.wav']
		@load.audio 'death', ['./assets/sfx/death.wav']
		@load.audio 'spring', ['./assets/sfx/spring.wav']

		for i in [1..@game.MAX_LEVELS]
			@game.state.add "world-#{i}", new GameLevel i, false

	create: () ->
		@startMainMenu()

	update: () ->
		@loadText.content = @load.progress + "%"

	startMainMenu: () ->
		#no main menu for now, straight to game
		@game.state.start 'MainMenu'

	
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
game = new Game()