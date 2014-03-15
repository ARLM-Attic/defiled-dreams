
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