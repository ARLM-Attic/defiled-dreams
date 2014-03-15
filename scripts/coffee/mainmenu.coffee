
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