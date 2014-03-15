
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